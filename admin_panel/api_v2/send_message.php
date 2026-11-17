<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle JSON input
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    // Debug logging
    file_put_contents('../uploads/debug_log.txt', date('[Y-m-d H:i:s] ') . "RAW: " . $json . "\n", FILE_APPEND);
    file_put_contents('../uploads/debug_log.txt', "POST: " . json_encode($_POST) . "\n", FILE_APPEND);

    $params = array_merge($_POST, ($data ?? []));
    
    $chat_id = $params['chat_id'] ?? null;
    $sender_id = $params['sender_id'] ?? null;
    $receiver_id = $params['receiver_id'] ?? null;
    $message_text = $params['message_text'] ?? '';

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

    $sender_id = resolveUserId($conn, $sender_id);
    $receiver_id = resolveUserId($conn, $receiver_id);

    file_put_contents('../uploads/debug_log.txt', "RESOLVED: S:$sender_id R:$receiver_id\n", FILE_APPEND);

    if (!$sender_id || !$receiver_id) {
        echo json_encode(['status' => 'error', 'message' => 'Missing sender_id or receiver_id']);
        exit;
    }
    
    // File upload logic
    $file_url = null;
    $file_type = null;
    
    if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = '../uploads/chat/';
        if (!is_dir($upload_dir)) mkdir($upload_dir, 0777, true);
        
        $file_name = time() . '_' . basename($_FILES['file']['name']);
        $target_file = $upload_dir . $file_name;
        
        if (move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
            $file_url = 'uploads/chat/' . $file_name;
            $file_type = $_FILES['file']['type']; // e.g. image/jpeg, application/pdf
        }
    }

    try {
        if (!$chat_id) {
            // Find or create chat
            $stmt = $conn->prepare("SELECT id FROM chats WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)");
            $stmt->execute([$sender_id, $receiver_id, $receiver_id, $sender_id]);
            $chat = $stmt->fetch();
            
            if ($chat) {
                $chat_id = $chat['id'];
            } else {
                $chat_id = 'CH' . substr(uniqid(), -8);
                $stmt = $conn->prepare("INSERT INTO chats (id, user1_id, user2_id) VALUES (?, ?, ?)");
                $stmt->execute([$chat_id, $sender_id, $receiver_id]);
            }
        }

        $msg_id = 'MSG' . substr(uniqid(), -8);
        $stmt = $conn->prepare("INSERT INTO messages (id, chat_id, sender_id, receiver_id, message_text, file_url, file_type, is_read) VALUES (?, ?, ?, ?, ?, ?, ?, 0)");
        $stmt->execute([$msg_id, $chat_id, $sender_id, $receiver_id, $message_text, $file_url, $file_type]);

        // Create notification for receiver
        $notif_id = 'NT' . substr(uniqid(), -8);
        $notif_title = "New Message";
        $notif_msg = substr($message_text, 0, 50) . ($file_url ? " [File Attached]" : "");
        $stmt = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, 'message_new', ?, ?, ?)");
        $stmt->execute([$notif_id, $receiver_id, $notif_title, $notif_msg, $chat_id]);

        echo json_encode(['status' => 'success', 'message_id' => $msg_id, 'file_url' => $file_url]);
    } catch (PDOException $e) {
        $diag = [
            'error' => $e->getMessage(),
            'sender_id' => $sender_id,
            'receiver_id' => $receiver_id,
            'chat_id' => $chat_id,
            'params' => $params
        ];
        echo json_encode(['status' => 'error', 'message' => "SQL Error: " . $e->getMessage() . " | DIAG: " . json_encode($diag)]);
    }
}
?>
