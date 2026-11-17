<?php
// admin/users.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Role and Filter Logic
$role_filter = $_GET['role'] ?? 'all';
$status_filter = $_GET['filter'] ?? 'all';

$query = "SELECT id, name, email, username, role, created_at, last_activity FROM user";
$params = [];

$where_clauses = [];
if ($role_filter !== 'all') {
    $where_clauses[] = "role = :role";
    $params['role'] = $role_filter;
}
if ($status_filter === 'online') {
    $where_clauses[] = "last_activity > DATE_SUB(NOW(), INTERVAL 5 MINUTE)";
}

if (!empty($where_clauses)) {
    $query .= " WHERE " . implode(" AND ", $where_clauses);
}

$query .= " ORDER BY created_at DESC";

$stmt = $conn->prepare($query);
$stmt->execute($params);
$users = $stmt->fetchAll();
?>

<div class="page-header">
    <div style="display: flex; flex-direction: column; gap: 5px;">
        <h1 class="page-title"><?= $status_filter === 'online' ? 'Online ' : '' ?><?= $role_filter === 'all' ? 'All Users' : ucfirst($role_filter) . 's' ?></h1>
        <div style="display: flex; gap: 10px; align-items: center;">
            <span style="font-size: 0.9rem; color: var(--text-muted);">Filter by Role:</span>
            <select onchange="location.href='users.php?role=' + this.value" style="padding: 5px 10px; border-radius: 5px; border: 1px solid var(--border); background: var(--secondary); color: var(--text);">
                <option value="all" <?= $role_filter === 'all' ? 'selected' : '' ?>>All Users</option>
                <option value="user" <?= $role_filter === 'user' ? 'selected' : '' ?>>Clients</option>
                <option value="designer" <?= $role_filter === 'designer' ? 'selected' : '' ?>>Designers</option>
                <option value="admin" <?= $role_filter === 'admin' ? 'selected' : '' ?>>Admins</option>
            </select>
        </div>
    </div>
    <div class="action-btns">
        <a href="add_user.php" class="btn-primary">
            <i class="fa-solid fa-user-plus"></i> Add New User
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">All Registered Users</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Joined Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $user): ?>
                        <tr>
                            <td>
                                <?php 
                                $is_online = (isset($user['last_activity']) && strtotime($user['last_activity']) > (time() - 300));
                                ?>
                                <span class="badge" style="background: <?= $is_online ? 'rgba(16, 185, 129, 0.1)' : 'rgba(148, 163, 184, 0.1)' ?>; color: <?= $is_online ? '#10b981' : '#94a3b8' ?>; border: 1px solid <?= $is_online ? '#10b981' : 'transparent' ?>;">
                                    <i class="fa-solid fa-circle" style="font-size: 0.5rem; margin-right: 5px;"></i>
                                    <?= $is_online ? 'Online' : 'Offline' ?>
                                </span>
                            </td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 0.75rem;">
                                    <div style="width: 32px; height: 32px; border-radius: 50%; background: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 0.8rem; font-weight: 600; color: #fff;">
                                        <?= strtoupper(substr($user['name'], 0, 1)) ?>
                                    </div>
                                    <?= htmlspecialchars((string)$user['name']) ?>
                                </div>
                            </td>
                            <td><?= htmlspecialchars((string)$user['email']) ?></td>
                            <td><?= htmlspecialchars((string)$user['username']) ?></td>
                            <td>
                                <span class="badge badge-<?= $user['role'] == 'admin' ? 'completed' : ($user['role'] == 'designer' ? 'active' : 'planning') ?>">
                                    <?= ucfirst($user['role']) ?>
                                </span>
                            </td>
                            <td><?= date('M d, Y', strtotime($user['created_at'])) ?></td>
                            <td>
                                <div class="action-btns">
                                    <a href="user_details.php?id=<?= $user['id'] ?>" class="btn-primary btn-sm" title="View Details" style="padding: 5px 10px; min-width: unset;">
                                        <i class="fa-solid fa-eye"></i>
                                    </a>
                                    <a href="edit_user.php?id=<?= $user['id'] ?>" class="btn-secondary btn-sm" title="Edit" style="padding: 5px 10px; min-width: unset; background: var(--secondary); color: var(--text); border: 1px solid var(--border);">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <?php if ($user['role'] !== 'admin'): ?>
                                        <a href="delete_user.php?id=<?= $user['id'] ?>" class="btn-danger btn-sm" title="Delete" onclick="return confirm('Are you sure you want to delete this user? This cannot be undone.')" style="padding: 5px 10px; min-width: unset;">
                                            <i class="fa-solid fa-trash"></i>
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
