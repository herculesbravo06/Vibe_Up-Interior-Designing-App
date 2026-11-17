<?php
// admin/designers.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Filter Logic
$status_filter = $_GET['filter'] ?? 'all';

$query = "SELECT u.id, u.name, u.email, u.last_activity, d.bio, d.rating, d.experience_years 
          FROM user u 
          JOIN designer d ON u.id = d.user_id 
          WHERE u.role = 'designer'";

$params = [];
if ($status_filter === 'online') {
    $query .= " AND u.last_activity > DATE_SUB(NOW(), INTERVAL 5 MINUTE)";
}

$query .= " ORDER BY d.rating DESC";

$stmt = $conn->prepare($query);
$stmt->execute($params);
$designers = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title"><?= $status_filter === 'online' ? 'Online ' : '' ?>Manage Designers</h1>
    <div class="action-btns">
        <a href="add_designer.php" class="btn-primary">
            <i class="fa-solid fa-user-plus"></i> Add New Designer
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">Registered Interior Designers</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Designer</th>
                        <th>Contact</th>
                        <th>Experience</th>
                        <th>Rating</th>
                        <th>Bio</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                        <?php foreach ($designers as $designer): ?>
                        <tr>
                            <td>
                                <?php 
                                $is_online = (isset($designer['last_activity']) && strtotime($designer['last_activity']) > (time() - 300));
                                ?>
                                <span class="badge" style="background: <?= $is_online ? 'rgba(16, 185, 129, 0.1)' : 'rgba(148, 163, 184, 0.1)' ?>; color: <?= $is_online ? '#10b981' : '#94a3b8' ?>; border: 1px solid <?= $is_online ? '#10b981' : 'transparent' ?>;">
                                    <i class="fa-solid fa-circle" style="font-size: 0.5rem; margin-right: 5px;"></i>
                                    <?= $is_online ? 'Online' : 'Offline' ?>
                                </span>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: #fff;"><?= htmlspecialchars((string)$designer['name']) ?></div>
                                <div style="font-size: 0.75rem; color: var(--text-muted);">ID: <?= $designer['id'] ?></div>
                            </td>
                            <td><?= htmlspecialchars((string)$designer['email']) ?></td>
                            <td><span class="badge badge-active"><?= $designer['experience_years'] ?> Years</span></td>
                            <td>
                                <div style="color: var(--warning); font-weight: 600;">
                                    <i class="fa-solid fa-star"></i> <?= $designer['rating'] ?>
                                </div>
                            </td>
                            <td>
                                <div style="max-width: 200px; font-size: 0.85rem; color: var(--text-muted);" title="<?= htmlspecialchars((string)$designer['bio']) ?>">
                                    <?= htmlspecialchars(strlen((string)$designer['bio']) > 50 ? substr((string)$designer['bio'], 0, 50) . '...' : (string)$designer['bio']) ?>
                                </div>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="designer_details.php?id=<?= $designer['id'] ?>" class="btn-primary btn-sm" title="View Details" style="padding: 5px 10px; min-width: unset;">
                                        <i class="fa-solid fa-eye"></i>
                                    </a>
                                    <a href="edit_designer.php?id=<?= $designer['id'] ?>" class="btn-secondary btn-sm" title="Edit" style="padding: 5px 10px; min-width: unset; background: var(--secondary); color: var(--text); border: 1px solid var(--border);">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <a href="delete_designer.php?id=<?= $designer['id'] ?>" class="btn-danger btn-sm" title="Delete" onclick="return confirm('Permanently delete this designer and their profile?')" style="padding: 5px 10px; min-width: unset;">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
