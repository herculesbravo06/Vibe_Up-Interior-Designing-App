<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();

echo "<h3>Catalogue Categories</h3>";
$cats = $conn->query("SELECT * FROM catalogue_categories")->fetchAll();
foreach($cats as $c) echo $c['name'] . "<br>";

echo "<h3>Catalogue Items (Categories)</h3>";
$items = $conn->query("SELECT DISTINCT category FROM catalogue_items")->fetchAll();
foreach($items as $i) echo ($i['category'] ?: "[Empty]") . "<br>";

echo "<h3>Counts Query Result</h3>";
$counts = $conn->query("SELECT category, COUNT(*) as count FROM catalogue_items GROUP BY category")->fetchAll(PDO::FETCH_KEY_PAIR);
print_r($counts);
?>
