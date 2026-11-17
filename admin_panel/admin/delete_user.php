<?php
// admin/delete_user.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';

if ($id && $id !== 'U90001') { // Protect main admin
    try {
        $stmt = $conn->prepare("DELETE FROM user WHERE id = :id");
        $stmt->execute(['id' => $id]);
    } catch (Exception $e) {
        // Log error or set session message
    }
}

header("Location: users.php");
exit;
