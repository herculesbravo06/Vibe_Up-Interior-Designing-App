<?php
// admin/index.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

// Fetch Statistics
// Clients count
$stmt = $conn->query("SELECT COUNT(*) as count FROM user WHERE role = 'user'");
$user_count = $stmt->fetch()['count'];

// Total Users count (All roles)
$stmt = $conn->query("SELECT COUNT(*) as count FROM user");
$total_all_users = $stmt->fetch()['count'];

// Online Customers (Last 5 minutes)
$stmt = $conn->query("SELECT COUNT(*) as count FROM user WHERE role = 'user' AND last_activity > DATE_SUB(NOW(), INTERVAL 5 MINUTE)");
$online_customers = $stmt->fetch()['count'];

// Online Designers (Last 5 minutes)
$stmt = $conn->query("SELECT COUNT(*) as count FROM user WHERE role = 'designer' AND last_activity > DATE_SUB(NOW(), INTERVAL 5 MINUTE)");
$online_designers = $stmt->fetch()['count'];

// Total Designers
$stmt = $conn->query("SELECT COUNT(*) as count FROM user WHERE role = 'designer'");
$designer_count = $stmt->fetch()['count'];

// Pending Designer Requests
$stmt = $conn->query("SELECT COUNT(*) as count FROM designer_request WHERE status = 'pending'");
$pending_requests = $stmt->fetch()['count'];

// Total Projects
$stmt = $conn->query("SELECT COUNT(*) as count FROM project");
$total_projects = $stmt->fetch()['count'];

// Fetch Ratings Distribution for Pie Chart
$ratings = [1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0];
$stmt = $conn->query("SELECT rating, COUNT(*) as count FROM feedback GROUP BY rating");
while ($row = $stmt->fetch()) {
    if (isset($ratings[$row['rating']])) {
        $ratings[$row['rating']] = (int)$row['count'];
    }
}
$rating_data = array_values($ratings);

?>

<div class="page-header">
    <h1 class="page-title">Admin Dashboard</h1>
    <div class="date-display" style="color: var(--text-muted); font-weight: 500;">
        <i class="fa-regular fa-calendar"></i> <?= date('F d, Y') ?>
    </div>
</div>

<div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));">
    <a href="users.php" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon icon-blue">
                <i class="fa-solid fa-users"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($user_count) ?></h3>
                <p>Clients</p>
            </div>
        </div>
    </a>

    <a href="users.php?role=all" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6;">
                <i class="fa-solid fa-user-group"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($total_all_users) ?></h3>
                <p>Total Users</p>
            </div>
        </div>
    </a>
    
    <a href="users.php?filter=online" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">
                <i class="fa-solid fa-signal"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($online_customers) ?></h3>
                <p>Online Customers</p>
            </div>
            <div style="position:absolute; top:10px; right:10px;"><i class="fa-solid fa-circle" style="color:#10b981; font-size:0.5rem; animation: pulse 2s infinite;"></i></div>
        </div>
    </a>

    <a href="designers.php?filter=online" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(236, 72, 153, 0.1); color: #ec4899;">
                <i class="fa-solid fa-headset"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($online_designers) ?></h3>
                <p>Online Designers</p>
            </div>
            <div style="position:absolute; top:10px; right:10px;"><i class="fa-solid fa-circle" style="color:#ec4899; font-size:0.5rem; animation: pulse 2s infinite;"></i></div>
        </div>
    </a>
    
    <a href="designers.php" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon icon-pink">
                <i class="fa-solid fa-pen-nib"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($designer_count) ?></h3>
                <p>Total Designers</p>
            </div>
        </div>
    </a>
    
    <a href="projects.php" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon icon-green">
                <i class="fa-solid fa-folder-open"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($total_projects) ?></h3>
                <p>Total Projects</p>
            </div>
        </div>
    </a>

    <a href="designer_requests.php" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon icon-yellow">
                <i class="fa-solid fa-clock-rotate-left"></i>
            </div>
            <div class="stat-info">
                <h3><?= number_format($pending_requests) ?></h3>
                <p>Pending Requests</p>
            </div>
        </div>
    </a>

    <a href="ai_logs.php" class="stat-card-link">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">
                <i class="fa-solid fa-wand-magic-sparkles"></i>
            </div>
            <div class="stat-info">
                <?php
                $stmt = $conn->query("SELECT COUNT(*) FROM generated_images");
                $ai_count = $stmt->fetchColumn();
                ?>
                <h3><?= number_format($ai_count) ?></h3>
                <p>AI Designs</p>
            </div>
        </div>
    </a>
</div>

