<?php
// admin/designer_details.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

$designer_id = $_GET['id'] ?? 0;

// Fetch designer details (id is the user.id)
$stmt = $conn->prepare("
    SELECT u.*, d.bio, d.rating, d.experience_years, d.portfolio_urls, d.id as designer_table_id
    FROM user u
    LEFT JOIN designer d ON u.id = d.user_id
    WHERE u.id = :id AND u.role = 'designer'
");
$stmt->bindParam(':id', $designer_id);
$stmt->execute();
$designer = $stmt->fetch();

if (!$designer) {
    echo "<div class='page-content'><h2>Designer not found.</h2><a href='designers.php'>Back to Designers</a></div>";
    require_once '../includes/footer.php';
    exit;
}

$designer_table_id = $designer['designer_table_id'];

// Fetch qualifications
$qual_stmt = $conn->prepare("SELECT * FROM designer_qualification WHERE designer_id = :did");
$qual_stmt->bindParam(':did', $designer_table_id);
$qual_stmt->execute();
$qualifications = $qual_stmt->fetchAll();

// Fetch designer's assigned projects
$proj_stmt = $conn->prepare("
    SELECT p.*, u.name as user_name 
    FROM project p
    JOIN user u ON p.user_id = u.id
    JOIN designer_request dr ON p.id = dr.project_id
    WHERE dr.designer_id = :did AND dr.status = 'accepted'
    ORDER BY p.created_at DESC
");
$proj_stmt->bindParam(':did', $designer_table_id);
$proj_stmt->execute();
$projects = $proj_stmt->fetchAll();

// Fetch feedback
$fb_stmt = $conn->prepare("
    SELECT f.*, u.name as user_name 
    FROM feedback f
    JOIN user u ON f.from_user_id = u.id
    WHERE f.to_user_id = :uid
    ORDER BY f.created_at DESC
");
$fb_stmt->bindParam(':uid', $designer_id);
$fb_stmt->execute();
$feedbacks = $fb_stmt->fetchAll();

?>

<div class="page-header">
    <h1 class="page-title">Designer Profile & Portfolio</h1>
    <a href="designers.php" class="btn-primary" style="display:inline-block; width:auto; background-color:var(--text-muted);"><i class="fa-solid fa-arrow-left"></i> Back to Designers</a>
</div>

<div class="stats-grid">
    <div class="card" style="margin-bottom:0;">
        <div class="card-body" style="display:flex; align-items:center; gap: 1.5rem;">
            <?php 
                $img = !empty($designer['profile_pic_url']) 
                    ? (strpos($designer['profile_pic_url'], 'http') === 0 ? $designer['profile_pic_url'] : '../' . $designer['profile_pic_url'])
                    : 'https://ui-avatars.com/api/?name='.urlencode($designer['name']).'&background=ec4899&color=fff'; 
            ?>
            <img src="<?= htmlspecialchars($img) ?>" style="width:100px; height:100px; border-radius:50%; box-shadow:0 4px 6px rgba(0,0,0,0.1); border: 2px solid var(--secondary); object-fit:cover;">
            <div>
                <h2 style="font-size:1.5rem; margin-bottom:0.2rem;"><?= htmlspecialchars($designer['name']) ?></h2>
                <div style="color:var(--warning); font-weight:bold; margin-bottom:0.5rem;"><i class="fa-solid fa-star"></i> <?= $designer['rating'] ?? '0.0' ?> Rating</div>
                <div class="badge badge-active"><i class="fa-solid fa-briefcase"></i> <?= htmlspecialchars($designer['experience_years'] ?? '0') ?> Years Experience</div>
            </div>
            <div style="flex-grow:1; text-align:right;">
                <p style="color:var(--text-muted);"><i class="fa-solid fa-envelope"></i> <?= htmlspecialchars($designer['email']) ?></p>
                <p style="color:var(--text-muted); margin-top:0.5rem;"><i class="fa-solid fa-phone"></i> <?= htmlspecialchars($designer['phone']) ?></p>
                <?php if(!empty($designer['bio'])): ?>
                    <p style="color:var(--text-muted); font-style:italic; margin-top:0.5rem;"><?= htmlspecialchars($designer['bio']) ?></p>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php if(count($qualifications) > 0): ?>
<div class="card" style="margin-top: 1.5rem;">
    <div class="card-header">
        <h3 class="card-title">Qualifications</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Qualification</th>
                        <th>Institute</th>
                        <th>Year Completed</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach($qualifications as $q): ?>
                    <tr>
                        <td style="font-weight: 500;"><?= htmlspecialchars($q['qualification_name']) ?></td>
                        <td><?= htmlspecialchars($q['institute_name'] ?? 'N/A') ?></td>
                        <td><?= htmlspecialchars($q['year_completed'] ?? 'N/A') ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<div class="stats-grid" style="margin-top: 2rem;">
    <!-- Projects Handled -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Assigned Projects</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Project Name</th>
                            <th>Customer</th>
                            <th>Budget</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($projects as $project): ?>
                        <tr>
                            <td style="font-weight: 500;"><?= htmlspecialchars($project['name']) ?></td>
                            <td>
                                <a href="user_details.php?id=<?= $project['user_id'] ?>" style="color:var(--primary); text-decoration:none;">
                                    <i class="fa-solid fa-user"></i> <?= htmlspecialchars($project['user_name']) ?>
                                </a>
                            </td>
                            <td><?= $project['total_estimated_cost'] ? $project['currency'].' '.number_format($project['total_estimated_cost'], 2) : 'N/A' ?></td>
                            <td>
                                <?php 
                                    $badge_class = 'badge-planning';
                                    if($project['status'] == 'in_progress') $badge_class = 'badge-active';
                                    if($project['status'] == 'completed') $badge_class = 'badge-completed';
                                ?>
                                <span class="badge <?= $badge_class ?>"><?= ucfirst(str_replace('_', ' ', $project['status'])) ?></span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (count($projects) == 0): ?>
                        <tr><td colspan="4" style="text-align:center;">No assigned projects yet.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Feedback -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Client Feedback</h3>
        </div>
        <div class="card-body">
            <?php foreach($feedbacks as $fb): ?>
            <div style="border-bottom: 1px solid var(--border); padding-bottom: 1rem; margin-bottom: 1rem;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.5rem;">
                    <strong style="color:var(--text-main); font-size:0.9rem;"><?= htmlspecialchars($fb['user_name']) ?></strong>
                    <span style="color:var(--warning); font-size:0.8rem;">
                        <?php for($i=0; $i<$fb['rating']; $i++) echo '<i class="fa-solid fa-star"></i>'; ?>
                    </span>
                </div>
                <p style="font-size:0.85rem; color:var(--text-muted); font-style:italic;">"<?= htmlspecialchars($fb['comment']) ?>"</p>
                <div style="font-size:0.7rem; color:var(--border); text-align:right; margin-top:0.5rem;">
                    <?= date('M d, Y', strtotime($fb['created_at'])) ?>
                </div>
            </div>
            <?php endforeach; ?>
            <?php if (count($feedbacks) == 0): ?>
                <div style="text-align:center; color:var(--text-muted); font-style:italic;">No client feedback available.</div>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
