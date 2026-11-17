<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();

$tables = ['catalogue_items', 'project', 'user', 'designer', 'feedback', 'messages', 'ai_prompts'];

echo "<pre>";
foreach($tables as $table) {
    try {
        $stmt = $conn->query("DESCRIBE $table");
        echo "<h3>Table: $table</h3>";
        print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
    } catch (Exception $e) {
        echo "Error on $table: " . $e->getMessage() . "<br>";
    }
}
echo "</pre>";
?>
