<?php
// admin/activity_logs.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch all logs
$stmt = $conn->query("
    SELECT l.*, u.name as actor_name 
    FROM activity_logs l 
    LEFT JOIN user u ON l.actor_id = u.id 
    ORDER BY l.created_at DESC 
    LIMIT 200
");
$logs = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">System Activity Logs</h1>
    <div class="date-display" style="color: var(--text-muted); font-weight: 500;">
        <i class="fa-solid fa-shield-halved"></i> Audit Trail
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">Recent Actions (Last 200)</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Actor</th>
                        <th>Action</th>
                        <th>Entity</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($logs)): ?>
                        <tr><td colspan="5" style="text-align: center; padding: 2rem;">No activity logs found.</td></tr>
                    <?php else: ?>
                        <?php foreach ($logs as $log): ?>
                            <tr>
                                <td style="font-size: 0.8rem; white-space: nowrap;"><?= date('M d, H:i:s', strtotime($log['created_at'])) ?></td>
                                <td style="font-weight: 600;"><?= htmlspecialchars($log['actor_name'] ?? 'System') ?></td>
                                <td>
                                    <span class="badge" style="background: rgba(99, 102, 241, 0.1); color: #6366f1;">
                                        <?= strtoupper(htmlspecialchars($log['action'])) ?>
                                    </span>
                                </td>
                                <td><?= htmlspecialchars($log['entity_type']) ?> #<?= htmlspecialchars($log['entity_id'] ?? 'N/A') ?></td>
                                <td style="font-size: 0.9rem; color: var(--text-muted);"><?= htmlspecialchars($log['details'] ?? '-') ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
