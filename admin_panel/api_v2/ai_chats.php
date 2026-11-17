<?php
// Copy of ai_chats.php for scratch workspace
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$conn->exec("
    CREATE TABLE IF NOT EXISTS ai_chat_sessions (
        id VARCHAR(50) PRIMARY KEY,
        user_id VARCHAR(50) NOT NULL,
        title VARCHAR(255) DEFAULT 'New Chat',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS ai_chat_messages (
        id VARCHAR(50) PRIMARY KEY,
        session_id VARCHAR(50) NOT NULL,
        role ENUM('user', 'ai') NOT NULL,
        message TEXT,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
        INDEX idx_session (session_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    if ($data) $_POST = array_merge($_POST, $data);
}

$action = $_REQUEST['action'] ?? 'list_sessions';

try {
    switch ($action) {
        case 'create_session':
            $user_id = $_POST['user_id'] ?? null;
            if (!$user_id) { echo json_encode(['status' => 'error', 'message' => 'Missing user_id']); exit; }
            $stmt = $conn->prepare("SELECT user_id FROM designer WHERE id = ? LIMIT 1");
            $stmt->execute([$user_id]); $found = $stmt->fetchColumn();
            if ($found) $user_id = $found;
            $session_id = 'AIC' . substr(uniqid(), -10);
            $title = $_POST['title'] ?? 'New Chat';
            $stmt = $conn->prepare("INSERT INTO ai_chat_sessions (id, user_id, title) VALUES (?, ?, ?)");
            $stmt->execute([$session_id, $user_id, $title]);
            echo json_encode(['status' => 'success', 'session_id' => $session_id]);
            break;
        case 'list_sessions':
            $user_id = $_GET['user_id'] ?? null;
            if (!$user_id) { echo json_encode(['status' => 'error', 'message' => 'Missing user_id']); exit; }
            $stmt = $conn->prepare("SELECT user_id FROM designer WHERE id = ? LIMIT 1");
            $stmt->execute([$user_id]); $found = $stmt->fetchColumn();
            if ($found) $user_id = $found;
            $stmt = $conn->prepare("SELECT s.*, (SELECT COUNT(*) FROM ai_chat_messages WHERE session_id = s.id) as message_count FROM ai_chat_sessions s WHERE s.user_id = ? ORDER BY s.updated_at DESC");
            $stmt->execute([$user_id]);
            echo json_encode(['status' => 'success', 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;
        case 'get_messages':
            $session_id = $_GET['session_id'] ?? null;
            if (!$session_id) { echo json_encode(['status' => 'error', 'message' => 'Missing session_id']); exit; }
            $stmt = $conn->prepare("SELECT * FROM ai_chat_messages WHERE session_id = ? ORDER BY created_at ASC");
            $stmt->execute([$session_id]);
            echo json_encode(['status' => 'success', 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;
        case 'save_message':
            $session_id = $_POST['session_id'] ?? null;
            $role = $_POST['role'] ?? null;
            $message = $_POST['message'] ?? '';
            $image_url = $_POST['image_url'] ?? null;
            if (!$session_id || !$role) { echo json_encode(['status' => 'error', 'message' => 'Missing fields']); exit; }
            $msg_id = 'AIM' . substr(uniqid(), -10);
            $stmt = $conn->prepare("INSERT INTO ai_chat_messages (id, session_id, role, message, image_url) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$msg_id, $session_id, $role, $message, $image_url]);
            $conn->prepare("UPDATE ai_chat_sessions SET updated_at = NOW() WHERE id = ?")->execute([$session_id]);
            if ($role === 'user') {
                $stmt = $conn->prepare("SELECT COUNT(*) FROM ai_chat_messages WHERE session_id = ? AND role = 'user'");
                $stmt->execute([$session_id]);
                if ($stmt->fetchColumn() == 1) {
                    $title = mb_substr($message, 0, 60);
                    if (mb_strlen($message) > 60) $title .= '...';
                    $conn->prepare("UPDATE ai_chat_sessions SET title = ? WHERE id = ?")->execute([$title, $session_id]);
                }
            }
            echo json_encode(['status' => 'success', 'message_id' => $msg_id]);
            break;
        case 'delete_session':
            $session_id = $_POST['session_id'] ?? null;
            if (!$session_id) { echo json_encode(['status' => 'error', 'message' => 'Missing session_id']); exit; }
            $conn->prepare("DELETE FROM ai_chat_sessions WHERE id = ?")->execute([$session_id]);
            echo json_encode(['status' => 'success']);
            break;
        default:
            echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
