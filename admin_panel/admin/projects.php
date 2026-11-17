<?php
// admin/projects.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch all projects
$stmt = $conn->query("
    SELECT p.*, u.name as customer_name 
    FROM project p 
    JOIN user u ON p.user_id = u.id 
    ORDER BY p.created_at DESC
");
$projects = $stmt->fetchAll();
?>

<div class="page-header">
    <h1 class="page-title">Manage Projects</h1>
    <div class="action-btns">
        <a href="edit_project.php" class="btn-primary">
            <i class="fa-solid fa-plus"></i> Create New Project
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">All Interior Design Projects</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Project Name</th>
                        <th>Customer</th>
                        <th>Status</th>
                        <th>Budget</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($projects as $project): ?>
                        <tr>
                            <td><code style="color: var(--accent);"><?= $project['id'] ?></code></td>
                            <td>
                                <div style="font-weight: 600;"><?= htmlspecialchars((string)$project['name']) ?></div>
                                <div style="font-size: 0.75rem; color: var(--text-muted);">
                                    <?= htmlspecialchars(strlen((string)$project['description']) > 40 ? substr((string)$project['description'], 0, 40) . '...' : (string)$project['description']) ?>
                                </div>
                            </td>
                            <td><?= htmlspecialchars((string)$project['customer_name']) ?></td>
                            <td>
                                <span class="badge badge-<?= $project['status'] ?>">
                                    <?= ucfirst($project['status']) ?>
                                </span>
                            </td>
                            <td style="font-weight: 600;">
                                <?= $project['currency'] ?> <?= number_format($project['total_estimated_cost'], 2) ?>
                            </td>
                            <td><?= date('M d, Y', strtotime($project['created_at'])) ?></td>
                            <td>
                                <div class="action-btns">
                                    <a href="project_details.php?id=<?= $project['id'] ?>" class="btn-primary btn-sm" title="Project Depth Info" style="padding: 5px 10px; min-width: unset;">
                                        <i class="fa-solid fa-circle-info"></i>
                                    </a>
                                    <a href="edit_project.php?id=<?= $project['id'] ?>" class="btn-secondary btn-sm" title="Edit Content" style="padding: 5px 10px; min-width: unset; background: var(--secondary); color: var(--text); border: 1px solid var(--border);">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <a href="delete_project.php?id=<?= $project['id'] ?>" class="btn-danger btn-sm" title="Delete" onclick="return confirm('Permanently delete this project and all associated data?')" style="padding: 5px 10px; min-width: unset;">
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
