<?php
// admin/migrations/add_scene_data.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

try {
    // Check if column exists
    $stmt = $conn->query("SHOW COLUMNS FROM room LIKE 'scene_data'");
    $exists = $stmt->fetch();

    if (!$exists) {
        $conn->exec("ALTER TABLE room ADD COLUMN scene_data LONGTEXT DEFAULT NULL AFTER height_m");
        echo "Successfully added 'scene_data' column to 'room' table.";
    } else {
        echo "Column 'scene_data' already exists.";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
