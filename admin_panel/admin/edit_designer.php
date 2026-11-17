<?php
// admin/edit_designer.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';
$designer = null;

if ($id) {
    $stmt = $conn->prepare("
        SELECT u.*, d.bio, d.experience_years, d.rating 
        FROM user u 
        JOIN designer d ON u.id = d.user_id 
        WHERE d.id = :id
    ");
    $stmt->execute(['id' => $id]);
    $designer = $stmt->fetch();
}

if (!$designer) {
    header("Location: designers.php");
    exit;
}

$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $bio = $_POST['bio'] ?? '';
    $exp = $_POST['experience_years'] ?? 0;
    $rating = $_POST['rating'] ?? 0;

    try {
        $conn->beginTransaction();
        
        // Update user table
        $updateUser = $conn->prepare("UPDATE user SET name = :name WHERE id = :uid");
        $updateUser->execute(['name' => $name, 'uid' => $designer['user_id']]);
        
        // Update designer table
        $updateDesigner = $conn->prepare("UPDATE designer SET bio = :bio, experience_years = :exp, rating = :rating WHERE id = :id");
        $updateDesigner->execute([
            'bio' => $bio,
            'exp' => $exp,
            'rating' => $rating,
            'id' => $id
        ]);
        
        $conn->commit();
        $message = '<div class="alert alert-success">Designer updated successfully!</div>';
        
        // Refresh data
        $stmt->execute(['id' => $id]);
        $designer = $stmt->fetch();
    } catch (Exception $e) {
        $conn->rollBack();
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Edit Designer: <?= htmlspecialchars($designer['name']) ?></h1>
    <a href="designers.php" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Back to List</a>
</div>

<?= $message ?>

<div class="card" style="max-width: 700px;">
    <div class="card-body">
        <form method="POST">
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-control" value="<?= htmlspecialchars($designer['name']) ?>" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">Bio / Description</label>
                <textarea name="bio" class="form-control" rows="4"><?= htmlspecialchars($designer['bio']) ?></textarea>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Experience (Years)</label>
                    <input type="number" name="experience_years" class="form-control" value="<?= $designer['experience_years'] ?>">
                </div>
                <div class="form-group">
                    <label class="form-label">Rating (0-5)</label>
                    <input type="number" step="0.1" name="rating" class="form-control" value="<?= $designer['rating'] ?>">
                </div>
            </div>
            
            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary">Update Designer Profile</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
