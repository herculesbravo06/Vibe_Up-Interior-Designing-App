<?php
// admin/generate_report.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$type = $_GET['type'] ?? 'projects';
$status = $_GET['status'] ?? 'all';
$category = $_GET['category'] ?? 'all';
$min_rating = $_GET['min_rating'] ?? 0;
$from = $_GET['from'] ?? date('Y-m-01');
$to = $_GET['to'] ?? date('Y-m-t');

$data = [];
try {
    if ($type == 'projects') {
        $query = "SELECT p.*, u.name as customer_name FROM project p LEFT JOIN user u ON p.user_id = u.id WHERE p.created_at BETWEEN :from AND :to";
        if ($status != 'all') $query .= " AND p.status = :status";
        $stmt = $conn->prepare($query);
        if ($status != 'all') $stmt->bindParam(':status', $status);
    } elseif ($type == 'users') {
        $stmt = $conn->prepare("SELECT * FROM user WHERE role = 'user' AND created_at BETWEEN :from AND :to ORDER BY created_at DESC");
    } elseif ($type == 'financial') {
        $stmt = $conn->prepare("
            SELECT 
                status, 
                COUNT(*) as project_count, 
                SUM(total_estimated_cost) as total_budget,
                AVG(total_estimated_cost) as avg_budget
            FROM project 
            WHERE created_at BETWEEN :from AND :to
            GROUP BY status
        ");
    } elseif ($type == 'designers') {
        $query = "SELECT u.name, u.email, d.experience_years, d.rating, d.specialization,
                  (SELECT COUNT(*) FROM project WHERE designer_id = u.id) as active_projects
                  FROM user u 
                  JOIN designer d ON u.id = d.user_id 
                  WHERE u.role = 'designer' AND u.created_at BETWEEN :from AND :to";
        if ($min_rating > 0) $query .= " AND d.rating >= :min_rating";
        $query .= " ORDER BY d.rating DESC";
        $stmt = $conn->prepare($query);
        if ($min_rating > 0) $stmt->bindParam(':min_rating', $min_rating);
    } elseif ($type == 'inventory') {
        $query = "SELECT * FROM catalogue_items WHERE created_at BETWEEN :from AND :to";
        if ($category != 'all') $query .= " AND category = :category";
        $query .= " ORDER BY category, name ASC";
        $stmt = $conn->prepare($query);
        if ($category != 'all') $stmt->bindParam(':category', $category);
    } elseif ($type == 'categories') {
        $stmt = $conn->prepare("SELECT * FROM catalogue_categories WHERE created_at BETWEEN :from AND :to ORDER BY name ASC");
    } elseif ($type == 'feedback') {
        $query = "SELECT f.*, u1.name as from_user, u2.name as to_user FROM feedback f 
                  LEFT JOIN user u1 ON f.from_user_id = u1.id 
                  LEFT JOIN user u2 ON f.to_user_id = u2.id 
                  WHERE f.created_at BETWEEN :from AND :to";
        if ($min_rating > 0) $query .= " AND f.rating >= :min_rating";
        $query .= " ORDER BY f.created_at DESC";
        $stmt = $conn->prepare($query);
        if ($min_rating > 0) $stmt->bindParam(':min_rating', $min_rating);
    } elseif ($type == 'messages') {
        $stmt = $conn->prepare("SELECT m.*, u1.name as sender_name, u2.name as receiver_name FROM messages m 
                                JOIN user u1 ON m.sender_id = u1.id 
                                JOIN user u2 ON m.receiver_id = u2.id 
                                WHERE m.timestamp BETWEEN :from AND :to ORDER BY m.timestamp DESC");
    } elseif ($type == 'ai_prompts') {
        $stmt = $conn->prepare("SELECT a.*, u.name as user_name FROM ai_prompts a 
                                JOIN user u ON a.user_id = u.id 
                                WHERE a.created_at BETWEEN :from AND :to ORDER BY a.created_at DESC");
    } elseif ($type == 'requests') {
        $query = "SELECT r.*, u.name as user_name, p.name as project_name FROM designer_request r 
                  JOIN user u ON r.user_id = u.id 
                  LEFT JOIN project p ON r.project_id = p.id
                  WHERE r.created_at BETWEEN :from AND :to";
        if ($status != 'all') $query .= " AND r.status = :status";
        $query .= " ORDER BY r.created_at DESC";
        $stmt = $conn->prepare($query);
        if ($status != 'all') $stmt->bindParam(':status', $status);
    } elseif ($type == 'system') {
        $data = [
            'Total Active Clients' => $conn->query("SELECT COUNT(*) FROM user WHERE role='user'")->fetchColumn(),
            'Certified Designers' => $conn->query("SELECT COUNT(*) FROM user WHERE role='designer'")->fetchColumn(),
            'Total Active Projects' => $conn->query("SELECT COUNT(*) FROM project")->fetchColumn(),
            'Catalogue Item Count' => $conn->query("SELECT COUNT(*) FROM catalogue_items")->fetchColumn(),
            'Category Count' => $conn->query("SELECT COUNT(*) FROM catalogue_categories")->fetchColumn(),
            'Pending Applications' => $conn->query("SELECT COUNT(*) FROM designer_request WHERE status='pending'")->fetchColumn(),
            'Total Feedback' => $conn->query("SELECT COUNT(*) FROM feedback")->fetchColumn(),
            'Total Messages' => $conn->query("SELECT COUNT(*) FROM messages")->fetchColumn(),
            'AI Prompts Generated' => $conn->query("SELECT COUNT(*) FROM ai_prompts")->fetchColumn(),
            'Total Project Volume' => $conn->query("SELECT SUM(total_estimated_cost) FROM project")->fetchColumn() . " INR"
        ];
    }
    
    if ($type != 'system') {
        $stmt->bindParam(':from', $from);
        $stmt->bindParam(':to', $to);
        $stmt->execute();
        $data = $stmt->fetchAll();
    }
} catch (Exception $e) {
    die("Report Generation Error: " . $e->getMessage());
}

$report_title = strtoupper($type) . " REPORT";
$report_period = date('d M Y', strtotime($from)) . " to " . date('d M Y', strtotime($to));
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><?= $report_title ?> - Vibe Up Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --secondary: #f8fafc;
            --text: #0f172a;
            --text-muted: #64748b;
            --border: #e2e8f0;
        }
        body {
            font-family: 'Outfit', sans-serif;
            background: white;
            color: var(--text);
            margin: 0;
            padding: 40px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            border-bottom: 2px solid var(--primary);
            padding-bottom: 20px;
            margin-bottom: 40px;
        }
        .logo-box h1 {
            margin: 0;
            font-size: 2.5rem;
            color: var(--primary);
            letter-spacing: -1px;
        }
        .report-info {
            text-align: right;
        }
        .report-info h2 {
            margin: 0;
            font-size: 1.5rem;
            color: var(--text);
        }
        .report-info p {
            margin: 5px 0 0;
            color: var(--text-muted);
            font-weight: 500;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: var(--secondary);
            text-align: left;
            padding: 12px 15px;
            border-bottom: 2px solid var(--border);
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            font-size: 0.8rem;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid var(--border);
            font-size: 0.9rem;
        }
        .badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            background: #eee;
        }
        .footer {
            margin-top: 50px;
            text-align: center;
            font-size: 0.8rem;
            color: var(--text-muted);
            border-top: 1px solid var(--border);
            padding-top: 20px;
        }
        @media print {
            .no-print { display: none; }
            body { padding: 0; }
            @page { size: landscape; }
        }
        .print-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--primary);
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 8px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
            font-family: inherit;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>
