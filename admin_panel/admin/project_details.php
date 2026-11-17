<?php
// admin/project_details.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';
$project = null;

if ($id) {
    $stmt = $conn->prepare("
        SELECT p.*, 
               u.name as customer_name, u.email as customer_email, u.phone as customer_phone,
               d_u.name as designer_name,
               r.length_m, r.width_m, r.height_m, r.name as room_name
        FROM project p
        LEFT JOIN user u ON p.user_id = u.id
        LEFT JOIN designer d ON p.designer_id = d.id
        LEFT JOIN user d_u ON d.user_id = d_u.id
        LEFT JOIN room r ON p.id = r.project_id
        WHERE p.id = :id
        LIMIT 1
    ");
    $stmt->execute(['id' => $id]);
    $project = $stmt->fetch();
    
    // Supplement missing fields for the UI
    if ($project) {
        $project['assistance_type'] = $project['designer_id'] ? 'Designer Consultation' : 'AI-Powered DIY';
        if ($project['length_m']) {
            $project['room_dimensions'] = $project['length_m'] . "m x " . $project['width_m'] . "m x " . $project['height_m'] . "m";
        } else {
            $project['room_dimensions'] = 'Not Specified';
        }
    }
}

if (!$project) {
    header("Location: projects.php");
    exit;
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <div style="display: flex; flex-direction: column;">
        <span style="color: var(--text-muted); font-size: 0.9rem;">Project ID: <?= $project['id'] ?></span>
        <h1 class="page-title"><?= htmlspecialchars($project['name']) ?></h1>
    </div>
    <div class="action-btns">
        <a href="edit_project.php?id=<?= $project['id'] ?>" class="btn-primary">
            <i class="fa-solid fa-pen-to-square"></i> Edit Project
        </a>
        <a href="projects.php" class="btn-secondary">
            <i class="fa-solid fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1.2fr; gap: 1.5rem;">
    <!-- Main Info -->
    <div class="column">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Project Overview</h3>
            </div>
            <div class="card-body">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                    <div>
                        <p style="margin-bottom: 0.25rem; color: var(--text-muted); font-size: 0.85rem;">Service Type</p>
                        <p style="font-weight: 600; font-size: 1.1rem; color: var(--primary);">
                            <i class="fa-solid fa-wand-magic-sparkles"></i> <?= $project['assistance_type'] ?>
                        </p>
                    </div>
                    <div>
                        <p style="margin-bottom: 0.25rem; color: var(--text-muted); font-size: 0.85rem;">Current Status</p>
                        <span class="badge badge-<?= $project['status'] ?>" style="font-size: 0.9rem; padding: 0.5rem 1rem;">
                            <?= ucfirst(str_replace('_', ' ', $project['status'])) ?>
                        </span>
                    </div>
                    <div>
                        <p style="margin-bottom: 0.25rem; color: var(--text-muted); font-size: 0.85rem;">Room Dimensions</p>
                        <p style="font-weight: 500;"><?= $project['room_dimensions'] ?: 'Not Specified' ?></p>
                    </div>
                    <div>
                        <p style="margin-bottom: 0.25rem; color: var(--text-muted); font-size: 0.85rem;">Estimated Budget</p>
                        <p style="font-weight: 700; color: var(--success); font-size: 1.2rem;">
                            ₹<?= number_format($project['total_estimated_cost']) ?>
                        </p>
                    </div>
                </div>
                
                <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">
                
                <h4 style="margin-bottom: 1rem;">Project Progress</h4>
                <div style="width: 100%; height: 10px; background: var(--secondary); border-radius: 5px; overflow: hidden; margin-bottom: 0.5rem;">
                    <div style="width: <?= $project['status'] == 'completed' ? '100%' : ($project['status'] == 'in_progress' ? '60%' : '20%') ?>; height: 100%; background: var(--primary);"></div>
                </div>
                <p style="font-size: 0.85rem; color: var(--text-muted);">Last updated: <?= date('M d, Y', strtotime($project['updated_at'])) ?></p>
            </div>
        </div>

        <div class="card" style="margin-top: 1.5rem;">
            <div class="card-header">
                <h3 class="card-title">Design Notes / Technical Info</h3>
            </div>
            <div class="card-body">
                <p style="color: var(--text-muted);">Detailed design parameters and floor plans for this <?= strtolower($project['assistance_type']) ?> project are stored in the system's encrypted storage vault.</p>
                <!-- In a real app, you'd list furniture items, AI prompt results, etc here -->
            </div>
        </div>
    </div>

    <!-- Sidebar Info -->
    <div class="column">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Customer Details</h3>
            </div>
            <div class="card-body">
                <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;">
                    <div style="width: 50px; height: 50px; border-radius: 12px; background: var(--secondary); display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
                        <i class="fa-solid fa-user"></i>
                    </div>
                    <div>
                        <h4 style="margin-bottom: 0.1rem;"><?= htmlspecialchars($project['customer_name']) ?></h4>
                        <p style="font-size: 0.85rem; color: var(--text-muted);">Client Since <?= date('Y', strtotime($project['created_at'])) ?></p>
                    </div>
                </div>
                <div style="font-size: 0.9rem;">
                    <p style="margin-bottom: 0.75rem;"><i class="fa-solid fa-envelope" style="width: 20px;"></i> <?= $project['customer_email'] ?></p>
                    <p><i class="fa-solid fa-phone" style="width: 20px;"></i> <?= $project['customer_phone'] ?></p>
                </div>
            </div>
        </div>

        <div class="card" style="margin-top: 1.5rem;">
            <div class="card-header">
                <h3 class="card-title">Assigned Designer</h3>
            </div>
            <div class="card-body">
                <?php if ($project['designer_name']): ?>
                    <div style="display: flex; align-items: center; gap: 1rem;">
                        <div style="width: 50px; height: 50px; border-radius: 50%; background: rgba(99, 102, 241, 0.1); border: 2px solid var(--primary); display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: var(--primary);">
                            <i class="fa-solid fa-pen-nib"></i>
                        </div>
                        <div>
                            <h4 style="margin-bottom: 0.1rem;"><?= htmlspecialchars($project['designer_name']) ?></h4>
                            <p style="font-size: 0.85rem; color: var(--primary);">Professional Designer</p>
                        </div>
                    </div>
                <?php else: ?>
                    <p style="color: var(--text-muted); text-align: center; padding: 1rem;">No designer assigned yet.</p>
                    <a href="edit_project.php?id=<?= $project['id'] ?>" class="btn-secondary" style="width: 100%; margin-top: 1rem; text-align: center;">Assign Now</a>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
