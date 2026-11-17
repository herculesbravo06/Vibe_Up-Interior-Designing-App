<?php
require_once 'C:/Xampp1/htdocs/vibe_up/config/database.php';
$db = new Database();
$conn = $db->getConnection();

$sql = "CREATE TABLE IF NOT EXISTS catalogue_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
$conn->exec($sql);

$sql2 = "INSERT IGNORE INTO catalogue_categories (name, image_url) VALUES 
('Sofa', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc'),
('Table', 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88'),
('Bed', 'https://images.unsplash.com/photo-1505693415918-91e51bdd219b'),
('Lighting', 'https://images.unsplash.com/photo-1542728929-14a3ccd60698'),
('Decor', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38')";
$conn->exec($sql2);

echo "Table created and populated.";
?>
