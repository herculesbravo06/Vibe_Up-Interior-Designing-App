<?php
// api_v2/get_layout_suggestions.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$upload_id = $_GET['upload_id'] ?? '';

if(empty($upload_id)) {
    echo json_encode(["status" => "error", "message" => "upload_id is required."]);
    exit;
}

$stmt = $conn->prepare("SELECT id, ai_suggestions, furniture_placement_data FROM layout_recommendations WHERE upload_id = :uid LIMIT 1");
$stmt->bindParam(':uid', $upload_id);
$stmt->execute();
$recommendation = $stmt->fetch(PDO::FETCH_ASSOC);

if($recommendation) {
    echo json_encode([
        "status" => "success",
        "data" => $recommendation
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "No recommendations found for this upload."]);
}
?>
