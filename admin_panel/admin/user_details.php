<?php
// admin/user_details.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

$user_id = $_GET['id'] ?? 0;

// Fetch user details
$stmt = $conn->prepare("SELECT * FROM user WHERE id = :id AND role = 'user'");
$stmt->bindParam(':id', $user_id);
$stmt->execute();
$user = $stmt->fetch();

if (!$user) {
    echo "<div class='page-content'><h2>User not found.</h2><a href='users.php'>Back to Users</a></div>";
    require_once '../includes/footer.php';
    exit;
}

// Fetch user's projects with designer info and room details
$proj_stmt = $conn->prepare("
    SELECT p.*, 
           d_user.name as designer_name, d_user.id as designer_user_id,
           (SELECT GROUP_CONCAT(CONCAT(r.name, ' (', r.length_m, 'x', r.width_m, 'm)') SEPARATOR ', ') FROM room r WHERE r.project_id = p.id) as room_info,
           (SELECT SUM(r.budget_estimate) FROM room r WHERE r.project_id = p.id) as room_budget
    FROM project p
    LEFT JOIN designer_request dr ON p.id = dr.project_id AND dr.status = 'accepted'
    LEFT JOIN designer d ON dr.designer_id = d.id
    LEFT JOIN user d_user ON d.user_id = d_user.id
    WHERE p.user_id = :id
    ORDER BY p.created_at DESC
");
$proj_stmt->bindParam(':id', $user_id);
$proj_stmt->execute();
$projects = $proj_stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Customer Details</h1>
    <a href="users.php" class="btn-primary" style="display:inline-block; width:auto; background-color:var(--text-muted);"><i class="fa-solid fa-arrow-left"></i> Back to Users</a>
</div>

<div class="stats-grid">
    <div class="card" style="margin-bottom:0;">
        <div class="card-body" style="display:flex; align-items:center; gap: 1.5rem;">
            <?php $img = !empty($user['profile_pic_url']) ? (strpos($user['profile_pic_url'], 'http') === 0 ? $user['profile_pic_url'] : '../' . $user['profile_pic_url']) : 'https://ui-avatars.com/api/?name='.urlencode($user['name']).'&background=random'; ?>
            <img src="<?= htmlspecialchars($img) ?>" style="width:100px; height:100px; border-radius:50%; box-shadow:0 4px 6px rgba(0,0,0,0.1); object-fit:cover;">
            <div>
                <h2 style="font-size:1.5rem; margin-bottom:0.2rem;"><?= htmlspecialchars($user['name']) ?></h2>
                <p style="color:var(--text-muted); margin-bottom:0.5rem;"><i class="fa-solid fa-envelope"></i> <?= htmlspecialchars($user['email']) ?></p>
                <p style="color:var(--text-muted); margin-bottom:0.5rem;"><i class="fa-solid fa-phone"></i> <?= htmlspecialchars($user['phone']) ?></p>
                <div class="badge badge-active">Joined <?= date('M Y', strtotime($user['created_at'])) ?></div>
            </div>
        </div>
    </div>
</div>

<h3 style="margin-top: 2rem;">Projects (<?= count($projects) ?>)</h3>

<div class="card">
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Project Name</th>
                        <th>Rooms</th>
                        <th>Budget</th>
                        <th>Assigned Designer</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach($projects as $project): ?>
                    <tr>
                        <td style="font-weight: 500;"><?= htmlspecialchars($project['name']) ?></td>
                        <td><i class="fa-solid fa-door-open"></i> <?= htmlspecialchars($project['room_info'] ?? 'No rooms') ?></td>
                        <td><?= $project['total_estimated_cost'] ? $project['currency'].' '.number_format($project['total_estimated_cost'], 2) : 'N/A' ?></td>
                        <td>
                            <?php if($project['designer_name']): ?>
                                <a href="designer_details.php?id=<?= $project['designer_user_id'] ?>" style="color:var(--primary); text-decoration:none;">
                                    <i class="fa-solid fa-pen-nib"></i> <?= htmlspecialchars($project['designer_name']) ?>
                                </a>
                            <?php else: ?>
                                <span style="color:var(--text-muted); font-style:italic;">DIY / AI Assist</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php 
                                $badge_class = 'badge-planning';
                                if($project['status'] == 'in_progress') $badge_class = 'badge-active';
                                if($project['status'] == 'completed') $badge_class = 'badge-completed';
                            ?>
                            <span class="badge <?= $badge_class ?>"><?= ucfirst(str_replace('_', ' ', $project['status'])) ?></span>
                        </td>
                        <td><?= date('M d, Y', strtotime($project['created_at'])) ?></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (count($projects) == 0): ?>
                    <tr><td colspan="6" style="text-align:center;">This user has no projects yet.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
