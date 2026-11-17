<?php
// admin_panel/api/heartbeat.php
// Updates user's last_activity to show them as "Online" in the Admin Panel

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once '../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id)) {
    $db = new Database();
    $conn = $db->getConnection();

    try {
        $stmt = $conn->prepare("UPDATE user SET last_activity = NOW() WHERE id = :user_id");
        $stmt->bindParam(':user_id', $data->user_id);
        
        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Heartbeat received']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to update activity']);
        }
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing user_id']);
}
?>
