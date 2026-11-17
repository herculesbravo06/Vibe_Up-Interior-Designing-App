<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$user1 = $_GET['user1_id'] ?? $_GET['user_a'] ?? null;
$user2 = $_GET['user2_id'] ?? $_GET['user_b'] ?? null;

// ID Resolution: Convert designer_id (D...) to user_id (U...)
function resolveUserId($conn, $id) {
    if (!$id) return null;
    if (strpos($id, 'D') === 0) {
        $stmt = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
        $stmt->execute([$id]);
        $uid = $stmt->fetchColumn();
        return $uid ?: $id;
    }
    return $id;
}

$user1 = resolveUserId($conn, $user1);
$user2 = resolveUserId($conn, $user2);

// Debug logging
file_put_contents('../uploads/debug_log.txt', date('[Y-m-d H:i:s] ') . "HISTORY RESOLVED: $user1 vs $user2\n", FILE_APPEND);

if (!$user1 || !$user2) {
    echo json_encode(['status' => 'error', 'message' => 'Missing user IDs (user1_id/user2_id or user_a/user_b)']);
    exit;
}

try {
    // 1. Get Chat ID
    $stmt = $conn->prepare("SELECT id FROM chats WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)");
    $stmt->execute([$user1, $user2, $user2, $user1]);
    $chat = $stmt->fetch();

    if (!$chat) {
        echo json_encode(['status' => 'success', 'history' => [], 'data' => []]);
        exit;
    }

    $chat_id = $chat['id'];

    // 2. Mark messages as read for user1 (the requester)
    $stmt = $conn->prepare("UPDATE messages SET is_read = 1 WHERE chat_id = ? AND receiver_id = ? AND is_read = 0");
    $stmt->execute([$chat_id, $user1]);

    // 3. Fetch history
    $stmt = $conn->prepare("SELECT * FROM messages WHERE chat_id = ? ORDER BY timestamp ASC");
    $stmt->execute([$chat_id]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['status' => 'success', 'history' => $messages, 'data' => $messages]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
