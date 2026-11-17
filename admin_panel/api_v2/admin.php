<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$action = $_REQUEST['action'] ?? 'dashboard';

try {
    switch ($action) {
        case 'dashboard':
            $stats = [];
            $stats['user_count'] = $conn->query("SELECT COUNT(*) FROM user WHERE role = 'user'")->fetchColumn();
            $stats['designer_count'] = $conn->query("SELECT COUNT(*) FROM user WHERE role = 'designer'")->fetchColumn();
            $stats['pending_requests'] = $conn->query("SELECT COUNT(*) FROM designer_request WHERE status = 'pending'")->fetchColumn();
            $stats['active_projects'] = $conn->query("SELECT COUNT(*) FROM project WHERE status = 'in_progress'")->fetchColumn();
            $stats['total_designs'] = $conn->query("SELECT COUNT(*) FROM generated_images")->fetchColumn();
            
            // Recent activity
            $stmt = $conn->query("SELECT l.*, u.name as actor_name FROM activity_logs l LEFT JOIN user u ON l.actor_id = u.id ORDER BY l.created_at DESC LIMIT 10");
            $stats['recent_activity'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode(['status' => 'success', 'stats' => $stats]);
            break;

        case 'users':
            $stmt = $conn->query("SELECT id, name, email, username, phone, role, created_at FROM user ORDER BY created_at DESC");
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['status' => 'success', 'users' => $users]);
            break;

        case 'designers':
            $stmt = $conn->query("SELECT u.id, u.name, u.email, d.bio, d.rating, d.experience_years FROM user u JOIN designer d ON u.id = d.user_id");
            $designers = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['status' => 'success', 'designers' => $designers]);
            break;

        case 'logs':
            $stmt = $conn->query("SELECT l.*, u.name as actor_name FROM activity_logs l LEFT JOIN user u ON l.actor_id = u.id ORDER BY l.created_at DESC");
            $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['status' => 'success', 'logs' => $logs]);
            break;

        case 'requests':
            $stmt = $conn->query("SELECT r.id, r.status, r.created_at,
                                         u.name AS user_name, 
                                         du.name AS designer_name,
                                         p.name AS project_name,
                                         p.status AS project_status
                                  FROM designer_request r
                                  JOIN user u ON r.user_id = u.id
                                  JOIN designer d ON r.designer_id = d.id
                                  JOIN user du ON d.user_id = du.id
                                  JOIN project p ON r.project_id = p.id
                                  ORDER BY r.created_at DESC");
            $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['status' => 'success', 'data' => $requests]);
            break;
            
        case 'update_user':
            $id = $_POST['id'];
            $role = $_POST['role'];
            $stmt = $conn->prepare("UPDATE user SET role = ? WHERE id = ?");
            $stmt->execute([$role, $id]);
            echo json_encode(['status' => 'success']);
            break;
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
