<?php
// admin/feedback.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Handle feedback deletion
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete' && isset($_POST['id'])) {
    $id = $_POST['id'];
    $stmt = $conn->prepare("DELETE FROM feedback WHERE id = :id");
    $stmt->bindParam(':id', $id);
    if ($stmt->execute()) {
        $message = '<div class="alert alert-success">Feedback deleted.</div>';
    } else {
        $message = '<div class="alert alert-danger">Error deleting feedback.</div>';
    }
}

// Fetch feedback where to_user_id is NULL (App Feedback)
$app_stmt = $conn->query("
    SELECT f.*, u.name as user_name 
    FROM feedback f 
    LEFT JOIN user u ON f.from_user_id = u.id 
    WHERE f.to_user_id IS NULL OR f.to_user_id = ''
    ORDER BY f.created_at DESC
");
$app_feedbacks = $app_stmt->fetchAll();

// Fetch feedback where to_user_id is NOT NULL (Designer Feedback)
$designer_stmt = $conn->query("
    SELECT f.*, u.name as user_name, d.name as designer_name 
    FROM feedback f 
    LEFT JOIN user u ON f.from_user_id = u.id 
    LEFT JOIN user d ON f.to_user_id = d.id AND d.role = 'designer'
    WHERE f.to_user_id IS NOT NULL AND f.to_user_id != ''
    ORDER BY f.created_at DESC
");
$designer_feedbacks = $designer_stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Manage Feedback & Reviews</h1>
</div>

<?php if (isset($message)) echo $message; ?>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
    <!-- App Feedback -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">General App Feedback</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($app_feedbacks as $fb): ?>
                        <tr>
                            <td style="font-weight: 500;"><?= htmlspecialchars($fb['user_name'] ?? 'Anonymous') ?></td>
                            <td style="color:var(--warning);"><i class="fa-solid fa-star"></i> <?= $fb['rating'] ?>/5</td>
                            <td style="font-size: 0.875rem; color:var(--text-muted);"><?= htmlspecialchars($fb['comment']) ?></td>
                            <td>
                                <form method="POST" action="" style="display:inline;" onsubmit="return confirm('Delete this feedback?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $fb['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-danger"><i class="fa-solid fa-trash"></i></button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (count($app_feedbacks) == 0): ?>
                        <tr><td colspan="4" style="text-align:center;">No app feedback yet.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Designer Feedback -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Designer Reviews</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Designer</th>
                            <th>Reviewed By</th>
                            <th>Rating & Comment</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($designer_feedbacks as $fb): ?>
                        <tr>
                            <td style="font-weight: 500;">
                                <a href="designer_details.php?id=<?= $fb['to_user_id'] ?>" style="color:var(--secondary); text-decoration:none;">
                                    <?= htmlspecialchars($fb['designer_name']) ?>
                                </a>
                            </td>
                            <td><?= htmlspecialchars($fb['user_name']) ?></td>
                            <td>
                                <div style="color:var(--warning); margin-bottom:0.2rem;">
                                    <?php for($i=0; $i<$fb['rating']; $i++) echo '<i class="fa-solid fa-star"></i>'; ?>
                                </div>
                                <div style="font-size: 0.8rem; color:var(--text-muted);"><?= htmlspecialchars($fb['comment']) ?></div>
                            </td>
                            <td>
                                <form method="POST" action="" style="display:inline;" onsubmit="return confirm('Delete this feedback?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $fb['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-danger"><i class="fa-solid fa-trash"></i></button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (count($designer_feedbacks) == 0): ?>
                        <tr><td colspan="4" style="text-align:center;">No designer reviews yet.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
