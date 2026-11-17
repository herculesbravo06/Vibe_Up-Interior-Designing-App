<?php
// admin/designer_requests.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Handle accept/decline/delete action
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && isset($_POST['id'])) {
    $id = $_POST['id'];
    $action = $_POST['action'];
    
    if ($action == 'delete') {
        $stmt = $conn->prepare("DELETE FROM designer_request WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $message = '<div class="alert alert-success">Request deleted.</div>';
    } elseif ($action == 'accept') {
        // Update request status to 'accepted'
        $stmt = $conn->prepare("UPDATE designer_request SET status = 'accepted' WHERE id = :id");
        $stmt->execute(['id' => $id]);
        
        // Find associated project and update its status
        $req = $conn->prepare("SELECT project_id, designer_id FROM designer_request WHERE id = :id");
        $req->execute(['id' => $id]);
        $data = $req->fetch();
        
        if ($data && $data['project_id']) {
            $upd = $conn->prepare("UPDATE project SET status = 'active', designer_id = :did WHERE id = :pid");
            $upd->execute(['did' => $data['designer_id'], 'pid' => $data['project_id']]);
        }
        
        $message = '<div class="alert alert-success">Request accepted! Project is now active.</div>';
    } elseif ($action == 'decline') {
        $stmt = $conn->prepare("UPDATE designer_request SET status = 'declined' WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $message = '<div class="alert alert-warning">Request declined.</div>';
    }
}

// Fetch requests
$stmt = $conn->query("
    SELECT r.*, 
           u.name as user_name, u.email as user_email,
           d.name as designer_name, d.email as designer_email,
           p.name as project_name
    FROM designer_request r
    JOIN user u ON r.user_id = u.id
    LEFT JOIN user d ON r.designer_id = d.id AND d.role = 'designer'
    LEFT JOIN project p ON r.project_id = p.id
    ORDER BY r.created_at DESC
");
$requests = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Manage Designer Requests</h1>
</div>

<?= isset($message) ? $message : '' ?>

<div class="card">
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Project Name</th>
                        <th>Customer</th>
                        <th>Requested Designer</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach($requests as $req): ?>
                    <tr>
                        <td>
                            <?php 
                                $badge_class = 'badge-planning'; // pending
                                if($req['status'] == 'accepted' || $req['status'] == 'live') $badge_class = 'badge-active';
                                if($req['status'] == 'declined' || $req['status'] == 'solved') $badge_class = 'badge-completed';
                            ?>
                            <span class="badge <?= $badge_class ?>"><?= ucfirst(htmlspecialchars($req['status'])) ?></span>
                        </td>
                        <td style="font-weight: 500;">
                            <?php if($req['project_name']): ?>
                                <?= htmlspecialchars($req['project_name']) ?>
                            <?php else: ?>
                                <span style="color:var(--text-muted); font-style:italic;">No Project Linked</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <a href="user_details.php?id=<?= $req['user_id'] ?>" style="color:var(--text-main); text-decoration:none; font-weight:500;">
                                <?= htmlspecialchars($req['user_name']) ?>
                            </a>
                        </td>
                        <td>
                            <?php if($req['designer_name']): ?>
                                <a href="designer_details.php?id=<?= $req['designer_id'] ?>" style="color:var(--primary); text-decoration:none;">
                                    <i class="fa-solid fa-palette"></i> <?= htmlspecialchars($req['designer_name']) ?>
                                </a>
                            <?php else: ?>
                                <span style="color:var(--text-muted); font-style:italic;">Auto-Assign/Open Request</span>
                            <?php endif; ?>
                        </td>
                        <td><?= date('M d, Y', strtotime($req['created_at'])) ?></td>
                        <td>
                            <div class="action-btns" style="gap: 5px;">
                                <?php if($req['status'] == 'pending'): ?>
                                    <form method="POST" action="" style="display:inline;">
                                        <input type="hidden" name="action" value="accept">
                                        <input type="hidden" name="id" value="<?= $req['id'] ?>">
                                        <button type="submit" class="btn btn-sm" style="background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid #10b981;" title="Accept Request">
                                            <i class="fa-solid fa-check"></i>
                                        </button>
                                    </form>
                                    <form method="POST" action="" style="display:inline;">
                                        <input type="hidden" name="action" value="decline">
                                        <input type="hidden" name="id" value="<?= $req['id'] ?>">
                                        <button type="submit" class="btn btn-sm" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; border: 1px solid #ef4444;" title="Decline Request">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </form>
                                <?php endif; ?>
                                <form method="POST" action="" style="display:inline;" onsubmit="return confirm('Delete this request permanently?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $req['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-danger" style="background: var(--danger); border: none; padding: 5px 10px;" title="Delete Permanently">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($requests) == 0): ?>
                    <tr><td colspan="6" style="text-align:center;">No designer requests found.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
