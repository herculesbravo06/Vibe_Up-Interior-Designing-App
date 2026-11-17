<?php
// admin/delete_catalogue.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';

if ($id) {
    try {
        $stmt = $conn->prepare("DELETE FROM catalogue_items WHERE id = :id");
        $stmt->execute(['id' => $id]);
    } catch (Exception $e) { }
}

header("Location: catalogue.php");
exit;
