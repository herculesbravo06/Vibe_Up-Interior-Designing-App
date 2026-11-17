<?php
// admin/edit_project.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';
$project = null;

if ($id) {
    $stmt = $conn->prepare("SELECT * FROM project WHERE id = :id");
    $stmt->execute(['id' => $id]);
    $project = $stmt->fetch();
}

if (!$project) {
    header("Location: projects.php");
    exit;
}

// Fetch designers for assignment
$designers = $conn->query("SELECT d.id, u.name FROM designer d JOIN user u ON d.user_id = u.id")->fetchAll();

$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $status = $_POST['status'] ?? 'draft';
    $cost = $_POST['total_estimated_cost'] ?? 0;
    $designer_id = $_POST['designer_id'] ?: null;

    try {
        $update = $conn->prepare("UPDATE project SET name = :name, status = :status, total_estimated_cost = :cost, designer_id = :designer_id WHERE id = :id");
        $update->execute([
            'name' => $name,
            'status' => $status,
            'cost' => $cost,
            'designer_id' => $designer_id,
            'id' => $id
        ]);
        $message = '<div class="alert alert-success">Project updated successfully!</div>';
        $stmt->execute(['id' => $id]);
        $project = $stmt->fetch();
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Edit Project: <?= htmlspecialchars($project['name']) ?></h1>
    <a href="projects.php" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Back to List</a>
</div>

<?= $message ?>

<div class="card" style="max-width: 700px;">
    <div class="card-body">
        <form method="POST">
            <div class="form-group">
                <label class="form-label">Project Name</label>
                <input type="text" name="name" class="form-control" value="<?= htmlspecialchars($project['name']) ?>" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">Status</label>
                <select name="status" class="form-control">
                    <option value="draft" <?= $project['status'] == 'draft' ? 'selected' : '' ?>>Draft</option>
                    <option value="in_progress" <?= $project['status'] == 'in_progress' ? 'selected' : '' ?>>In Progress</option>
                    <option value="completed" <?= $project['status'] == 'completed' ? 'selected' : '' ?>>Completed</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Estimated Cost (INR)</label>
                <input type="number" step="0.01" name="total_estimated_cost" class="form-control" value="<?= $project['total_estimated_cost'] ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Assign Designer</label>
                <select name="designer_id" class="form-control">
                    <option value="">-- No Designer Assigned --</option>
                    <?php foreach ($designers as $designer): ?>
                        <option value="<?= $designer['id'] ?>" <?= $project['designer_id'] == $designer['id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($designer['name']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary">Update Project Details</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
