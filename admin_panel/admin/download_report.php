<?php
// admin/download_report.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$type = $_GET['type'] ?? 'projects';
$status = $_GET['status'] ?? 'all';
$from = $_GET['from'] ?? date('Y-m-01');
$to = $_GET['to'] ?? date('Y-m-t');

$data = [];
$filename = "report_" . $type . "_" . date('Ymd') . ".csv";

try {
    if ($type == 'projects') {
        $query = "SELECT p.id, p.name, u.name as customer, p.status, p.total_estimated_cost as budget, p.created_at 
                  FROM project p JOIN user u ON p.user_id = u.id 
                  WHERE p.created_at BETWEEN :from_date AND :to_date";
        if ($status != 'all') $query .= " AND p.status = :status";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':from_date', $from);
        $stmt->bindParam(':to_date', $to);
        if ($status != 'all') $stmt->bindParam(':status', $status);
    } elseif ($type == 'users') {
        $stmt = $conn->prepare("SELECT id, name, email, username, phone, dob, created_at FROM user WHERE role = 'user' AND created_at BETWEEN :from_date AND :to_date");
        $stmt->bindParam(':from_date', $from);
        $stmt->bindParam(':to_date', $to);
    } elseif ($type == 'designers') {
        $stmt = $conn->prepare("SELECT u.id, u.name, u.email, d.experience_years, d.rating, u.created_at 
                                FROM user u JOIN designer d ON u.id = d.user_id 
                                WHERE u.role = 'designer' AND u.created_at BETWEEN :from_date AND :to_date");
        $stmt->bindParam(':from_date', $from);
        $stmt->bindParam(':to_date', $to);
    }

    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Set headers for download
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename=' . $filename);
    $output = fopen('php://output', 'w');

    if (!empty($data)) {
        // Column headers
        fputcsv($output, array_keys($data[0]));
        // Data rows
        foreach ($data as $row) {
            fputcsv($output, $row);
        }
    } else {
        fputcsv($output, ["No data found for this report criteria"]);
    }
    fclose($output);
    exit;

} catch (Exception $e) {
    die("Error generating report: " . $e->getMessage());
}
?>
