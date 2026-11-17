<?php
// api/projects.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Suppress errors to ensure zero plain-text output
error_reporting(0);
ini_set('display_errors', 0);

try {
    require_once '../config/database.php';
    $db = new Database();
    $conn = $db->getConnection();

    if (!$conn) {
        throw new Exception("Could not connect to database.");
    }

    $method = $_SERVER['REQUEST_METHOD'];

    if ($method == 'GET') {
        // Fetch projects for a user
        $user_id = $_GET['user_id'] ?? null;
        $designer_id = $_GET['designer_id'] ?? null;
        
        if ($user_id) {
            $stmt = $conn->prepare("
                SELECT p.*, 
                       d_user.name as designer_name,
                       r.length_m as room_length,
                       r.width_m as room_width,
                       r.height_m as room_height,
                       r.name as room_name,
                       r.scene_data,
                       (SELECT COUNT(*) FROM room r2 WHERE r2.project_id = p.id) as room_count
                FROM project p 
                LEFT JOIN designer_request dr ON p.id = dr.project_id AND dr.status = 'accepted'
                LEFT JOIN designer d ON dr.designer_id = d.id
                LEFT JOIN user d_user ON d.user_id = d_user.id
                LEFT JOIN room r ON p.id = r.project_id
                WHERE p.user_id = :uid 
                GROUP BY p.id
                ORDER BY p.created_at DESC
            ");
            $stmt->bindParam(":uid", $user_id);
        } elseif ($designer_id) {
            $stmt = $conn->prepare("
                SELECT p.*, u.name as user_name 
                FROM project p 
                JOIN user u ON p.user_id = u.id 
                JOIN designer_request dr ON p.id = dr.project_id
                JOIN designer d ON dr.designer_id = d.id
                WHERE d.user_id = :did AND dr.status = 'accepted'
                ORDER BY p.created_at DESC
            ");
            $stmt->bindParam(":did", $designer_id);
        } else {
            echo json_encode(["status" => "error", "message" => "user_id or designer_id required."]);
            exit;
        }
        
        $stmt->execute();
        $projects = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["status" => "success", "data" => $projects]);

    } elseif ($method == 'POST') {
        // Create OR Update project
        $data = json_decode(file_get_contents("php://input"));
        if (!$data) { throw new Exception("Invalid JSON received."); }
        
        // IF project_id is provided, treat as UPDATE
        if (!empty($data->project_id)) {
            $pid = $data->project_id;
            $title = $data->title ?? $data->name ?? null; // Support name fallback
            $description = $data->description ?? null;
            $budget = $data->budget ?? null;
            
            $updates = [];
            $params = [":pid" => $pid];
            
            if($title !== null) { $updates[] = "name = :title"; $params[":title"] = $title; }
            if($description !== null) { $updates[] = "description = :desc"; $params[":desc"] = $description; }
            if($budget !== null) { $updates[] = "total_estimated_cost = :budget"; $params[":budget"] = $budget; }
            
            if (!empty($updates)) {
                $sql = "UPDATE project SET " . implode(", ", $updates) . " WHERE id = :pid";
                $stmt = $conn->prepare($sql);
                $stmt->execute($params);
            }
            
            if (!empty($data->dimensions) || !empty($data->scene_data)) {
                $length = $data->dimensions->length ?? null;
                $width = $data->dimensions->width ?? null;
                $height = $data->dimensions->height ?? null;
                $scene_data = $data->scene_data ?? null;
                
                $upd_r = [];
                $par_r = [":pid" => $pid];
                
                if($length !== null) { $upd_r[] = "length_m = :length"; $par_r[":length"] = $length; }
                if($width !== null) { $upd_r[] = "width_m = :width"; $par_r[":width"] = $width; }
                if($height !== null) { $upd_r[] = "height_m = :height"; $par_r[":height"] = $height; }
                if($scene_data !== null) { $upd_r[] = "scene_data = :scene"; $par_r[":scene"] = $scene_data; }
                
                if (!empty($upd_r)) {
                    $sql_r = "UPDATE room SET " . implode(", ", $upd_r) . " WHERE project_id = :pid LIMIT 1";
                    $r_stmt = $conn->prepare($sql_r);
                    $r_stmt->execute($par_r);
                }
            }
            echo json_encode(["status" => "success", "message" => "Project updated."]);
            exit;
        }

        // Normal Create (POST)
        $title = $data->title ?? $data->name ?? null; // Support name fallback
        if (empty($data->user_id) || empty($title)) {
            echo json_encode(["status" => "error", "message" => "user_id and title are required."]);
            exit;
        }
        
        $id = uniqid('P'); // project id
        $description = $data->description ?? null;
        $budget = $data->budget ?? 0;
        
        $stmt = $conn->prepare("INSERT INTO project (id, user_id, name, description, total_estimated_cost, status) VALUES (:id, :user_id, :title, :desc, :budget, 'in_progress')");
        $stmt->bindParam(":id", $id);
        $stmt->bindParam(":user_id", $data->user_id);
        $stmt->bindParam(":title", $title);
        $stmt->bindParam(":desc", $description);
        $stmt->bindParam(":budget", $budget);
        
        if ($stmt->execute()) {
            
            // Log Activity
            $actStmt = $conn->prepare("INSERT INTO activity_logs (id, actor_id, action, entity_type, entity_id, details) VALUES (:aid, :actor_id, 'create_project', 'project', :ent_id, :details)");
            $details = 'User created project: ' . $title;
            $actStmt->execute([
                ':aid' => uniqid('ACT'),
                ':actor_id' => $data->user_id,
                ':ent_id' => $id,
                ':details' => $details
            ]);

            // Generate room ID and prepare insert
            $rid = uniqid('R');
            $room_name = $data->room_name ?? 'Main Room';
            $length = $data->dimensions->length ?? 0;
            $width = $data->dimensions->width ?? 0;
            $height = $data->dimensions->height ?? 3;
            $scene_data = $data->scene_data ?? null;
            
            $r_stmt = $conn->prepare("INSERT INTO room (id, project_id, name, length_m, width_m, height_m, scene_data) VALUES (:rid, :pid, :name, :length, :width, :height, :scene)");
            $r_stmt->bindParam(":rid", $rid);
            $r_stmt->bindParam(":pid", $id);
            $r_stmt->bindParam(":name", $room_name);
            $r_stmt->bindParam(":length", $length);
            $r_stmt->bindParam(":width", $width);
            $r_stmt->bindParam(":height", $height);
            $r_stmt->bindParam(":scene", $scene_data);
            $r_stmt->execute();
            
            // Handle designer request mapping if designer_id is provided
            if (!empty($data->designer_id)) {
                $dreq_id = uniqid('DR');
                $dr_stmt = $conn->prepare("INSERT INTO designer_request (id, project_id, user_id, designer_id, status) VALUES (:drid, :pid, :uid, :did, 'pending')");
                $dr_stmt->bindParam(":drid", $dreq_id);
                $dr_stmt->bindParam(":pid", $id);
                $dr_stmt->bindParam(":uid", $data->user_id);
                $dr_stmt->bindParam(":did", $data->designer_id);
                $dr_stmt->execute();
            }

            echo json_encode(["status" => "success", "message" => "Project created.", "project_id" => $id]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to create project."]);
        }
    } elseif ($method == 'PUT' || $method == 'OPTIONS') {
        if ($method == 'OPTIONS') { exit; }
        // Update existing project
        $data = json_decode(file_get_contents("php://input"));
        if (!$data) { throw new Exception("Invalid JSON received."); }
        
        if (empty($data->project_id)) {
            echo json_encode(["status" => "error", "message" => "project_id is required for updates."]);
            exit;
        }
        
        $pid = $data->project_id;
        $title = $data->title ?? $data->name ?? null; // Support name fallback
        $description = $data->description ?? null;
        $budget = $data->budget ?? null;
        
        $updates = [];
        $params = [":pid" => $pid];
        
        if($title !== null) { $updates[] = "name = :title"; $params[":title"] = $title; }
        if($description !== null) { $updates[] = "description = :desc"; $params[":desc"] = $description; }
        if($budget !== null) { $updates[] = "total_estimated_cost = :budget"; $params[":budget"] = $budget; }
        
        if (!empty($updates)) {
            $sql = "UPDATE project SET " . implode(", ", $updates) . " WHERE id = :pid";
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
        }
        
        // Also update the room if dimensions or scene_data are provided
        if (!empty($data->dimensions) || !empty($data->scene_data)) {
            $length = $data->dimensions->length ?? null;
            $width = $data->dimensions->width ?? null;
            $height = $data->dimensions->height ?? null;
            $scene_data = $data->scene_data ?? null;
            
            $upd_r = [];
            $par_r = [":pid" => $pid];
            
            if($length !== null) { $upd_r[] = "length_m = :length"; $par_r[":length"] = $length; }
            if($width !== null) { $upd_r[] = "width_m = :width"; $par_r[":width"] = $width; }
            if($height !== null) { $upd_r[] = "height_m = :height"; $par_r[":height"] = $height; }
            if($scene_data !== null) { $upd_r[] = "scene_data = :scene"; $par_r[":scene"] = $scene_data; }
            
            if (!empty($upd_r)) {
                $sql_r = "UPDATE room SET " . implode(", ", $upd_r) . " WHERE project_id = :pid LIMIT 1";
                $r_stmt = $conn->prepare($sql_r);
                $r_stmt->execute($par_r);
            }
        }

        echo json_encode(["status" => "success", "message" => "Project updated."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Unsupported method."]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error", 
        "message" => "Server Error: " . $e->getMessage()
    ]);
}
?>

