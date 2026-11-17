<?php
// api_v2/fetch_designs.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$user_id = $_GET['user_id'] ?? '';

if(empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "user_id is required as a query parameter."]);
    exit;
}

$stmt = $conn->prepare("SELECT id, original_prompt, selected_style, timestamp FROM design_requests WHERE user_id = :uid ORDER BY timestamp DESC");
$stmt->bindParam(':uid', $user_id);
$stmt->execute();
$requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

$results = [];

// Embed the generated images inside each request
foreach($requests as $req) {
    $img_stmt = $conn->prepare("SELECT image_url, variation_number FROM generated_images WHERE request_id = :reqid");
    $img_stmt->bindParam(':reqid', $req['id']);
    $img_stmt->execute();
    $images = $img_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $req['images'] = $images;
    $results[] = $req;
}

echo json_encode([
    "status" => "success",
    "data" => $results
]);
?>
