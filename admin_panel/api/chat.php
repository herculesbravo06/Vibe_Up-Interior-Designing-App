<?php
// api/chat.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");

require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? null;

if ($method == 'GET') {
    // 1. Fetch Conversations
    if ($action == 'conversations') {
        $user_id = $_GET['user_id'] ?? null;
        if (!$user_id) {
            echo json_encode(["status" => "error", "message" => "User ID required."]);
            exit;
        }

        // Get chats where user is either user1 or user2
        $stmt = $conn->prepare("
            SELECT c.id, 
                   u.name as recipient_name, 
                   u.profile_pic_url as recipient_pic,
                   u.id as recipient_id,
                   (SELECT message_text FROM messages m WHERE m.chat_id = c.id ORDER BY m.timestamp DESC LIMIT 1) as last_message,
                   (SELECT timestamp FROM messages m WHERE m.chat_id = c.id ORDER BY m.timestamp DESC LIMIT 1) as last_time
            FROM chats c
            JOIN user u ON (c.user1_id = :uid AND c.user2_id = u.id) OR (c.user2_id = :uid AND c.user1_id = u.id)
            WHERE c.user1_id = :uid OR c.user2_id = :uid
            ORDER BY last_time DESC
        ");
        $stmt->bindParam(":uid", $user_id);
        $stmt->execute();
        $chats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(["status" => "success", "data" => $chats]);
    }
    // 2. Fetch Messages
    elseif ($action == 'messages') {
        $chat_id = $_GET['chat_id'] ?? null;
        if (!$chat_id) {
            echo json_encode(["status" => "error", "message" => "Chat ID required."]);
            exit;
        }

        $stmt = $conn->prepare("SELECT * FROM messages WHERE chat_id = :cid ORDER BY timestamp ASC");
        $stmt->bindParam(":cid", $chat_id);
        $stmt->execute();
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(["status" => "success", "data" => $messages]);
    }
} elseif ($method == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    $action = $data->action ?? null;

    if ($action == 'send') {
        if (empty($data->chat_id) || empty($data->sender_id) || empty($data->message_text)) {
            echo json_encode(["status" => "error", "message" => "chat_id, sender_id and message_text are required."]);
            exit;
        }

        $chat_id = $data->chat_id;
        $sender_id = $data->sender_id;
        $message_text = $data->message_text;

        // Resolve receiver_id from chat
        $stmt_c = $conn->prepare("SELECT user1_id, user2_id FROM chats WHERE id = ?");
        $stmt_c->execute([$chat_id]);
        $chat = $stmt_c->fetch();
        
        if (!$chat) {
            echo json_encode(["status" => "error", "message" => "Chat not found."]);
            exit;
        }

        $receiver_id = ($chat['user1_id'] === $sender_id) ? $chat['user2_id'] : $chat['user1_id'];
        $id = 'MSG' . substr(uniqid(), -8);

        $stmt = $conn->prepare("INSERT INTO messages (id, chat_id, sender_id, receiver_id, message_text) VALUES (:id, :cid, :sid, :rid, :txt)");
        $stmt->execute([
            ':id' => $id,
            ':cid' => $chat_id,
            ':sid' => $sender_id,
            ':rid' => $receiver_id,
            ':txt' => $message_text
        ]);

        // Push notification
        $n_id = 'NT' . substr(uniqid(), -8);
        $stmt_n = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, 'message_new', 'New Message', ?, ?)");
        $stmt_n->execute([$n_id, $receiver_id, $message_text, $chat_id]);

        echo json_encode(["status" => "success", "message" => "Message sent."]);
    }
}
?>
