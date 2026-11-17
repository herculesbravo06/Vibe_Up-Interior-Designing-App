<?php
// admin/catalogue.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$category_filter = $_GET['category'] ?? '';

// Fetch all categories
$categories = $conn->query("SELECT * FROM catalogue_categories ORDER BY name")->fetchAll();

if ($category_filter) {
    // If a category is selected, show items
    $stmt = $conn->prepare("SELECT * FROM catalogue_items WHERE category = :cat ORDER BY name");
    $stmt->execute(['cat' => $category_filter]);
    $items = $stmt->fetchAll();
} else {
    // Robust aggregate counts for categories
    $counts_raw = $conn->query("SELECT category, COUNT(*) as count FROM catalogue_items GROUP BY category")->fetchAll(PDO::FETCH_KEY_PAIR);
    $counts = [];
    foreach($counts_raw as $k => $v) {
        $counts[strtolower(trim($k))] = $v;
    }

    // ─── Grouping Logic for Hierarchical View ───
    $majorGroups = [
        "CONSTRUCTION" => [
            "Rooms (Construction)", "Walls & Partitions", "Doors & Openings", "Windows", "Stairs & Columns"
        ],
        "INTERIOR" => [
            "Living Room", "Bedroom", "Kitchen", "Dining Room", "Bathroom", "Office", "Kids Room", "Gym & Hobby"
        ],
        "EXTERIOR" => [
            "Plants & Trees", "Garden Furniture", "Pool & Water", "Structures & Lighting"
        ]
    ];

    $groupedCategories = ["CONSTRUCTION" => [], "INTERIOR" => [], "EXTERIOR" => [], "OTHER" => []];
    foreach ($categories as $cat) {
        $found = false;
        foreach ($majorGroups as $major => $subs) {
            if (in_array($cat['name'], $subs)) {
                $groupedCategories[$major][] = $cat;
                $found = true;
                break;
            }
        }
        if (!$found) $groupedCategories["OTHER"][] = $cat;
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <div style="display: flex; flex-direction: column;">
        <h1 class="page-title"><?= $category_filter ? 'Category: ' . htmlspecialchars($category_filter) : 'Product Catalogue' ?></h1>
        <?php if ($category_filter): ?>
            <a href="catalogue.php" style="color: var(--primary); font-size: 0.9rem; text-decoration: none;">
                <i class="fa-solid fa-arrow-left"></i> All Categories
            </a>
        <?php endif; ?>
    </div>
    <div class="action-btns">
        <a href="edit_catalogue.php<?= $category_filter ? '?category=' . urlencode($category_filter) : '' ?>" class="btn-primary" style="padding: 8px 20px; min-width: unset;">
            <i class="fa-solid fa-plus"></i> Add New Item
        </a>
    </div>
</div>

<?php if (!$category_filter): ?>
    <!-- Hierarchical Grouped View -->
    <?php foreach ($groupedCategories as $major => $cats): ?>
        <?php if (!empty($cats)): ?>
            <div style="margin-bottom: 3rem;">
                <div style="display: flex; align-items: center; margin-bottom: 1.5rem;">
                    <h2 style="margin: 0; font-size: 1rem; letter-spacing: 2px; color: var(--accent); font-weight: 700;"><?= $major ?></h2>
                    <div style="flex-grow: 1; height: 1px; background: linear-gradient(to right, var(--accent_low), transparent); margin-left: 20px;"></div>
                </div>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem;">
                    <?php foreach ($cats as $cat): ?>
                        <a href="?category=<?= urlencode($cat['name']) ?>" class="cat-card">
                            <div class="cat-img">
                                <?php if ($cat['image_url']): ?>
                                    <img src="<?= htmlspecialchars($cat['image_url']) ?>">
                                <?php else: ?>
                                    <div class="cat-placeholder">
                                        <i class="fa-solid fa-couch fa-2x"></i>
                                    </div>
                                <?php endif; ?>
                                <div class="cat-overlay"></div>
                            </div>
                            <div class="cat-content">
                                <h3><?= htmlspecialchars($cat['name']) ?></h3>
                                <?php $cname = strtolower(trim($cat['name'])); ?>
                                <span class="badge"><?= $counts[$cname] ?? 0 ?> Products</span>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endif; ?>
    <?php endforeach; ?>
<?php else: ?>
    <!-- Items List View (Filtered) -->
    <div class="card">
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Product Detail</th>
                            <th>Price</th>
                            <th>Material</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($items)): ?>
                            <tr><td colspan="5" style="text-align:center; padding: 3rem; color: var(--text-muted);">No products found in this category.</td></tr>
                        <?php else: ?>
                            <?php foreach ($items as $item): ?>
                                <tr>
                                    <td>
                                        <?php if ($item['images']): ?>
                                            <?php $imgs = json_decode($item['images'], true); ?>
                                            <img src="<?= htmlspecialchars($imgs[0] ?? (strpos($item['images'], 'http') === 0 ? $item['images'] : '../assets/img/placeholder.png')) ?>" style="width: 50px; height: 50px; border-radius: 8px; object-fit: cover; border: 1px solid var(--border);">
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;"><?= htmlspecialchars((string)$item['name']) ?></div>
                                        <div style="font-size: 0.75rem; color: var(--text-muted);"><?= $item['id'] ?></div>
                                    </td>
                                    <td style="font-weight: 700; color: var(--accent);"><?= number_format($item['price']) ?> <?= $item['currency'] ?? 'INR' ?></td>
                                    <td><?= htmlspecialchars((string)$item['material'] ?? 'N/A') ?></td>
                                    <td>
                                        <div class="action-btns">
                                            <a href="edit_catalogue.php?id=<?= $item['id'] ?>" class="btn-secondary btn-sm"><i class="fa-solid fa-pen"></i></a>
                                            <a href="delete_catalogue.php?id=<?= $item['id'] ?>" class="btn-danger btn-sm" onclick="return confirm('Delete?')"><i class="fa-solid fa-trash"></i></a>
                                        </div>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
<?php endif; ?>

<style>
.cat-card {
    text-decoration: none;
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    display: flex;
    flex-direction: column;
}

.cat-card:hover {
    transform: translateY(-8px);
    border-color: var(--accent);
    box-shadow: 0 12px 24px rgba(0,0,0,0.3);
}

.cat-img {
    height: 160px;
    position: relative;
    background: var(--secondary);
}

.cat-img img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.cat-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-muted);
}

.cat-overlay {
    position: absolute;
    bottom: 0; left: 0; right: 0;
    height: 60%;
    background: linear-gradient(to top, rgba(15, 23, 42, 0.8), transparent);
}

.cat-content {
    padding: 1.25rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.cat-content h3 {
    margin: 0;
    font-size: 1.1rem;
    color: var(--text);
    font-weight: 600;
}

.badge {
    background: var(--accent_low);
    color: var(--accent);
    padding: 4px 10px;
    border-radius: 8px;
    font-size: 0.75rem;
    font-weight: 700;
}

.btn-primary {
    background: var(--accent) !important;
    border: none;
    border-radius: 10px;
    color: #000 !important;
    font-weight: 700;
}
</style>

<?php require_once '../includes/footer.php'; ?>

