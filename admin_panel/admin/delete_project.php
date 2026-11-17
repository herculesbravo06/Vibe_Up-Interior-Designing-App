<?php
// admin/delete_project.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';

if ($id) {
    $stmt = $conn->prepare("DELETE FROM project WHERE id = :id");
    $stmt->execute(['id' => $id]);
}

header("Location: projects.php");
exit;
