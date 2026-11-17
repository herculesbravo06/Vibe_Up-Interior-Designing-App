<?php
// api/designers.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$action = $_GET['action'] ?? 'list';

if ($action == 'list') {
    // Fetch top designers
    $stmt = $conn->query("
        SELECT u.id as user_id, d.id as designer_id, d.id as id, u.name, u.email, u.profile_pic_url,
               d.bio, d.rating, d.experience_years
        FROM user u
        JOIN designer d ON u.id = d.user_id
        WHERE u.role = 'designer'
        ORDER BY d.rating DESC
    ");
    $designers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Add default avatars if missing
    foreach($designers as &$d) {
        if(empty($d['profile_pic_url'])) {
            $d['profile_pic_url'] = 'https://ui-avatars.com/api/?name='.urlencode($d['name']).'&background=random';
        }
    }
    
    echo json_encode(["status" => "success", "data" => $designers]);

} elseif ($action == 'details' && isset($_GET['id'])) {
    $id = $_GET['id'];
    
    // Resolve D... to U... if necessary
    if (strpos($id, 'D') === 0) {
        $stmt = $conn->prepare("SELECT user_id FROM designer WHERE id = ?");
        $stmt->execute([$id]);
        $uid = $stmt->fetchColumn();
        if ($uid) $id = $uid;
    }
    $stmt = $conn->prepare("
        SELECT u.id, u.name, u.email, u.profile_pic_url,
               d.bio, d.rating, d.experience_years, d.portfolio_urls
        FROM user u
        JOIN designer d ON u.id = d.user_id
        WHERE u.id = :id AND u.role = 'designer'
    ");
    $stmt->bindParam(":id", $id);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $designer = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Parse JSON URLs
        if (!empty($designer['portfolio_urls'])) {
            $designer['portfolio_urls'] = json_decode($designer['portfolio_urls'], true);
        }
        
        // Fetch qualifications
        $q_stmt = $conn->prepare("SELECT * FROM designer_qualification WHERE designer_id = (SELECT id FROM designer WHERE user_id = :uid)");
        $q_stmt->bindParam(":uid", $id);
        $q_stmt->execute();
        $designer['qualifications'] = $q_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(["status" => "success", "data" => $designer]);
    } else {
        echo json_encode(["status" => "error", "message" => "Designer not found."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request."]);
}
?>
