<?php
// admin/delete_designer.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';

if ($id) {
    // We expect the user.id here, which is passed as the designer id in the listing
    // Since designer.user_id cascades from user.id, we delete the user record
    $stmt = $conn->prepare("DELETE FROM user WHERE id = :id AND role = 'designer'");
    $stmt->execute(['id' => $id]);
}

header("Location: designers.php");
exit;
