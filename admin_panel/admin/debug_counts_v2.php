<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();

echo "Raw Channels Check:<br>";
$cats = $conn->query("SELECT id, name FROM catalogue_categories")->fetchAll();
var_dump($cats);

echo "<br>Raw Items Check:<br>";
$items = $conn->query("SELECT id, name, category FROM catalogue_items LIMIT 5")->fetchAll();
var_dump($items);

echo "<br>Counts PAIR Check:<br>";
$counts = $conn->query("SELECT category, COUNT(*) as count FROM catalogue_items GROUP BY category")->fetchAll(PDO::FETCH_KEY_PAIR);
var_dump($counts);
?>
