<?php
// api_v2/upload_room.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$user_id = $_POST['user_id'] ?? '';

if(empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "user_id is required."]);
    exit;
}

if(!isset($_FILES['room_image']) || $_FILES['room_image']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(["status" => "error", "message" => "No room image uploaded or an upload error occurred."]);
    exit;
}

$file_tmp_path = $_FILES['room_image']['tmp_name'];
$file_name = $_FILES['room_image']['name'];
$file_extension = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));

$allowed_extensions = ['jpg', 'jpeg', 'png', 'webp'];
if(!in_array($file_extension, $allowed_extensions)) {
    echo json_encode(["status" => "error", "message" => "Invalid file type. Only JPG, PNG, and WebP are allowed."]);
    exit;
}

// Ensure unique file name
$new_file_name = md5(time() . $file_name) . '.' . $file_extension;
$upload_dir = '../uploads/rooms/';
$dest_path = $upload_dir . $new_file_name;

if(move_uploaded_file($file_tmp_path, $dest_path)) {
    $upload_id = uniqid('UP_');
    $relative_path = 'uploads/rooms/' . $new_file_name;

    $stmt = $conn->prepare("INSERT INTO room_uploads (id, user_id, uploaded_image) VALUES (:id, :uid, :path)");
    $stmt->bindParam(':id', $upload_id);
    $stmt->bindParam(':uid', $user_id);
    $stmt->bindParam(':path', $relative_path);

    if ($stmt->execute()) {
        
        // Auto-stub a layout recommendation for testing
        $rec_id = uniqid('REC_');
        $dummy_suggestions = "Optimized layout generated. Place sofa against the north wall, keep walkways clear.";
        
        $rec_stmt = $conn->prepare("INSERT INTO layout_recommendations (id, upload_id, ai_suggestions) VALUES (:rid, :uid, :sug)");
        $rec_stmt->bindParam(':rid', $rec_id);
        $rec_stmt->bindParam(':uid', $upload_id);
        $rec_stmt->bindParam(':sug', $dummy_suggestions);
        $rec_stmt->execute();

        echo json_encode([
            "status" => "success",
            "message" => "Room uploaded successfully.",
            "upload_id" => $upload_id,
            "image_url" => $relative_path
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Database insertion failed."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Failed to move the uploaded file. Check directory permissions."]);
}
?>
