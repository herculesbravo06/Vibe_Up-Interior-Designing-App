<?php
// admin/categories.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

// Ensure table exists
$conn->exec("CREATE TABLE IF NOT EXISTS catalogue_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");

$message = '';

// Handle Delete
if (isset($_GET['delete'])) {
    $stmt = $conn->prepare("DELETE FROM catalogue_categories WHERE id = :id");
    $stmt->execute(['id' => $_GET['delete']]);
    $message = '<div class="alert alert-success">Category deleted successfully!</div>';
}

// Handle Add/Edit
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $image_url = $_POST['image_url'] ?? '';
    $id = $_POST['id'] ?? '';

    try {
        if ($id) {
            $stmt = $conn->prepare("UPDATE catalogue_categories SET name = :name, image_url = :image_url WHERE id = :id");
            $stmt->execute(['name' => $name, 'image_url' => $image_url, 'id' => $id]);
            $message = '<div class="alert alert-success">Category updated!</div>';
        } else {
            $stmt = $conn->prepare("INSERT INTO catalogue_categories (name, image_url) VALUES (:name, :image_url)");
            $stmt->execute(['name' => $name, 'image_url' => $image_url]);
            $message = '<div class="alert alert-success">Category added!</div>';
        }
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

$categories = $conn->query("SELECT * FROM catalogue_categories ORDER BY name")->fetchAll();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Manage Categories</h1>
    <div class="action-btns">
        <a href="catalogue.php" class="btn-primary" style="background: var(--secondary); border: 1px solid var(--border); color: var(--text); padding: 8px 20px; min-width: unset;">
            <i class="fa-solid fa-arrow-left"></i> Back to Inventory
        </a>
    </div>
</div>

<?= $message ?>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 2rem;">
    <!-- Form -->
    <div class="card" style="height: fit-content;">
        <div class="card-header">
            <h3 class="card-title">Add / Edit Category</h3>
        </div>
        <div class="card-body">
            <form method="POST">
                <input type="hidden" name="id" id="cat_id">
                <div class="form-group">
                    <label class="form-label">Category Name</label>
                    <input type="text" name="name" id="cat_name" class="form-control" placeholder="e.g. Modern Sofas" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Image URL</label>
                    <input type="url" name="image_url" id="cat_image" class="form-control" placeholder="https://images.unsplash.com/...">
                </div>
                <div style="margin-top: 1.5rem;">
                    <button type="submit" class="btn-primary" style="width: 100%;">Save Category</button>
                    <button type="button" onclick="resetForm()" class="btn-secondary" style="width: 100%; margin-top: 0.5rem;">Reset</button>
                </div>
            </form>
        </div>
    </div>

    <!-- List -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Existing Categories</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Preview</th>
                            <th>Name</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($categories as $cat): ?>
                            <tr>
                                <td>
                                    <?php if ($cat['image_url']): ?>
                                        <img src="<?= htmlspecialchars($cat['image_url']) ?>" style="width: 50px; height: 50px; border-radius: 8px; object-fit: cover;">
                                    <?php else: ?>
                                        <div style="width: 50px; height: 50px; border-radius: 8px; background: var(--secondary); display: flex; align-items: center; justify-content: center;">
                                            <i class="fa-solid fa-folder"></i>
                                        </div>
                                    <?php endif; ?>
                                </td>
                                <td style="font-weight: 600;"><?= htmlspecialchars($cat['name']) ?></td>
                                <td>
                                    <div class="action-btns">
                                        <button onclick='editCat(<?= json_encode($cat) ?>)' class="btn-secondary btn-sm"><i class="fa-solid fa-pen"></i></button>
                                        <a href="?delete=<?= $cat['id'] ?>" class="btn-danger btn-sm" onclick="return confirm('Delete this category?')"><i class="fa-solid fa-trash"></i></a>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                        <?php if (empty($categories)): ?>
                            <tr><td colspan="3" style="text-align: center; padding: 2rem;">No categories yet.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
function editCat(cat) {
    document.getElementById('cat_id').value = cat.id;
    document.getElementById('cat_name').value = cat.name;
    document.getElementById('cat_image').value = cat.image_url;
}
function resetForm() {
    document.getElementById('cat_id').value = '';
    document.getElementById('cat_name').value = '';
    document.getElementById('cat_image').value = '';
}
</script>

<?php require_once '../includes/footer.php'; ?>
