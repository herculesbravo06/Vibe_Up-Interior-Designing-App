<?php
// admin/edit_catalogue.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';
$cat_prefill = $_GET['category'] ?? ''; // Prefill category if adding from category view
$item = null;

if ($id) {
    $stmt = $conn->prepare("SELECT * FROM catalogue_items WHERE id = :id");
    $stmt->execute(['id' => $id]);
    $item = $stmt->fetch();
}

// Fetch categories for dropdown
$categories = $conn->query("SELECT name FROM catalogue_categories ORDER BY name")->fetchAll(PDO::FETCH_COLUMN);

$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $category = $_POST['category'] ?? '';
    $price = $_POST['price'] ?? 0;
    $material = $_POST['material'] ?? '';
    $image_url = $_POST['image_url'] ?? '';
    
    // Store image URL as a JSON array for compatibility with current schema
    $images_json = json_encode([$image_url]);

    try {
        if ($id) {
            $update = $conn->prepare("UPDATE catalogue_items SET name = :name, category = :category, price = :price, material = :material, images = :images WHERE id = :id");
            $update->execute(['name' => $name, 'category' => $category, 'price' => $price, 'material' => $material, 'images' => $images_json, 'id' => $id]);
            $message = '<div class="alert alert-success">Item updated successfully!</div>';
        } else {
            $new_id = 'c' . rand(100, 999);
            $insert = $conn->prepare("INSERT INTO catalogue_items (id, name, category, price, material, images) VALUES (:id, :name, :category, :price, :material, :images)");
            $insert->execute(['id' => $new_id, 'name' => $name, 'category' => $category, 'price' => $price, 'material' => $material, 'images' => $images_json]);
            header("Location: catalogue.php?category=" . urlencode($category));
            exit;
        }
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title"><?= $id ? 'Edit Product' : 'Add New Product' ?></h1>
    <a href="catalogue.php<?= ($item || $cat_prefill) ? '?category=' . urlencode($item ? $item['category'] : $cat_prefill) : '' ?>" class="btn-secondary">
        <i class="fa-solid fa-arrow-left"></i> Back to List
    </a>
</div>

<?= $message ?>

<div class="card" style="max-width: 800px;">
    <div class="card-body">
        <form method="POST">
            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 2rem;">
                <div class="column">
                    <div class="form-group">
                        <label class="form-label">Product Name</label>
                        <input type="text" name="name" class="form-control" value="<?= $item ? htmlspecialchars($item['name']) : '' ?>" required placeholder="e.g. Modern Velvet Sofa">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select name="category" class="form-control" required>
                            <option value="">-- Select Category --</option>
                            <?php foreach ($categories as $cat): ?>
                                <option value="<?= htmlspecialchars($cat) ?>" <?= (($item && $item['category'] == $cat) || (!$item && $cat_prefill == $cat)) ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($cat) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                        <p style="font-size: 0.75rem; margin-top: 0.25rem;">Don't see your category? <a href="categories.php" style="color: var(--primary);">Add it here</a></p>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label class="form-label">Price (INR)</label>
                            <input type="number" step="0.01" name="price" class="form-control" value="<?= $item ? $item['price'] : '' ?>" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Material</label>
                            <input type="text" name="material" class="form-control" value="<?= $item ? htmlspecialchars($item['material']) : '' ?>" placeholder="e.g. Wood, Leather">
                        </div>
                    </div>
                </div>

                <div class="column">
                    <div class="form-group">
                        <label class="form-label">Product Image URL</label>
                        <input type="url" name="image_url" id="img_input" class="form-control" value="<?= $item ? htmlspecialchars(json_decode($item['images'])[0] ?? '') : '' ?>" placeholder="https://..." oninput="previewImg(this.value)">
                    </div>
                    
                    <div id="preview_container" style="width: 100%; height: 200px; border-radius: 12px; background: var(--secondary); border: 1px dashed var(--border); display: flex; align-items: center; justify-content: center; overflow: hidden; margin-top: 1rem;">
                        <?php if ($item && !empty(json_decode($item['images'])[0])): ?>
                            <img src="<?= htmlspecialchars(json_decode($item['images'])[0]) ?>" style="width: 100%; height: 100%; object-fit: cover;" id="img_preview">
                        <?php else: ?>
                            <p id="preview_text" style="color: var(--text-muted); font-size: 0.85rem;">Image Preview</p>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <div style="margin-top: 2.5rem; border-top: 1px solid var(--border); padding-top: 1.5rem; display: flex; gap: 1rem;">
                <button type="submit" class="btn-primary"><?= $id ? 'Save Product Changes' : 'Create Product Entry' ?></button>
                <a href="catalogue.php" class="btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
function previewImg(url) {
    const container = document.getElementById('preview_container');
    if (url) {
        container.innerHTML = `<img src="${url}" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.parentElement.innerHTML='<p style=\'color:red\'>Invalid Image URL</p>'">`;
    } else {
        container.innerHTML = `<p style="color: var(--text-muted); font-size: 0.85rem;">Image Preview</p>`;
    }
}
</script>

<?php require_once '../includes/footer.php'; ?>
