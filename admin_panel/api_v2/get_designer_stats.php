<?php
require_once '../config/database.php';
header('Content-Type: application/json');

$db = new Database();
$conn = $db->getConnection();

$id = $_GET['designer_id'] ?? null;

if (!$id) {
    echo json_encode(['status' => 'error', 'message' => 'Missing designer ID']);
    exit;
}

// Robust resolution: Find designer entry by either its own ID or the user ID
$stmt = $conn->prepare("SELECT id, user_id FROM designer WHERE id = ? OR user_id = ? LIMIT 1");
$stmt->execute([$id, $id]);
$designer_row = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$designer_row) {
    echo json_encode(['status' => 'error', 'message' => 'Designer record not found for ID: ' . $id]);
    exit;
}

$designer_id = $designer_row['id'];
$designer_user_id = $designer_row['user_id'];

try {
    // Total Projects (Active: accepted or live)
    $stmt = $conn->prepare("SELECT COUNT(*) FROM designer_request WHERE designer_id = ? AND status IN ('accepted', 'live')");
    $stmt->execute([$designer_id]);
    $total_projects = $stmt->fetchColumn();

    // Pending Requests
    $stmt = $conn->prepare("SELECT COUNT(*) FROM designer_request WHERE designer_id = ? AND status = 'pending'");
    $stmt->execute([$designer_id]);
    $pending_requests = $stmt->fetchColumn();

    // Completed Projects (solved)
    $stmt = $conn->prepare("SELECT COUNT(*) FROM designer_request WHERE designer_id = ? AND status = 'solved'");
    $stmt->execute([$designer_id]);
    $completed_projects = $stmt->fetchColumn();

    // Get designer's user_id for feedback
    $stmt_u = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
    $stmt_u->execute([$designer_id]);
    $designer_user_id = $stmt_u->fetchColumn();

    // Average Rating
    $stmt = $conn->prepare("SELECT AVG(rating) FROM feedback WHERE to_user_id = ?");
    $stmt->execute([$designer_user_id]);
    $avg_rating = $stmt->fetchColumn() ?: 0;

    // Profile Info
    $stmt = $conn->prepare("
        SELECT u.name, u.email, u.profile_pic_url AS profile_image, d.bio, d.experience_years 
        FROM user u 
        JOIN designer d ON u.id = d.user_id 
        WHERE d.id = ?
    ");
    $stmt->execute([$designer_id]);
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'data' => [
            'total_projects' => (int)$total_projects,
            'pending_requests' => (int)$pending_requests,
            'completed_projects' => (int)$completed_projects,
            'rating' => round((float)$avg_rating, 1),
            'profile' => $profile
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
