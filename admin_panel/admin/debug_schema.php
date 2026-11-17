<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();
$stmt = $conn->query("DESCRIBE catalogue_items");
echo "<pre>";
print_r($stmt->fetchAll());
echo "</pre>";

$stmt2 = $conn->query("DESCRIBE catalogue_categories");
echo "<h3>Categories</h3><pre>";
print_r($stmt2->fetchAll());
echo "</pre>";
?>
