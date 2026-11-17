<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$user_id = $_GET['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'Missing user ID']);
    exit;
}

try {
    $stmt = $conn->prepare("
        SELECT 
            c.id as chat_id,
            u.id as other_user_id,
            u.name as other_user_name,
            u.profile_pic_url,
            m.message_text as last_message,
            m.timestamp as last_time,
            m.sender_id as last_sender,
            (SELECT COUNT(*) FROM messages WHERE chat_id = c.id AND receiver_id = ? AND is_read = 0) as unread_count
        FROM chats c
        JOIN user u ON (u.id = c.user1_id OR u.id = c.user2_id) AND u.id != ?
        LEFT JOIN messages m ON m.id = (
            SELECT id FROM messages WHERE chat_id = c.id ORDER BY timestamp DESC LIMIT 1
        )
        WHERE c.user1_id = ? OR c.user2_id = ?
        ORDER BY m.timestamp DESC
    ");
    $stmt->execute([$user_id, $user_id, $user_id, $user_id]);
    $chats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['status' => 'success', 'chats' => $chats]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
