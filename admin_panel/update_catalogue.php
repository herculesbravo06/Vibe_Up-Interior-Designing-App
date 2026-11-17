<?php
// admin_panel/update_catalogue.php
// This script synchronizes the Admin DB with the FULL Flutter app dataset (CatalogData.dart)

require_once 'config/database.php';

$db = new Database();
$conn = $db->getConnection();

if (!$conn) {
    die("Database connection failed.");
}

try {
    // 0. Self-Healing Schema Migration
    $checkCol = $conn->query("SHOW COLUMNS FROM room LIKE 'scene_data'")->fetch();
    if (!$checkCol) {
        $conn->exec("ALTER TABLE room ADD COLUMN scene_data LONGTEXT DEFAULT NULL AFTER height_m");
    }

    $conn->beginTransaction();

    // 1. Clear old data
    $conn->exec("SET FOREIGN_KEY_CHECKS = 0;");
    $conn->exec("DELETE FROM catalogue_items;");
    $conn->exec("DELETE FROM catalogue_categories;");

    // 2. Categories with Premium Unsplash Images
    $catData = [
        ['c_rooms', 'Rooms (Construction)', 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800'],
        ['c_walls', 'Walls & Partitions', 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800'],
        ['c_doors', 'Doors & Openings', 'https://images.unsplash.com/photo-1515516089376-88db1e26e9c0?w=800'],
        ['c_windows', 'Windows', 'https://images.unsplash.com/photo-1503708928676-1cb796a0891e?w=800'],
        ['c_stairs', 'Stairs & Columns', 'https://images.unsplash.com/photo-1560185127-6a9578161191?w=800'],
        ['i_living', 'Living Room', 'https://images.unsplash.com/photo-1554995207-c18c20360a59?w=800'],
        ['i_bedroom', 'Bedroom', 'https://images.unsplash.com/photo-1505693415918-91e51bdd219b?w=800'],
        ['i_kitchen', 'Kitchen', 'https://images.unsplash.com/photo-1556911220-e15224bbaf47?w=800'],
        ['i_dining', 'Dining Room', 'https://images.unsplash.com/photo-1617806118233-f8e187f42894?w=800'],
        ['i_bath', 'Bathroom', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800'],
        ['i_office', 'Office', 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800'],
        ['i_kids', 'Kids Room', 'https://images.unsplash.com/photo-1560412852-d61d80b06a3d?w=800'],
        ['i_hobby', 'Gym & Hobby', 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800'],
        ['e_plants', 'Plants & Trees', 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800'],
        ['e_garden', 'Garden Furniture', 'https://images.unsplash.com/photo-1567016376408-0226e4d0c1ea?w=800'],
        ['e_pool', 'Pool & Water', 'https://images.unsplash.com/photo-1562678666-608f977870ca?w=800'],
        ['e_structures', 'Structures & Lighting', 'https://images.unsplash.com/photo-1542728929-14a3ccd60698?w=800']
    ];

    $catStmt = $conn->prepare("INSERT INTO catalogue_categories (id, name, image_url) VALUES (?, ?, ?)");
    foreach ($catData as $cat) { $catStmt->execute($cat); }

    // 3. FULL ITEM LIST (Extracted from CatalogData.dart)
    $items = [
        // CONSTRUCTION
        ['c1', 'Square Room', 'Rooms (Construction)', 15000, 'Concrete'],
        ['c2', 'L-Shaped Room', 'Rooms (Construction)', 22000, 'Concrete'],
        ['c3', 'T-Shaped Room', 'Rooms (Construction)', 25000, 'Concrete'],
        ['c4', 'Circular Room', 'Rooms (Construction)', 35000, 'Concrete'],
        ['c5', 'Custom Studio', 'Rooms (Construction)', 45000, 'Concrete'],
        ['c6', 'Duplex Space', 'Rooms (Construction)', 85000, 'Concrete'],
        ['c7', 'Basement', 'Rooms (Construction)', 30000, 'Concrete'],

        ['w1', 'Standard Wall', 'Walls & Partitions', 1200, 'Plaster'],
        ['w2', 'Glass Wall', 'Walls & Partitions', 8500, 'Tempered Glass'],
        ['w3', 'Brick Wall', 'Walls & Partitions', 3200, 'Red Brick'],
        ['w4', 'Wooden Panel', 'Walls & Partitions', 4500, 'Oak'],
        ['w5', 'Half Wall', 'Walls & Partitions', 1000, 'Concrete'],
        ['w6', 'Acoustic Panel', 'Walls & Partitions', 6000, 'Foam'],

        ['d1', 'Single Oak Door', 'Doors & Openings', 12000, 'Oak Wood'],
        ['d2', 'Sliding Glass Door', 'Doors & Openings', 25000, 'Glass'],
        ['d3', 'Double Entry Door', 'Doors & Openings', 45000, 'Mahogany'],
        ['d4', 'Arcade Opening', 'Doors & Openings', 5000, 'Drywall'],
        ['d5', 'Garage Roller', 'Doors & Openings', 65000, 'Steel'],
        ['d6', 'Barn Door', 'Doors & Openings', 18000, 'Pine'],
        ['d7', 'Bifold Door', 'Doors & Openings', 22000, 'Aluminum'],

        ['win1', 'Standard Window', 'Windows', 4500, 'Glass'],
        ['win2', 'Bay Window', 'Windows', 18000, 'Glass'],
        ['win3', 'Panoramic Wall', 'Windows', 55000, 'Glass'],
        ['win4', 'Skylight', 'Windows', 28000, 'Glass'],
        ['win5', 'Awning Window', 'Windows', 6000, 'Glass'],
        ['win6', 'Stained Glass', 'Windows', 35000, 'Artistic Glass'],

        ['st1', 'Straight Stairs', 'Stairs & Columns', 45000, 'Wood/Steel'],
        ['st2', 'Spiral Stairs', 'Stairs & Columns', 120000, 'Wrought Iron'],
        ['st3', 'Roman Column', 'Stairs & Columns', 15000, 'Marble'],
        ['st4', 'Modern Steel Pillar', 'Stairs & Columns', 22000, 'Stainless Steel'],
        ['st5', 'Floating Steps', 'Stairs & Columns', 85000, 'Oak & Glass'],

        // INTERIOR
        ['lr1', 'Corner Sofa', 'Living Room', 65000, 'Fabric'],
        ['lr2', 'Leather Armchair', 'Living Room', 28000, 'Leather'],
        ['lr3', 'Minimalist TV Unit', 'Living Room', 15000, 'MDF'],
        ['lr4', 'Marble Coffee Table', 'Living Room', 12000, 'Marble'],
        ['lr5', 'Modern Bookshelf', 'Living Room', 18000, 'Plywood'],
        ['lr6', 'Sectional Couch', 'Living Room', 95000, 'Velvet'],
        ['lr7', 'Recliner', 'Living Room', 35000, 'Leather'],
        ['lr8', 'Nest of Tables', 'Living Room', 8000, 'Walnut'],

        ['br1', 'King Sized Bed', 'Bedroom', 45000, 'Teak'],
        ['br2', 'Double Wardrobe', 'Bedroom', 35000, 'Engineered Wood'],
        ['br3', 'Glass Nightstand', 'Bedroom', 6000, 'Glass'],
        ['br4', 'Makeup Vanity', 'Bedroom', 12000, 'MDF'],
        ['br5', 'Queen Size Bed', 'Bedroom', 35000, 'Wood'],
        ['br6', 'Floor Mirror', 'Bedroom', 4500, 'Mirrored Glass'],
        ['br7', 'Chest of Drawers', 'Bedroom', 15000, 'Pine'],

        ['kt1', 'Marble Island', 'Kitchen', 85000, 'Marble'],
        ['kt2', 'Cabinet Set', 'Kitchen', 150000, 'Laminate'],
        ['kt3', 'Smart Fridge', 'Kitchen', 95000, 'Steel'],
        ['kt4', 'Industrial Oven', 'Kitchen', 45000, 'Steel'],
        ['kt5', 'Bar Stool', 'Kitchen', 3500, 'Steel & Wood'],
        ['kt6', 'Microwave', 'Kitchen', 12000, 'Plastic/Metal'],
        ['kt7', 'Dishwasher', 'Kitchen', 38000, 'Steel'],

        ['dr1', 'Oak Dining Table', 'Dining Room', 42000, 'Oak'],
        ['dr2', 'Velvet Dining Chair', 'Dining Room', 6500, 'Velvet'],
        ['dr3', 'Modern Sideboard', 'Dining Room', 22000, 'Wood'],
        ['dr4', 'Designer Wine Rack', 'Dining Room', 15000, 'Metal'],
        ['dr5', 'Round Glass Table', 'Dining Room', 28000, 'Glass'],

        ['bt1', 'Freestanding Bathtub', 'Bathroom', 75000, 'Acrylic'],
        ['bt2', 'Walk-in Shower', 'Bathroom', 45000, 'Glass'],
        ['bt3', 'Double Vanity', 'Bathroom', 32000, 'Marble'],
        ['bt4', 'Smart Toilet', 'Bathroom', 55000, 'Ceramic'],
        ['bt5', 'Towel Warmer', 'Bathroom', 8500, 'Chrome'],

        ['of1', 'Ergonomic Desk', 'Office', 22000, 'Steel/Laminate'],
        ['of2', 'Executive Chair', 'Office', 18000, 'Mesh/Leather'],
        ['of3', 'Modern Filing Cabinet', 'Office', 12000, 'Steel'],
        ['of4', 'Desk Lamp', 'Office', 3500, 'Metal'],
        ['of5', 'Stationery Rack', 'Office', 1500, 'Plastic'],

        ['kd1', 'Bunk Bed', 'Kids Room', 55000, 'Pine'],
        ['kd2', 'Study Table', 'Kids Room', 8500, 'Particle Board'],
        ['kd3', 'Toy Storage', 'Kids Room', 12000, 'Plastic'],
        ['kd4', 'Bean Bag', 'Kids Room', 2500, 'Fabric'],

        ['gm1', 'Treadmill', 'Gym & Hobby', 45000, 'Metal/Rubber'],
        ['gm2', 'Yoga Mat Set', 'Gym & Hobby', 2500, 'Rubber'],
        ['gm3', 'Dumbbell Rack', 'Gym & Hobby', 15000, 'Steel'],
        ['gm4', 'Gaming Chair', 'Gym & Hobby', 14000, 'Leatherette'],

        // EXTERIOR
        ['pt1', 'Maple Tree', 'Plants & Trees', 2500, 'Organic'],
        ['pt2', 'Boxwood Bush', 'Plants & Trees', 800, 'Organic'],
        ['pt3', 'Rose Garden Bed', 'Plants & Trees', 4500, 'Organic'],
        ['pt4', 'Date Palm', 'Plants & Trees', 6000, 'Organic'],
        ['pt5', 'Bonsai Collection', 'Plants & Trees', 15000, 'Organic'],
        ['pt6', 'Lawn Turf', 'Plants & Trees', 150, 'Organic'],
        ['pt7', 'Lavender Row', 'Plants & Trees', 1200, 'Organic'],
        ['pt8', 'Cactus Pot', 'Plants & Trees', 450, 'Organic'],

        ['gf1', 'Teak Bench', 'Garden Furniture', 15000, 'Teak'],
        ['gf2', 'Rattan Patio Set', 'Garden Furniture', 55000, 'Rattan'],
        ['gf3', 'Stone BBQ Grill', 'Garden Furniture', 35000, 'Natural Stone'],
        ['gf4', 'Wooden Gazebo', 'Garden Furniture', 180000, 'Cedar'],
        ['gf5', 'Luxury Sun Lounger', 'Garden Furniture', 12000, 'Aluminum'],
        ['gf6', 'Garden Swing', 'Garden Furniture', 25000, 'Steel'],
        ['gf7', 'Patio Umbrella', 'Garden Furniture', 8500, 'Fabric'],

        ['pw1', 'Olympic Pool', 'Pool & Water', 1200000, 'Tiled'],
        ['pw2', 'Zen Fountain', 'Pool & Water', 45000, 'Concrete'],
        ['pw3', 'Luxury Jacuzzi', 'Pool & Water', 150000, 'Acrylic'],
        ['pw4', 'Infinity Pool', 'Pool & Water', 2500000, 'Tiled'],
        ['pw5', 'Garden Pond', 'Pool & Water', 35000, 'Liner'],
        ['pw6', 'Waterfall Feature', 'Pool & Water', 85000, 'Stone'],

        ['gs1', 'Wooden Slat Fence', 'Structures & Lighting', 800, 'Cedar'],
        ['gs2', 'Modern Stone Wall', 'Structures & Lighting', 2200, 'Slate'],
        ['gs3', 'Garden Arch', 'Structures & Lighting', 12000, 'Iron'],
        ['gs4', 'Modern Pergola', 'Structures & Lighting', 95000, 'Aluminum'],
        ['gs5', 'Driveway Stones', 'Structures & Lighting', 450, 'Gravel'],
        ['gs6', 'Tool Shed', 'Structures & Lighting', 45000, 'Pine'],
        ['gs7', 'Solar Path Light', 'Structures & Lighting', 1200, 'Plastic'],
        ['gs8', 'Outdoor Lantern', 'Structures & Lighting', 3500, 'Glass/Metal']
    ];

    $itemStmt = $conn->prepare("INSERT INTO catalogue_items (id, name, category, price, material, images) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($items as $item) {
        $img = '["https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400"]'; // Default placeholder
        $item[] = $img;
        $itemStmt->execute($item);
    }

    $conn->exec("SET FOREIGN_KEY_CHECKS = 1;");
    $conn->commit();

    echo "<h1>Admin Sync Success (Full Dataset)</h1>";
    echo "<p>Admin Panel categories and items now match EVERY SINGLE item in the Flutter App.</p>";
    echo "<ul><li>Categories Synced: ".count($catData)."</li><li>Total Items Synced: ".count($items)."</li></ul>";
    echo "<p><a href='admin/catalogue.php'>Return to Admin Catalogue</a></p>";

} catch (Exception $e) {
    if ($conn->inTransaction()) { $conn->rollBack(); }
    echo "<h1>Sync Failed</h1>";
    echo "<p>Error: " . $e->getMessage() . "</p>";
}
?>
