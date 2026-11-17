<?php
// api/catalogue.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$action = $_GET['action'] ?? 'items'; // default to listing items

// Fetch categories dynamically from catalogue items
if ($action == 'categories') {
    $stmt = $conn->query("SELECT DISTINCT category as name FROM catalogue_items WHERE category IS NOT NULL AND category != ''");
    $categories = $stmt->fetchAll();
    echo json_encode(["status" => "success", "data" => $categories]);
} elseif ($action == 'sync') {
    // 1. Fetch Categories
    $catStmt = $conn->query("SELECT * FROM catalogue_categories ORDER BY id ASC");
    $categories = $catStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 2. Fetch All Items
    $itemStmt = $conn->query("SELECT * FROM catalogue_items ORDER BY id ASC");
    $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
    
    $base_url = "http://" . $_SERVER['HTTP_HOST'] . "/scratch/admin_panel/";

    // 3. Process Items into Category Buckets
    $categoryMap = [];
    foreach($items as $item) {
        $catName = $item['category'];
        if(!isset($categoryMap[$catName])) {
            $categoryMap[$catName] = [];
        }
        
        // Finalize item for frontend
        $item['images'] = json_decode($item['images'], true);
        if(is_array($item['images'])) {
            foreach($item['images'] as &$img) {
                if(strpos($img, 'http') !== 0) $img = $base_url . $img;
            }
        }
        $categoryMap[$catName][] = $item;
    }

    // 4. Organize into the Nested "User App" Structure
    // (Defining Construction, Interior, Exterior as major folders)
    $majorGroups = [
        "Construction" => ["Rooms (Construction)", "Walls & Partitions", "Doors & Openings", "Windows", "Stairs & Columns"],
        "Interior" => ["Living Room", "Bedroom", "Kitchen", "Dining Room", "Bathroom", "Office", "Kids Room", "Gym & Hobby"],
        "Exterior" => ["Plants & Trees", "Garden Furniture", "Pool & Water", "Structures & Lighting"]
    ];

    $finalSync = [];
    foreach($majorGroups as $majorTitle => $subs) {
        $group = ["title" => $majorTitle, "sub" => []];
        foreach($subs as $subName) {
            if(isset($categoryMap[$subName])) {
                $group["sub"][] = [
                    "name" => $subName,
                    "items" => $categoryMap[$subName]
                ];
            }
        }
        if(!empty($group["sub"])) {
            $finalSync[] = $group;
        }
    }

    echo json_encode(["status" => "success", "data" => $finalSync]);
} elseif ($action == 'items') {
    $category = $_GET['category'] ?? '';
    $query = "SELECT * FROM catalogue_items";
    if (!empty($category)) {
        $query .= " WHERE category = :cat";
    }
    $query .= " ORDER BY id ASC";
    
    $stmt = $conn->prepare($query);
    if (!empty($category)) {
        $stmt->bindParam(':cat', $category);
    }
    $stmt->execute();
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Process images
    $base_url = "http://" . $_SERVER['HTTP_HOST'] . "/scratch/admin_panel/";
    foreach($items as &$item) {
        $item['images'] = json_decode($item['images'], true);
        if(is_array($item['images'])) {
            foreach($item['images'] as &$img) {
                if(strpos($img, 'http') !== 0) $img = $base_url . $img;
            }
        } else {
            $item['images'] = [];
        }
    }
    
    echo json_encode(["status" => "success", "data" => $items]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid action."]);
}
?>
