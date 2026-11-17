<?php
// admin/admins.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch all admin users
$stmt = $conn->query("SELECT id, name, email, username, created_at FROM user WHERE role = 'admin' ORDER BY created_at DESC");
$admins = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Manage Administrators</h1>
    <button class="btn-primary" onclick="alert('Admin registration is managed via secure setup.')">
        <i class="fa-solid fa-user-plus"></i> New Admin
    </button>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">System Administrators</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Username</th>
                        <th>Access Level</th>
                        <th>Joined Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($admins as $admin): ?>
                        <tr>
                            <td>
                                <div style="display: flex; align-items: center; gap: 0.75rem;">
                                    <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--secondary); display: flex; align-items: center; justify-content: center; font-size: 0.8rem; font-weight: 600;">
                                        <i class="fa-solid fa-shield-halved"></i>
                                    </div>
                                    <?= htmlspecialchars((string)$admin['name']) ?>
                                </div>
                            </td>
                            <td><?= htmlspecialchars((string)$admin['email']) ?></td>
                            <td>@<?= htmlspecialchars((string)$admin['username']) ?></td>
                            <td>
                                <span class="badge badge-active">Full Admin</span>
                            </td>
                            <td><?= date('M d, Y', strtotime($admin['created_at'])) ?></td>
                            <td>
                                <div class="action-btns">
                                    <a href="#" class="btn-secondary btn-sm" title="Edit Settings">
                                        <i class="fa-solid fa-gear"></i>
                                    </a>
                                    <?php if ($admin['id'] !== 'U90001'): // Prevent deleting main admin ?>
                                        <a href="#" class="btn-danger btn-sm" title="Revoke Access" onclick="return confirm('Revoke admin access for this user?')">
                                            <i class="fa-solid fa-user-slash"></i>
                                        </a>
                                    <?php endif; ?>
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
