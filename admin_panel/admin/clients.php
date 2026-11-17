<?php
// admin/clients.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch ONLY clients
$stmt = $conn->query("SELECT * FROM user WHERE role = 'user' ORDER BY created_at DESC");
$clients = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Direct Client Management</h1>
    <div style="color: var(--text-muted);">Filtered view for 'role = user' accounts</div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">Active Clients</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Client Detail</th>
                        <th>Email</th>
                        <th>Contact</th>
                        <th>Joined</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($clients as $client): ?>
                        <tr>
                            <td>
                                <div style="font-weight: 600;"><?= htmlspecialchars((string)$client['name']) ?></div>
                                <div style="font-size: 0.75rem; color: var(--text-muted);">UID: <?= $client['id'] ?></div>
                            </td>
                            <td><?= htmlspecialchars((string)$client['email']) ?></td>
                            <td><?= htmlspecialchars((string)$client['phone']) ?></td>
                            <td><?= date('M d, Y', strtotime($client['created_at'])) ?></td>
                            <td>
                                <div class="action-btns">
                                    <a href="user_details.php?id=<?= $client['id'] ?>" class="btn-primary btn-sm"><i class="fa-solid fa-eye"></i></a>
                                    <a href="edit_user.php?id=<?= $client['id'] ?>" class="btn-secondary btn-sm"><i class="fa-solid fa-pen"></i></a>
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
