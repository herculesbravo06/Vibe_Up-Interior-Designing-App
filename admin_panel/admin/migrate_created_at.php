<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();
try {
    $conn->exec("ALTER TABLE catalogue_items ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
    echo "Column created_at added to catalogue_items successfully.";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
