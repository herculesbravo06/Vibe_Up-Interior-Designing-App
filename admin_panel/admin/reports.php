<?php
// admin/reports.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';

$message = '';
$report_data = [];
$report_type = $_POST['report_type'] ?? 'projects';
$status = $_POST['status'] ?? 'all';
$category = $_POST['category'] ?? 'all';
$min_rating = $_POST['min_rating'] ?? 0;
$from_date = $_POST['from_date'] ?? date('Y-m-01');
$to_date = $_POST['to_date'] ?? date('Y-m-t');

if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['generate'])) {
    try {
        if ($report_type == 'projects') {
            $query = "SELECT p.*, u.name as customer_name FROM project p LEFT JOIN user u ON p.user_id = u.id WHERE p.created_at BETWEEN :from_date AND :to_date";
            if ($status != 'all') $query .= " AND p.status = :status";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            if ($status != 'all') $stmt->bindParam(':status', $status);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'users') {
            $stmt = $conn->prepare("SELECT * FROM user WHERE role = 'user' AND created_at BETWEEN :from_date AND :to_date ORDER BY created_at DESC");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'designers') {
            $stmt = $conn->prepare("SELECT u.*, d.* FROM user u LEFT JOIN designer d ON u.id = d.user_id WHERE u.role = 'designer' AND u.created_at BETWEEN :from_date AND :to_date ORDER BY created_at DESC");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'financial') {
            // Financial Performance: Revenue per project status and designer
            $stmt = $conn->prepare("
                SELECT 
                    status, 
                    COUNT(*) as project_count, 
                    SUM(total_estimated_cost) as total_budget,
                    AVG(total_estimated_cost) as avg_budget
                FROM project 
                WHERE created_at BETWEEN :from_date AND :to_date
                GROUP BY status
            ");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'designers') {
            // Designer Performance: Ratings, experience, and project load
            $stmt = $conn->prepare("
                SELECT 
                    u.name, d.experience_years, d.rating, d.specialization,
                    (SELECT COUNT(*) FROM project WHERE designer_id = u.id) as active_projects
                FROM designer d
                JOIN user u ON d.user_id = u.id
                WHERE u.created_at BETWEEN :from_date AND :to_date
                ORDER BY d.rating DESC
            ");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'inventory') {
            $query = "SELECT * FROM catalogue_items WHERE created_at BETWEEN :from_date AND :to_date";
            if ($category != 'all') $query .= " AND category = :category";
            $query .= " ORDER BY category, name ASC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            if ($category != 'all') $stmt->bindParam(':category', $category);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'categories') {
            $stmt = $conn->prepare("SELECT * FROM catalogue_categories WHERE created_at BETWEEN :from_date AND :to_date ORDER BY name ASC");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'feedback') {
            $query = "SELECT f.*, u1.name as from_user, u2.name as to_user FROM feedback f 
                      LEFT JOIN user u1 ON f.from_user_id = u1.id 
                      LEFT JOIN user u2 ON f.to_user_id = u2.id 
                      WHERE f.created_at BETWEEN :from_date AND :to_date";
            if ($min_rating > 0) $query .= " AND f.rating >= :min_rating";
            $query .= " ORDER BY f.created_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            if ($min_rating > 0) $stmt->bindParam(':min_rating', $min_rating);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'messages') {
            $stmt = $conn->prepare("SELECT m.*, u1.name as sender_name, u2.name as receiver_name FROM messages m 
                                    JOIN user u1 ON m.sender_id = u1.id 
                                    JOIN user u2 ON m.receiver_id = u2.id 
                                    WHERE m.timestamp BETWEEN :from_date AND :to_date ORDER BY m.timestamp DESC");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'ai_prompts') {
            $stmt = $conn->prepare("SELECT a.*, u.name as user_name FROM ai_prompts a 
                                    JOIN user u ON a.user_id = u.id 
                                    WHERE a.created_at BETWEEN :from_date AND :to_date ORDER BY a.created_at DESC");
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'requests') {
            $query = "SELECT r.*, u.name as user_name, p.name as project_name FROM designer_request r 
                      JOIN user u ON r.user_id = u.id 
                      LEFT JOIN project p ON r.project_id = p.id
                      WHERE r.created_at BETWEEN :from_date AND :to_date";
            if ($status != 'all') $query .= " AND r.status = :status";
            $query .= " ORDER BY r.created_at DESC";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':from_date', $from_date);
            $stmt->bindParam(':to_date', $to_date);
            if ($status != 'all') $stmt->bindParam(':status', $status);
            $stmt->execute();
            $report_data = $stmt->fetchAll();
        } elseif ($report_type == 'system') {
            // Aggregated Summary Data
            $report_data = [
                'Total Users' => $conn->query("SELECT COUNT(*) FROM user WHERE role='user'")->fetchColumn(),
                'Total Designers' => $conn->query("SELECT COUNT(*) FROM user WHERE role='designer'")->fetchColumn(),
                'Total Projects' => $conn->query("SELECT COUNT(*) FROM project")->fetchColumn(),
                'Total Items' => $conn->query("SELECT COUNT(*) FROM catalogue_items")->fetchColumn(),
                'Pending Requests' => $conn->query("SELECT COUNT(*) FROM designer_request WHERE status='pending'")->fetchColumn(),
                'In-Progress Projects' => $conn->query("SELECT COUNT(*) FROM project WHERE status='in_progress'")->fetchColumn(),
                'Completed Projects' => $conn->query("SELECT COUNT(*) FROM project WHERE status='completed'")->fetchColumn()
            ];
        }
        
        $print_url = "generate_report.php?type=$report_type&status=$status&category=$category&min_rating=$min_rating&from=$from_date&to=$to_date";
        $message = '<div class="alert alert-success" style="margin-top: 20px;"><i class="fa-solid fa-circle-check"></i> Found ' . count($report_data) . ' records. <a href="' . $print_url . '" target="_blank" class="btn-primary" style="display:inline-block; margin-left:15px; padding: 5px 15px; font-size: 0.85rem;"><i class="fa-solid fa-file-pdf"></i> View & Print PDF Report</a></div>';
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger" style="margin-top: 20px;"><i class="fa-solid fa-circle-exclamation"></i> Error: ' . $e->getMessage() . '</div>';
    }
}
?>

<div class="page-header">
    <h1 class="page-title">Reports & Analytics</h1>
    <div class="action-btns">
        <a href="generate_report.php?type=system" target="_blank" class="btn-primary" style="background: var(--secondary); color: var(--text); border: 1px solid var(--border);">
            <i class="fa-solid fa-file-invoice"></i> System Summary PDF
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="fa-solid fa-filter" style="color:var(--primary);"></i> Report Filters</h3>
    </div>
    <div class="card-body">
        <form method="POST" action="">
            <div class="scroll-x" style="padding-bottom: 1rem; margin-bottom: 1.5rem; width: 100%;">
                <div style="display: flex; gap: 1.5rem; min-width: max-content; padding-right: 3rem; padding-left: 0.5rem;">
                    <!-- Report Type -->
                    <div class="form-group" style="min-width: 250px;">
                        <label class="form-label">Report Type</label>
                        <select name="report_type" id="report_type" class="form-control" onchange="toggleFilters()">
                            <option value="projects" <?= $report_type == 'projects' ? 'selected' : '' ?>>Projects (All Details)</option>
                            <option value="financial" <?= $report_type == 'financial' ? 'selected' : '' ?>>Financial Performance (Revenue/Budgets)</option>
                            <option value="users" <?= $report_type == 'users' ? 'selected' : '' ?>>User Database (All Details)</option>
                            <option value="designers" <?= $report_type == 'designers' ? 'selected' : '' ?>>Designer Ratings & Performance</option>
                            <option value="requests" <?= $report_type == 'requests' ? 'selected' : '' ?>>Designer Requests</option>
                            <option value="inventory" <?= $report_type == 'inventory' ? 'selected' : '' ?>>Catalogue Items (Inventory Summary)</option>
                            <option value="categories" <?= $report_type == 'categories' ? 'selected' : '' ?>>Catalogue Categories</option>
                            <option value="feedback" <?= $report_type == 'feedback' ? 'selected' : '' ?>>Feedback Logs & Reviews</option>
                            <option value="messages" <?= $report_type == 'messages' ? 'selected' : '' ?>>Chat & Message Logs</option>
                            <option value="ai_prompts" <?= $report_type == 'ai_prompts' ? 'selected' : '' ?>>AI Prompt History</option>
                            <option value="system" <?= $report_type == 'system' ? 'selected' : '' ?>>Executive Summary</option>
                        </select>
                    </div>
                    
                    <!-- Status Filter -->
                    <div class="form-group filter-item filter-status" style="min-width: 180px;">
                        <label class="form-label">Filter Status</label>
                        <select name="status" class="form-control">
                            <option value="all" <?= $status == 'all' ? 'selected' : '' ?>>All Statuses</option>
                            <option value="pending" <?= $status == 'pending' ? 'selected' : '' ?>>Pending</option>
                            <option value="draft" <?= $status == 'draft' ? 'selected' : '' ?>>Draft</option>
                            <option value="in_progress" <?= $status == 'in_progress' ? 'selected' : '' ?>>In Progress</option>
                            <option value="completed" <?= $status == 'completed' ? 'selected' : '' ?>>Completed</option>
                            <option value="accepted" <?= $status == 'accepted' ? 'selected' : '' ?>>Accepted</option>
                            <option value="declined" <?= $status == 'declined' ? 'selected' : '' ?>>Declined</option>
                        </select>
                    </div>

                    <!-- Category Filter -->
                    <div class="form-group filter-item filter-category" style="display:none; min-width: 180px;">
                        <label class="form-label">Filter Category</label>
                        <select name="category" class="form-control">
                            <option value="all">All Categories</option>
                            <?php
                            $cats = $conn->query("SELECT name FROM catalogue_categories")->fetchAll();
                            foreach($cats as $c) {
                                $sel = ($category == $c['name']) ? 'selected' : '';
                                echo "<option value='".htmlspecialchars($c['name'])."' $sel>".htmlspecialchars($c['name'])."</option>";
                            }
                            ?>
                        </select>
                    </div>

                    <!-- Rating Filter -->
                    <div class="form-group filter-item filter-rating" style="display:none; min-width: 150px;">
                        <label class="form-label">Min Rating</label>
                        <select name="min_rating" class="form-control">
                            <option value="0" <?= $min_rating == 0 ? 'selected' : '' ?>>All Ratings</option>
                            <option value="4" <?= $min_rating == 4 ? 'selected' : '' ?>>4+ Stars</option>
                            <option value="3" <?= $min_rating == 3 ? 'selected' : '' ?>>3+ Stars</option>
                            <option value="2" <?= $min_rating == 2 ? 'selected' : '' ?>>2+ Stars</option>
                        </select>
                    </div>
                    
                    <!-- Date Range -->
                    <div class="form-group" style="min-width: 160px;">
                        <label class="form-label">From Date</label>
                        <input type="date" name="from_date" class="form-control" value="<?= htmlspecialchars($from_date) ?>">
                    </div>
                    <div class="form-group" style="min-width: 160px; margin-right: 2rem;">
                        <label class="form-label">To Date</label>
                        <input type="date" name="to_date" class="form-control" value="<?= htmlspecialchars($to_date) ?>">
                    </div>
                </div>
            </div>
            
            <div style="display: flex; gap: 1rem;">
                <button type="submit" name="generate" class="btn-primary" style="width: auto; padding: 0.75rem 2rem;">
                    <i class="fa-solid fa-wand-magic-sparkles"></i> Generate Preview
                </button>
                <button type="submit" name="export_pdf" class="btn-primary" style="width: auto; padding: 0.75rem 2rem; background: var(--secondary);">
                    <i class="fa-solid fa-file-pdf"></i> Download PDF
                </button>
            </div>
        </form>
    </div>
</div>

<?= $message ?>

<?php if (!empty($report_data)): ?>
<div class="card" style="margin-top: 2rem;">
    <div class="card-header">
        <h3 class="card-title">Preview: <?= ucfirst($report_type) ?> Report</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <?php if ($report_type == 'projects'): ?>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Customer</th>
                            <th>Status</th>
                            <th>Budget</th>
                            <th>Created At</th>
                        <?php elseif ($report_type == 'financial'): ?>
                            <th>Status</th>
                            <th>Project Count</th>
                            <th>Total Budget</th>
                            <th>Avg Budget</th>
                        <?php elseif ($report_type == 'users'): ?>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                        <?php elseif ($report_type == 'designers'): ?>
                            <th>Name</th>
                            <th>Rating</th>
                            <th>Exp (Yrs)</th>
                            <th>Specialization</th>
                            <th>Active Projects</th>
                        <?php elseif ($report_type == 'inventory'): ?>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Material</th>
                        <?php elseif ($report_type == 'categories'): ?>
                            <th>ID</th>
                            <th>Category Name</th>
                            <th>Image URL</th>
                            <th>Created At</th>
                        <?php elseif ($report_type == 'feedback'): ?>
                            <th>Feedback ID</th>
                            <th>From</th>
                            <th>To</th>
                            <th>Rating</th>
                            <th>Comment</th>
                        <?php elseif ($report_type == 'messages'): ?>
                            <th>Message ID</th>
                            <th>From</th>
                            <th>To</th>
                            <th>Message</th>
                            <th>Time</th>
                        <?php elseif ($report_type == 'ai_prompts'): ?>
                            <th>Prompt ID</th>
                            <th>User</th>
                            <th>Style</th>
                            <th>Status</th>
                            <th>Prompt Text</th>
                        <?php elseif ($report_type == 'requests'): ?>
                            <th>Req ID</th>
                            <th>Applicant</th>
                            <th>Project</th>
                            <th>Status</th>
                            <th>Date</th>
                        <?php elseif ($report_type == 'system'): ?>
                            <th>Metric</th>
                            <th>Value</th>
                        <?php endif; ?>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($report_type == 'system'): ?>
                        <?php foreach ($report_data as $metric => $val): ?>
                            <tr>
                                <td style="font-weight:600;"><?= $metric ?></td>
                                <td><span class="badge badge-active"><?= $val ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <?php foreach ($report_data as $row): ?>
                            <tr>
                                <?php if ($report_type == 'projects'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['name']) ?></td>
                                <td><?= htmlspecialchars((string)$row['customer_name']) ?></td>
                                <td><span class="badge badge-<?= $row['status'] ?>"><?= ucfirst($row['status']) ?></span></td>
                                <td>₹<?= number_format($row['currency'] == 'INR' ? $row['total_estimated_cost'] : $row['total_estimated_cost'] * 83) ?></td>
                                <td><?= date('M d, Y', strtotime($row['created_at'])) ?></td>
                            <?php elseif ($report_type == 'financial'): ?>
                                <td><span class="badge badge-active"><?= ucfirst($row['status']) ?></span></td>
                                <td><?= $row['project_count'] ?></td>
                                <td style="color:var(--success); font-weight:600;">₹<?= number_format($row['total_budget']) ?></td>
                                <td>₹<?= number_format($row['avg_budget']) ?></td>
                            <?php elseif ($report_type == 'users'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['name']) ?></td>
                                <td><?= htmlspecialchars((string)$row['username']) ?></td>
                                <td><?= htmlspecialchars((string)$row['email']) ?></td>
                                <td><?= htmlspecialchars((string)$row['phone']) ?></td>
                                <td><span class="badge badge-active"><?= ucfirst($row['role']) ?></span></td>
                            <?php elseif ($report_type == 'designers'): ?>
                                <td style="font-weight: 600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                                <td style="color:var(--warning);"><i class="fa-solid fa-star"></i> <?= $row['rating'] ?>/5</td>
                                <td><?= $row['experience_years'] ?> Years</td>
                                <td><?= htmlspecialchars((string)$row['specialization']) ?></td>
                                <td><span class="badge badge-planning"><?= $row['active_projects'] ?></span></td>
                            <?php elseif ($report_type == 'inventory'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['name']) ?></td>
                                <td><?= htmlspecialchars((string)$row['category']) ?></td>
                                <td>₹<?= number_format($row['price']) ?></td>
                                <td><?= htmlspecialchars((string)$row['material']) ?></td>
                            <?php elseif ($report_type == 'categories'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['name']) ?></td>
                                <td style="font-size:0.7rem; color:var(--text-muted);"><?= substr($row['image_url'], 0, 40) ?>...</td>
                                <td><?= date('M d, Y', strtotime($row['created_at'])) ?></td>
                            <?php elseif ($report_type == 'feedback'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['from_user']) ?></td>
                                <td><?= htmlspecialchars((string)$row['to_user']) ?></td>
                                <td><?= $row['rating'] ?> <i class="fa-solid fa-star" style="color:var(--warning)"></i></td>
                                <td title="<?= htmlspecialchars((string)$row['comment']) ?>"><?= substr(htmlspecialchars((string)$row['comment'] ?? ''), 0, 40) ?>...</td>
                            <?php elseif ($report_type == 'messages'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['sender_name']) ?></td>
                                <td><?= htmlspecialchars((string)$row['receiver_name']) ?></td>
                                <td title="<?= htmlspecialchars((string)$row['message_text']) ?>"><?= substr(htmlspecialchars((string)$row['message_text']), 0, 40) ?>...</td>
                                <td><?= date('H:i d/M', strtotime($row['timestamp'])) ?></td>
                            <?php elseif ($report_type == 'ai_prompts'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['user_name']) ?></td>
                                <td><span class="badge badge-active"><?= ucfirst($row['style']) ?></span></td>
                                <td><span class="badge"><?= ucfirst($row['status']) ?></span></td>
                                <td title="<?= htmlspecialchars((string)$row['prompt_text']) ?>"><?= substr(htmlspecialchars((string)$row['prompt_text']), 0, 40) ?>...</td>
                            <?php elseif ($report_type == 'requests'): ?>
                                <td><?= $row['id'] ?></td>
                                <td><?= htmlspecialchars((string)$row['user_name']) ?></td>
                                <td><?= htmlspecialchars((string)$row['project_name'] ?? 'N/A') ?></td>
                                <td><span class="badge badge-<?= $row['status'] ?>"><?= ucfirst($row['status']) ?></span></td>
                                <td><?= date('M d, Y', strtotime($row['created_at'])) ?></td>
                            <?php endif; ?>
                        </tr>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php endif; ?>

<script>
function toggleFilters() {
    const type = document.getElementById('report_type').value;
    const allFilters = document.querySelectorAll('.filter-item');
    allFilters.forEach(f => f.style.display = 'none');

    if (type === 'projects' || type === 'requests') {
        document.querySelector('.filter-status').style.display = 'block';
    } else if (type === 'inventory') {
        document.querySelector('.filter-category').style.display = 'block';
    } else if (type === 'feedback' || type === 'designers') {
        document.querySelector('.filter-rating').style.display = 'block';
    }
}
// Initial call
document.addEventListener('DOMContentLoaded', toggleFilters);
</script>

<?php require_once '../includes/footer.php'; ?>
