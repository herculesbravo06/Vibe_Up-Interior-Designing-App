<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();
try {
    $stmt = $conn->query("DESCRIBE designer_request");
    echo "<h3>Table: designer_request</h3><pre>";
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
    echo "</pre>";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
