<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$action = $_REQUEST['action'] ?? 'list';

// Handle JSON input for POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    if ($data) {
        $_POST = array_merge($_POST, $data);
        if (isset($data['action']))
            $action = $data['action'];
    }
}

try {
    switch ($action) {
        case 'create':
            $user_id = $_POST['user_id'] ?? '';
            $designer_id = $_POST['designer_id'] ?? '';
            $project_name = $_POST['project_name'] ?? '';
            $description = $_POST['project_description'] ?? '';

            if (!$user_id || !$designer_id) {
                throw new Exception("Missing user or designer ID");
            }

            // Robust resolution: Find designer entry by either its own ID or the user ID
            $stmt = $conn->prepare("SELECT id FROM designer WHERE id = ? OR user_id = ? LIMIT 1");
            $stmt->execute([$designer_id, $designer_id]);
            $real_designer_id = $stmt->fetchColumn();
            if ($real_designer_id) {
                $designer_id = $real_designer_id;
            }

            $conn->beginTransaction();

            $proj_id = $_POST['project_id'] ?? '';

            if (!$proj_id) {
                // 1. Create Project if not exists
                $proj_id = 'P' . substr(uniqid(), -8);
                $stmt = $conn->prepare("INSERT INTO project (id, user_id, name, description, status) VALUES (?, ?, ?, ?, 'draft')");
                $stmt->execute([$proj_id, $user_id, $project_name, $description]);
            }

            // 2. Create Designer Request
            $req_id = 'DR' . substr(uniqid(), -8);
            $stmt = $conn->prepare("INSERT INTO designer_request (id, user_id, designer_id, project_id, status) VALUES (?, ?, ?, ?, 'pending')");
            $stmt->execute([$req_id, $user_id, $designer_id, $proj_id]);

            // 3. Notify Designer
            $notif_id_d = 'NT' . substr(uniqid(), -8);
            $stmt = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, ?, ?, ?, ?)");

            // Get user_id of designer for notification
            $stmt_d = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
            $stmt_d->execute([$designer_id]);
            $designer_user_id = $stmt_d->fetchColumn();

            $stmt->execute([$notif_id_d, $designer_user_id, 'request_new', "New Design Request", "You have a new request for project: $project_name", $req_id]);

            // 3b. Notify Client (Confirmation)
            $notif_id_c = 'NT' . substr(uniqid(), -8);
            $stmt->execute([$notif_id_c, $user_id, 'request_new', "Project Created", "Successfully created project '$project_name' and sent to designer.", $proj_id]);

            // 4. Log Activity
            $log_id = 'LOG' . substr(uniqid(), -8);
            $stmt = $conn->prepare("INSERT INTO activity_logs (id, actor_id, action, entity_type, entity_id, details) VALUES (?, ?, 'creation', 'designer_request', ?, ?)");
            $stmt->execute([$log_id, $user_id, $req_id, "Created request for $project_name"]);

            $conn->commit();
            echo json_encode(['status' => 'success', 'request_id' => $req_id, 'project_id' => $proj_id]);
            break;

        case 'update_status':
            $req_id = $_POST['request_id'] ?? '';
            $status = $_POST['status'] ?? $_POST['new_status'] ?? ''; // Handle both names

            if (!$req_id || !$status) {
                throw new Exception("Missing request ID or status");
            }

            $conn->beginTransaction();

            $stmt = $conn->prepare("UPDATE designer_request SET status = ? WHERE id = ?");
            $stmt->execute([$status, $req_id]);

            // Get user_id and designer_id for intro message
            $stmt = $conn->prepare("SELECT user_id, designer_id, project_id FROM designer_request WHERE id = ?");
            $stmt->execute([$req_id]);
            $req = $stmt->fetch();

            if ($status === 'accepted') {
                // Get project name
                $stmt = $conn->prepare("SELECT name FROM project WHERE id = ?");
                $stmt->execute([$req['project_id']]);
                $pname = $stmt->fetchColumn();

                // Intro message logic
                $chat_id = 'CH' . substr(uniqid(), -8);

                // Get designer's user_id and name
                $stmt_d = $conn->prepare("SELECT d.user_id, u.name FROM designer d JOIN user u ON d.user_id = u.id WHERE d.id = ?");
                $stmt_d->execute([$req['designer_id']]);
                $designer_info = $stmt_d->fetch();
                $designer_user_id = $designer_info['user_id'];
                $designer_name = $designer_info['name'];

                // Check if chat exists
                $stmt = $conn->prepare("SELECT id FROM chats WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)");
                $stmt->execute([$designer_user_id, $req['user_id'], $req['user_id'], $designer_user_id]);
                $existing_chat = $stmt->fetchColumn();

                if (!$existing_chat) {
                    $stmt = $conn->prepare("INSERT INTO chats (id, user1_id, user2_id) VALUES (?, ?, ?)");
                    $stmt->execute([$chat_id, $designer_user_id, $req['user_id']]);
                }
                else {
                    $chat_id = $existing_chat;
                }

                $msg_text = "hi my name is $designer_name how can i help you in designing";
                $msg_id = 'MSG' . substr(uniqid(), -8);
                $stmt = $conn->prepare("INSERT INTO messages (id, chat_id, sender_id, receiver_id, message_text) VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([$msg_id, $chat_id, $designer_user_id, $req['user_id'], $msg_text]);

                // Assign designer to the project and mark as in_progress
                $stmt = $conn->prepare("UPDATE project SET designer_id = ?, assigned_at = NOW(), status = 'in_progress' WHERE id = ?");
                $stmt->execute([$req['designer_id'], $req['project_id']]);
            }

            // Notification for user
            $notif_id = 'NT' . substr(uniqid(), -8);
            $type = $status === 'accepted' ? 'request_accepted' : 'request_declined';
            $stmt = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, ?, 'Request Update', ?, ?)");
            $stmt->execute([$notif_id, $req['user_id'], $type, "Your request has been " . $status, $req_id]);

            // Log Activity
            $log_id = 'LOG' . substr(uniqid(), -8);
            $stmt = $conn->prepare("INSERT INTO activity_logs (id, actor_id, action, entity_type, entity_id, details) VALUES (?, ?, 'status_update', 'designer_request', ?, ?)");
            $stmt->execute([$log_id, $designer_user_id, $req_id, "Updated status to $status"]);

            $conn->commit();
            echo json_encode(['status' => 'success']);
            break;

        case 'list':
            $designer_id = $_GET['designer_id'] ?? null;
            $user_id = $_GET['user_id'] ?? null;
            $status_filter = $_GET['status'] ?? null;

            if ($designer_id) {
                // Robust resolution: Find designer entry by either its own ID or the user ID
                $stmt = $conn->prepare("SELECT id FROM designer WHERE id = ? OR user_id = ? LIMIT 1");
                $stmt->execute([$designer_id, $designer_id]);
                $real_id = $stmt->fetchColumn();
                if ($real_id)
                    $designer_id = $real_id;

                $sql = "SELECT r.*, u.name as user_name, p.name as project_name, p.description as project_description 
                        FROM designer_request r 
                        JOIN user u ON r.user_id = u.id 
                        JOIN project p ON r.project_id = p.id 
                        WHERE r.designer_id = ?";
                $params = [$designer_id];

                if ($status_filter) {
                    $sql .= " AND r.status = ?";
                    $params[] = $status_filter;
                }
                $sql .= " ORDER BY r.created_at DESC";

                $stmt = $conn->prepare($sql);
                $stmt->execute($params);
            }
            else if ($user_id) {
                $sql = "SELECT r.*, du.name as designer_name, du.id as designer_user_id, p.name as project_name, p.description as project_description 
                        FROM designer_request r 
                        JOIN project p ON r.project_id = p.id 
                        JOIN designer d ON r.designer_id = d.id
                        JOIN user du ON d.user_id = du.id
                        WHERE r.user_id = ?";
                $params = [$user_id];

                if ($status_filter) {
                    $sql .= " AND r.status = ?";
                    $params[] = $status_filter;
                }
                $sql .= " ORDER BY r.created_at DESC";

                // Debug logging
                file_put_contents('../uploads/debug_log.txt', date('[Y-m-d H:i:s] ') . "LIST USER SQL: $sql | PARAMS: " . json_encode($params) . "\n", FILE_APPEND);

                $stmt = $conn->prepare($sql);
                $stmt->execute($params);
            }
            else {
                $sql = "SELECT r.*, u.name as user_name, du.name as designer_name, du.id as designer_user_id, p.name as project_name 
                        FROM designer_request r 
                        JOIN user u ON r.user_id = u.id 
                        JOIN designer d ON r.designer_id = d.id
                        JOIN user du ON d.user_id = du.id
                        JOIN project p ON r.project_id = p.id";
                $params = [];

                if ($status_filter) {
                    $sql .= " WHERE r.status = ?";
                    $params[] = $status_filter;
                }
                $sql .= " ORDER BY r.created_at DESC";

                if (!empty($params)) {
                    $stmt = $conn->prepare($sql);
                    $stmt->execute($params);
                }
                else {
                    $stmt = $conn->query($sql);
                }
            }
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (!empty($data)) {
                file_put_contents('../uploads/debug_log.txt', "RESULT ROW 0: " . json_encode($data[0]) . "\n", FILE_APPEND);
            }
            echo json_encode(['status' => 'success', 'data' => $data]);
            break;
    }
}
catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction())
        $conn->rollBack();
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
