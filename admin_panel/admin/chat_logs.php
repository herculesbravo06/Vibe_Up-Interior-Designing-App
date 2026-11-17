<?php
// admin/chat_logs.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch chat messages with user names
$stmt = $conn->query("
    SELECT m.*, u.name as sender_name, r.name as receiver_name 
    FROM messages m 
    JOIN user u ON m.sender_id = u.id 
    JOIN user r ON m.receiver_id = r.id 
    ORDER BY m.timestamp DESC 
    LIMIT 100
");
$chats = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Platform Chat Transcripts</h1>
    <div style="color: var(--text-muted);">Monitor all communications between clients and designers</div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">Recent Conversations</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Sender</th>
                        <th>Receiver</th>
                        <th>Message Preview</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($chats)): ?>
                        <tr><td colspan="5" style="text-align:center; padding: 2rem;">No chat records found.</td></tr>
                    <?php else: ?>
                        <?php foreach ($chats as $chat): ?>
                            <tr>
                                <td style="font-size: 0.8rem;"><?= date('M d, H:i', strtotime($chat['timestamp'])) ?></td>
                                <td style="font-weight: 500;"><?= htmlspecialchars((string)$chat['sender_name']) ?></td>
                                <td style="font-weight: 500;"><?= htmlspecialchars((string)$chat['receiver_name']) ?></td>
                                <td style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                    <?= htmlspecialchars((string)$chat['message_text']) ?>
                                </td>
                                <td>
                                    <button class="btn-secondary btn-sm" onclick="alert('Full transcript view is available in secure audit mode.')">
                                        <i class="fa-solid fa-file-lines"></i>
                                    </button>
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
