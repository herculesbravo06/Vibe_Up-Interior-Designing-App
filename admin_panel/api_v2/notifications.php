<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    if ($data) {
        $_POST = array_merge($_POST, $data);
    }
}

$action = $_REQUEST['action'] ?? 'list';
$user_id = $_REQUEST['user_id'] ?? null;

if (!$user_id && $action !== 'none') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    if (isset($data['user_id'])) $user_id = $data['user_id'];
    
    if (!$user_id) {
        echo json_encode(['status' => 'error', 'message' => 'Missing user ID']);
        exit;
    }
}

// Robust ID resolution: If a designer_id (D...) was passed, resolve to the user_id
$resolved_user_id = $user_id;
$stmt = $conn->prepare("SELECT user_id FROM designer WHERE id = ? LIMIT 1");
$stmt->execute([$user_id]);
$found_user_id = $stmt->fetchColumn();
if ($found_user_id) {
    $resolved_user_id = $found_user_id;
}

try {
    switch ($action) {
        case 'list':
            $days = $_GET['days'] ?? null;
            
            $sql = "SELECT * FROM notifications WHERE user_id = ?";
            $params = [$resolved_user_id];
            
            if ($days) {
                $sql .= " AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)";
                $params[] = (int)$days;
            }
            
            $sql .= " ORDER BY created_at DESC LIMIT 50";
            
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            $notifs = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stmt = $conn->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
            $stmt->execute([$resolved_user_id]);
            $unread = $stmt->fetchColumn();
            
            echo json_encode(['status' => 'success', 'data' => $notifs, 'unread_count' => (int)$unread]);
            break;
            
        case 'mark_read':
            $id = $_POST['id'] ?? $_POST['notification_id'];
            $stmt = $conn->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?");
            $stmt->execute([$id, $resolved_user_id]);
            echo json_encode(['status' => 'success']);
            break;
            
        case 'mark_all_read':
            $stmt = $conn->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
            $stmt->execute([$resolved_user_id]);
            echo json_encode(['status' => 'success']);
            break;
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
