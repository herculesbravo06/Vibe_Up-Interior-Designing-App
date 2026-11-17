<?php
// api/feedback.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");

require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (empty($data->type) || empty($data->rating)) {
        echo json_encode(["status" => "error", "message" => "Feedback type and rating required."]);
        exit;
    }
    
    $user_id = $data->user_id ?? null;
    $rating = (int) $data->rating;
    $comment = $data->comment ?? '';
    
    $id = uniqid('F');
    if ($data->type == 'app') {
        $stmt = $conn->prepare("INSERT INTO feedback (id, from_user_id, to_user_id, rating, comment) VALUES (:id, :uid, NULL, :rating, :comment)");
        $stmt->bindParam(":id", $id);
        $stmt->bindParam(":uid", $user_id);
        $stmt->bindParam(":rating", $rating);
        $stmt->bindParam(":comment", $comment);
    } elseif ($data->type == 'designer') {
        if (empty($data->designer_id)) {
            echo json_encode(["status" => "error", "message" => "Designer ID required for designer feedback."]);
            exit;
        }
        $to_user_id = $data->designer_id;
        // Resolve D... to U... if necessary
        if (strpos($to_user_id, 'D') === 0) {
            $stmt_resolve = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
            $stmt_resolve->execute([$to_user_id]);
            $resolved_uid = $stmt_resolve->fetchColumn();
            if ($resolved_uid) $to_user_id = $resolved_uid;
        }

        $stmt = $conn->prepare("INSERT INTO feedback (id, from_user_id, to_user_id, rating, comment) VALUES (:id, :uid, :did, :rating, :comment)");
        $stmt->bindParam(":id", $id);
        $stmt->bindParam(":uid", $user_id);
        $stmt->bindParam(":did", $to_user_id);
        $stmt->bindParam(":rating", $rating);
        $stmt->bindParam(":comment", $comment);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid feedback type."]);
        exit;
    }
    
    if ($stmt->execute()) {
        // Notification logic
        try {
            if ($data->type == 'designer') {
                // Notify Designer
                $notif_id_d = 'NT' . substr(uniqid(), -8);
                $stmt_n = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, 'admin_update', 'New Feedback Received', ?, ?)");
                $stmt_n->execute([$notif_id_d, $to_user_id, "You have received a new $rating-star rating for your work.", $id]);
                
                // Notify Client (Confirmation)
                if ($user_id) {
                    $notif_id_c = 'NT' . substr(uniqid(), -8);
                    $stmt_n->execute([$notif_id_c, $user_id, 'admin_update', 'Feedback Submitted', "Thank you for your feedback! It helps our designers improve.", $id]);
                }
            } else if ($data->type == 'app' && $user_id) {
                // Notify Client for App Feedback
                $notif_id_c = 'NT' . substr(uniqid(), -8);
                $stmt_n = $conn->prepare("INSERT INTO notifications (id, user_id, type, title, message, reference_id) VALUES (?, ?, 'admin_update', 'Feedback Received', 'Thank you for your app feedback!', ?)");
                $stmt_n->execute([$notif_id_c, $user_id, $id]);
            }
        } catch (Exception $e) {
            // Log error but don't fail the feedback submission
            error_log("Notification error: " . $e->getMessage());
        }

        echo json_encode(["status" => "success", "message" => "Feedback submitted successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to submit feedback."]);
    }
} elseif ($method == 'GET') {
    // For designers, fetching their reviews
    if (isset($_GET['designer_id'])) {
        $did = $_GET['designer_id'];
        
        // Resolve D... to U... if necessary
        if (strpos($did, 'D') === 0) {
            $stmt_resolve = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
            $stmt_resolve->execute([$did]);
            $resolved_uid = $stmt_resolve->fetchColumn();
            if ($resolved_uid) $did = $resolved_uid;
        }

        $stmt = $conn->prepare("
            SELECT f.*, u.name as user_name 
            FROM feedback f 
            JOIN user u ON f.from_user_id = u.id 
            WHERE f.to_user_id = :did 
            ORDER BY f.created_at DESC
        ");
        $stmt->bindParam(":did", $did);
        $stmt->execute();
        $feedbacks = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["status" => "success", "data" => $feedbacks]);
    } else {
        echo json_encode(["status" => "error", "message" => "Designer ID required."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Unsupported method."]);
}
?>
