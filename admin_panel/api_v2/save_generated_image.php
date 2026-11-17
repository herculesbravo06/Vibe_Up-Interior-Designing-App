<?php
// api_v2/save_generated_image.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$data = json_decode(file_get_contents("php://input"));

if(empty($data->request_id) || empty($data->image_url)) {
    echo json_encode(["status" => "error", "message" => "request_id and image_url are required."]);
    exit;
}

$image_id = uniqid('IMG_');
$request_id = $data->request_id;
$image_url = $data->image_url;
$prompt_used = $data->prompt_used ?? '';
$variation = $data->variation_number ?? 1;

$stmt = $conn->prepare("INSERT INTO generated_images (id, request_id, image_url, prompt_used, variation_number) VALUES (:id, :req, :url, :prompt, :var)");
$stmt->bindParam(':id', $image_id);
$stmt->bindParam(':req', $request_id);
$stmt->bindParam(':url', $image_url);
$stmt->bindParam(':prompt', $prompt_used);
$stmt->bindParam(':var', $variation);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Generated image saved successfully.",
        "image_id" => $image_id
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Database insert failed."]);
}
?>