<style>
@keyframes pulse {
    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
    70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
}
</style>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; margin-bottom: 2rem;">
    <!-- Main Graph -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">System Overview (Core Stats)</h3>
        </div>
        <div class="card-body">
            <canvas id="overviewChart" style="width: 100%; height: 300px;"></canvas>
        </div>
    </div>
    
    <!-- Pie Chart -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Feedback Ratings</h3>
        </div>
        <div class="card-body">
            <canvas id="ratingChart" style="width: 100%; height: 300px;"></canvas>
        </div>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
    <!-- Recent Projects -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Recent Designers</h3>
        </div>
        <div class="card-body" style="padding: 0;">
            <?php
            $recent_stmt = $conn->query("
                SELECT u.name, d.bio, d.rating 
                FROM user u 
                JOIN designer d ON u.id = d.user_id 
                WHERE u.role = 'designer' 
                ORDER BY u.created_at DESC 
                LIMIT 5
            ");
            if ($recent_stmt->rowCount() > 0) {
                echo '<ul style="list-style: none;">';
                while ($row = $recent_stmt->fetch()) {
                    echo '<li style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;">';
                    $bio = strlen($row['bio']) > 30 ? substr($row['bio'], 0, 30) . '...' : (string)$row['bio'];
                    echo '<div><div style="font-weight: 600;">'.htmlspecialchars((string)$row['name']).'</div><div style="font-size: 0.8rem; color: var(--text-muted);">'.htmlspecialchars($bio).'</div></div>';
                    echo '<div class="badge badge-active"><i class="fa-solid fa-star"></i> '.$row['rating'].'</div>';
                    echo '</li>';
                }
                echo '</ul>';
            } else {
                echo '<div style="padding: 1.5rem; color: var(--text-muted); text-align: center;">No designers found.</div>';
            }
            ?>
        </div>
    </div>

    <!-- Project Growth -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Project Growth (30 Days)</h3>
        </div>
        <div class="card-body">
            <canvas id="growthChart" style="width: 100%; height: 300px;"></canvas>
        </div>
    </div>
</div>

<div class="card" style="margin-top: 2rem;">
    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
        <h3 class="card-title">System Activity Feed</h3>
        <a href="activity_logs.php" style="font-size: 0.8rem; color: var(--primary); text-decoration: none;">View All <i class="fa-solid fa-arrow-right"></i></a>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Target</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $log_stmt = $conn->query("
                        SELECT l.*, u.name as actor_name 
                        FROM activity_logs l 
                        LEFT JOIN user u ON l.actor_id = u.id 
                        ORDER BY l.created_at DESC 
                        LIMIT 5
                    ");
                    while($log = $log_stmt->fetch()) {
                        echo '<tr>';
                        echo '<td style="font-size: 0.8rem;">'.date('H:i:s', strtotime($log['created_at'])).'</td>';
                        echo '<td style="font-weight: 500;">'.htmlspecialchars($log['actor_name'] ?? 'System').'</td>';
                        echo '<td>'.htmlspecialchars($log['action']).'</td>';
                        echo '<td>'.htmlspecialchars($log['entity_type']).' #'.htmlspecialchars($log['entity_id'] ?? '').'</td>';
                        echo '</tr>';
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // Bar Chart (Overview)
    const overviewCtx = document.getElementById('overviewChart');
    if (overviewCtx) {
        new Chart(overviewCtx, {
            type: 'bar',
            data: {
                labels: ['Clients', 'Designers', 'Pending', 'Projects'],
                datasets: [{
                    label: 'Count',
                    data: [<?= $user_count ?>, <?= $designer_count ?>, <?= $pending_requests ?>, <?= $total_projects ?>],
                    backgroundColor: ['#6366f1', '#ec4899', '#f59e0b', '#10b981'],
                    borderRadius: 8,
                    barThickness: 40
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
                    x: { grid: { display: false }, ticks: { color: '#94a3b8' } }
                }
            }
        });
    }

    // Pie Chart (Ratings)
    const ratingCtx = document.getElementById('ratingChart');
    if (ratingCtx) {
        new Chart(ratingCtx, {
            type: 'doughnut',
            data: {
                labels: ['1 ⭐', '2 ⭐', '3 ⭐', '4 ⭐', '5 ⭐'],
                datasets: [{
                    data: <?= json_encode($rating_data) ?>,
                    backgroundColor: ['#ef4444', '#f59e0b', '#3b82f6', '#8b5cf6', '#10b981'],
                    borderWidth: 0,
                    hoverOffset: 15
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { color: '#94a3b8', padding: 20 } }
                },
                cutout: '70%'
            }
        });
    }

    // Growth Chart (Line) - Real Time data from the last 4 weeks
    <?php
    $growth_data = [];
    $growth_labels = [];
    for ($i = 3; $i >= 0; $i--) {
        $week_start = date('Y-m-d', strtotime("-$i week"));
        $week_end = date('Y-m-d', strtotime("-".($i-1)." week"));
        if ($i == 0) $week_end = date('Y-m-d', strtotime("+1 day"));
        
        $stmt = $conn->prepare("SELECT COUNT(*) as count FROM project WHERE created_at >= :start AND created_at < :end");
        $stmt->execute(['start' => $week_start, 'end' => $week_end]);
        $growth_data[] = (int)$stmt->fetch()['count'];
        $growth_labels[] = 'Week ' . (4 - $i);
    }
    ?>
    const growthCtx = document.getElementById('growthChart');
    if (growthCtx) {
        new Chart(growthCtx, {
            type: 'line',
            data: {
                labels: <?= json_encode($growth_labels) ?>,
                datasets: [{
                    label: 'New Projects',
                    data: <?= json_encode($growth_data) ?>,
                    borderColor: '#00ffd5',
                    backgroundColor: 'rgba(0, 255, 213, 0.1)',
                    tension: 0.4,
                    fill: true,
                    pointRadius: 5,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', stepSize: 1 } },
                    x: { grid: { display: false }, ticks: { color: '#94a3b8' } }
                }
            }
        });
    }
});
</script>

<?php require_once '../includes/footer.php'; ?>
