<?php
// admin/ai_logs.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch AI design prompts
$stmt = $conn->query("
    SELECT ai.*, u.name as user_name 
    FROM ai_design_suggestion ai 
    JOIN user u ON ai.user_id = u.id 
    ORDER BY ai.created_at DESC 
    LIMIT 100
");
$logs = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">AI Design Generation Logs</h1>
    <div style="color: var(--text-muted);">Track all AI prompts and generated contents</div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">AI Activity</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>User</th>
                        <th>Prompt Snippet</th>
                        <th>Result Preview</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($logs)): ?>
                        <tr><td colspan="5" style="text-align:center; padding: 2rem;">No AI requests logged yet.</td></tr>
                    <?php else: ?>
                        <?php foreach ($logs as $log): ?>
                            <tr>
                                <td style="font-size: 0.8rem;"><?= date('M d, Y', strtotime($log['created_at'])) ?></td>
                                <td style="font-weight: 500;"><?= htmlspecialchars((string)$log['user_name']) ?></td>
                                <td style="max-width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                    <?= htmlspecialchars((string)$log['prompt']) ?>
                                </td>
                                <td>
                                    <i class="fa-solid fa-image" style="color: var(--primary);"></i> Generated Content #<?= $log['id'] ?>
                                </td>
                                <td>
                                    <button class="btn-primary btn-sm" onclick="alert('Viewing generated image asset...')">
                                        <i class="fa-solid fa-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
