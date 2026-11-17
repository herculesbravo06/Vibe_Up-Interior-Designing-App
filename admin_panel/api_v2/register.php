<?php
// api_v2/register.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

$data = json_decode(file_get_contents("php://input"));

if(empty($data->full_name) || empty($data->email) || empty($data->password)) {
    echo json_encode(["status" => "error", "message" => "Full name, email, and password are required fields."]);
    exit;
}

$full_name = htmlspecialchars(strip_tags($data->full_name));
$email = htmlspecialchars(strip_tags($data->email));
$phone = isset($data->phone_number) ? htmlspecialchars(strip_tags($data->phone_number)) : '0000000000';
$password = $data->password; // Store plain text in `password` column
$password_hash = password_hash($password, PASSWORD_DEFAULT); // Also store bcrypt in `password_hash`
$role = isset($data->role) && in_array($data->role, ['user', 'designer']) ? $data->role : 'user';

// Check if email already exists in unified `user` table
$check_stmt = $conn->prepare("SELECT id FROM user WHERE email = :email");
$check_stmt->bindParam(':email', $email);
$check_stmt->execute();

if ($check_stmt->rowCount() > 0) {
    echo json_encode(["status" => "error", "message" => "This email is already registered."]);
    exit;
}

// Generate unique ID
$prefix = strtoupper(substr($role, 0, 1)) . '_';
$id = uniqid($prefix);

// Auto-generate username and dob (required by v1 user table schema)
$username = explode('@', $email)[0] . rand(100, 999);
$dob = '2000-01-01'; // Default DOB

$stmt = $conn->prepare("INSERT INTO user (id, name, email, username, password_hash, password, phone, dob, role) VALUES (:id, :name, :email, :username, :hash, :pass, :phone, :dob, :role)");
$stmt->bindParam(':id', $id);
$stmt->bindParam(':name', $full_name);
$stmt->bindParam(':email', $email);
$stmt->bindParam(':username', $username);
$stmt->bindParam(':hash', $password_hash);
$stmt->bindParam(':pass', $password);
$stmt->bindParam(':phone', $phone);
$stmt->bindParam(':dob', $dob);
$stmt->bindParam(':role', $role);

if ($stmt->execute()) {

    // If designer, create a designer profile entry
    if ($role === 'designer') {
        $did = uniqid('D');
        $dstmt = $conn->prepare("INSERT INTO designer (id, user_id) VALUES (:did, :uid)");
        $dstmt->bindParam(':did', $did);
        $dstmt->bindParam(':uid', $id);
        $dstmt->execute();
    }

    echo json_encode([
        "status" => "success",
        "message" => ucfirst($role) . " registered successfully.",
        "user" => [
            "id" => $id,
            "designer_id" => $role === 'designer' ? ($did ?? null) : null,
            "full_name" => $full_name,
            "email" => $email,
            "role" => $role
        ]
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Registration completely failed due to a database error."]);
}
?>
