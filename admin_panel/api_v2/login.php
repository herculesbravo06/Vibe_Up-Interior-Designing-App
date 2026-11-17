<?php
// api_v2/login.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$data = json_decode(file_get_contents("php://input"));

if(empty($data->email) || empty($data->password)) {
    echo json_encode(["status" => "error", "message" => "Email and password are required."]);
    exit;
}

$email = $data->email;
$password = $data->password;
$role_check = isset($data->isDesigner) && $data->isDesigner == true ? "role = 'designer'" : "role = 'user'"; 

// Query the unified `user` table (v1 naming)
$stmt = $conn->prepare("SELECT id, name, email, role, profile_pic_url, password_hash, password FROM user WHERE email = :email AND $role_check LIMIT 1");
$stmt->bindParam(':email', $email);
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user && (
    password_verify($password, $user['password_hash']) || // bcrypt match
    $password === $user['password']                       // plain text match
)) {
    // If designer, fetch designer_id (D...)
    $designer_id = null;
    if ($user['role'] === 'designer') {
        $d_stmt = $conn->prepare("SELECT id FROM designer WHERE user_id = ?");
        $d_stmt->execute([$user['id']]);
        $designer_id = $d_stmt->fetchColumn();
    }

    echo json_encode([
        "status" => "success", 
        "message" => "Login successful", 
        "user" => [
            "id" => $user['id'],
            "designer_id" => $designer_id,
            "full_name" => $user['name'],
            "email" => $user['email'],
            "role" => $user['role'],
            "profile_image" => $user['profile_pic_url']
        ]
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid credentials or incorrect role selected."]);
}
?>