<body>
    <button class="print-btn no-print" onclick="window.print()">
        <i class="fa-solid fa-print"></i> Print as PDF
    </button>

    <div class="header">
        <div class="logo-box">
            <h1>Vibe Up</h1>
            <p style="margin:0; font-weight:500; color:var(--text-muted);">Luxury Interior Administration</p>
        </div>
        <div class="report-info">
            <h2><?= $report_title ?></h2>
            <p><?= $report_period ?></p>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <?php if ($type == 'projects'): ?>
                    <th>ID</th>
                    <th>Project Name</th>
                    <th>Customer</th>
                    <th>Status</th>
                    <th>Budget</th>
                    <th>Last Update</th>
                <?php elseif ($type == 'financial'): ?>
                    <th>Project Status</th>
                    <th>Count</th>
                    <th>Total Budget</th>
                    <th>Avg Budget</th>
                <?php elseif ($type == 'users'): ?>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>DOB</th>
                    <th>Registration</th>
                <?php elseif ($type == 'designers'): ?>
                    <th>Designer Name</th>
                    <th>Rating</th>
                    <th>Exp (Yrs)</th>
                    <th>Specialization</th>
                    <th>Active Projects</th>
                <?php elseif ($type == 'inventory'): ?>
                    <th>ID</th>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Material</th>
                    <th>Dimensions</th>
                    <th>Price</th>
                <?php elseif ($type == 'categories'): ?>
                    <th>ID</th>
                    <th>Category Name</th>
                    <th>Image Source</th>
                    <th>Created At</th>
                <?php elseif ($type == 'feedback'): ?>
                    <th>ID</th>
                    <th>From</th>
                    <th>To</th>
                    <th>Project</th>
                    <th>Rating</th>
                    <th>Comment</th>
                <?php elseif ($type == 'messages'): ?>
                    <th>ID</th>
                    <th>From</th>
                    <th>To</th>
                    <th>Message Text</th>
                    <th>Chat ID</th>
                    <th>Time</th>
                <?php elseif ($type == 'ai_prompts'): ?>
                    <th>ID</th>
                    <th>User</th>
                    <th>Style</th>
                    <th>Status</th>
                    <th>Prompt Query</th>
                    <th>Results</th>
                <?php elseif ($type == 'requests'): ?>
                    <th>ID</th>
                    <th>Applicant</th>
                    <th>Project Link</th>
                    <th>Status</th>
                    <th>Submitted On</th>
                <?php elseif ($type == 'system'): ?>
                    <th>Aggregated Metric</th>
                    <th>Current System Value</th>
                <?php endif; ?>
            </tr>
        </thead>
        <tbody>
            <?php if ($type != 'system'): ?>
                <?php foreach ($data as $row): ?>
                    <tr>
                        <?php if ($type == 'projects'): ?>
                            <td><?= $row['id'] ?></td>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                            <td><?= htmlspecialchars((string)$row['customer_name'] ?: 'N/A') ?></td>
                            <td><span class="badge"><?= strtoupper($row['status']) ?></span></td>
                            <td>₹<?= number_format($row['currency'] == 'INR' ? $row['total_estimated_cost'] : $row['total_estimated_cost'] * 83) ?></td>
                            <td><?= date('d M Y', strtotime($row['updated_at'])) ?></td>
                        <?php elseif ($type == 'financial'): ?>
                            <td><span class="badge" style="background:var(--primary); color:white;"><?= strtoupper($row['status']) ?></span></td>
                            <td><?= $row['project_count'] ?></td>
                            <td style="font-weight:600; color:var(--primary)">₹<?= number_format($row['total_budget']) ?></td>
                            <td>₹<?= number_format($row['avg_budget']) ?></td>
                        <?php elseif ($type == 'users'): ?>
                            <td><?= $row['id'] ?></td>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                            <td><?= htmlspecialchars((string)$row['username']) ?></td>
                            <td><?= htmlspecialchars((string)$row['email']) ?></td>
                            <td><?= htmlspecialchars((string)$row['phone']) ?></td>
                            <td><?= $row['dob'] ?></td>
                            <td><?= date('d M Y', strtotime($row['created_at'])) ?></td>
                        <?php elseif ($type == 'designers'): ?>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                            <td><?= $row['rating'] ?> <i class="fa-solid fa-star" style="color:#fbbf24; font-size:0.75rem;"></i></td>
                            <td><?= $row['experience_years'] ?> Yrs</td>
                            <td><?= htmlspecialchars((string)$row['specialization']) ?></td>
                            <td><span class="badge" style="background:#e0e7ff; color:#4f46e5;"><?= $row['active_projects'] ?> Active</span></td>
                        <?php elseif ($type == 'inventory'): ?>
                            <td><?= $row['id'] ?></td>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                            <td><?= htmlspecialchars((string)$row['category']) ?></td>
                            <td><?= htmlspecialchars((string)$row['material'] ?: 'N/A') ?></td>
                            <td style="font-size:0.8rem;"><?= htmlspecialchars((string)$row['dimensions'] ?: 'N/A') ?></td>
                            <td>₹<?= number_format($row['price']) ?></td>
                        <?php elseif ($type == 'categories'): ?>
                            <td><?= $row['id'] ?></td>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['name']) ?></td>
                            <td style="font-size:0.75rem; max-width:300px;"><?= htmlspecialchars($row['image_url']) ?></td>
                            <td><?= date('d M Y', strtotime($row['created_at'])) ?></td>
                        <?php elseif ($type == 'feedback'): ?>
                            <td><?= $row['id'] ?></td>
                            <td><?= htmlspecialchars((string)$row['from_user']) ?></td>
                            <td><?= htmlspecialchars((string)$row['to_user']) ?></td>
                            <td><?= htmlspecialchars((string)$row['project_id'] ?: 'Global') ?></td>
                            <td><?= $row['rating'] ?> <i class="fa-solid fa-star" style="color:#fbbf24; font-size:0.75rem;"></i></td>
                            <td style="max-width:300px;"><?= htmlspecialchars($row['comment']) ?></td>
                        <?php elseif ($type == 'messages'): ?>
                            <td><?= $row['id'] ?></td>
                            <td><?= htmlspecialchars((string)$row['sender_name']) ?></td>
                            <td><?= htmlspecialchars((string)$row['receiver_name']) ?></td>
                            <td style="max-width:300px;"><?= htmlspecialchars($row['message_text']) ?></td>
                            <td><?= $row['chat_id'] ?></td>
                            <td><?= date('H:i d/M/Y', strtotime($row['timestamp'])) ?></td>
                        <?php elseif ($type == 'ai_prompts'): ?>
                            <td><?= $row['id'] ?></td>
                            <td><?= htmlspecialchars((string)$row['user_name']) ?></td>
                            <td><?= ucfirst($row['style']) ?></td>
                            <td><?= ucfirst($row['status']) ?></td>
                            <td style="max-width:300px;"><?= htmlspecialchars($row['prompt_text']) ?></td>
                            <td style="font-size:0.75rem; max-width:150px;"><?= htmlspecialchars(substr($row['result_images'] ?? '', 0, 30)) ?>...</td>
                        <?php elseif ($type == 'requests'): ?>
                            <td><?= $row['id'] ?></td>
                            <td style="font-weight:600;"><?= htmlspecialchars((string)$row['user_name']) ?></td>
                            <td><?= htmlspecialchars((string)$row['project_name'] ?: 'N/A') ?></td>
                            <td><span class="badge"><?= strtoupper($row['status']) ?></span></td>
                            <td><?= date('d M Y', strtotime($row['created_at'])) ?></td>
                        <?php endif; ?>
                    </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <?php foreach ($data as $metric => $val): ?>
                    <tr>
                        <td style="font-weight:600;"><?= $metric ?></td>
                        <td><span class="badge" style="background:var(--primary); color:white; padding: 5px 15px;"><?= is_numeric($val) ? number_format($val) : $val ?></span></td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>

            <?php if (empty($data)): ?>
                <tr><td colspan="10" style="text-align:center; padding: 40px;">No data found for the selected filters.</td></tr>
            <?php endif; ?>
        </tbody>
    </table>

    <div class="footer">
        <p>This is a system generated report from Vibe Up Admin Control Panel.</p>
        <p>© <?= date('Y') ?> Vibe Up Interior Designs. All rights reserved.</p>
    </div>

    <script>
        // Optional: Auto trigger print dialog if needed
        // window.onload = () => { window.print(); }
    </script>
</body>
</html>
