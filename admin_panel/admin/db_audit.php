<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();

$stmt = $conn->query("SHOW TABLES");
$tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo "Tables in vibe_up: " . implode(", ", $tables);
?>
