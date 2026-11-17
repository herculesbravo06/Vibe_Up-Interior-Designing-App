<?php
// api/auth.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

        $raw_input = file_get_contents("php://input");
        $data = json_decode($raw_input);

        if (!$data || !isset($data->action)) {
            echo json_encode(["status" => "error", "message" => "Action required."]);
            exit;
        }

        if ($data->action == 'login_user' || $data->action == 'login_designer') {
            $email = trim($data->email ?? '');
            $passwordEntered = $data->password ?? '';
            $requestedRole = ($data->action == 'login_designer') ? 'designer' : 'user';

            // ABSOLUTE LOGGING
            $debug_log = 'c:/xampp/htdocs/scratch/auth_debug.log';
            $log_msg = "[" . date('Y-m-d H:i:s') . "] Login Attempt: Email={$email} | Action={$data->action} | RAW: {$raw_input}\n";
            file_put_contents($debug_log, $log_msg, FILE_APPEND);

            if (empty($email) || empty($passwordEntered)) {
                echo json_encode(["status" => "error", "message" => "Email and password required."]);
                exit;
            }

            // STEP 1: Find user by email ONLY first (to detect role mismatch)
            $stmt = $conn->prepare("SELECT id, name, email, password, password_hash, role, profile_pic_url FROM user WHERE email = :email LIMIT 1");
            $stmt->execute([':email' => $email]);
            $user = $stmt->fetch();

            if (!$user) {
            file_put_contents($debug_log, "  >>> Result: User '{$email}' NOT FOUND\n", FILE_APPEND);
            echo json_encode(["status" => "error", "message" => "Invalid credentials."]);
            exit;
        }

        // STEP 2: Case-Insensitive Role Check
        $dbRole = strtolower($user['role'] ?? '');
        $reqRole = strtolower($requestedRole ?? '');
        
        if ($dbRole !== $reqRole) {
            file_put_contents($debug_log, "  >>> Result: Role mismatch (Selected: {$reqRole}, DB: {$dbRole})\n", FILE_APPEND);
            echo json_encode(["status" => "error", "message" => "Account found, but you must select the " . ucfirst($dbRole) . " role."]);
            exit;
        }

        // STEP 3: Robust Password Verification
        $passMatched = false;
        
        file_put_contents($debug_log, "  >>> DEBUG: Entered='{$passwordEntered}' | DB='{$user['password']}' | HashLen=" . strlen($user['password_hash'] ?? '') . "\n", FILE_APPEND);
        
        // A: Direct match with cleartext password column
        if (!empty($user['password']) && $passwordEntered === $user['password']) {
            $passMatched = true;
            file_put_contents($debug_log, "  >>> Pass: Match cleartext\n", FILE_APPEND);
        }
        
        // B: BCrypt Hash verification
        if (!$passMatched && !empty($user['password_hash']) && password_verify($passwordEntered, $user['password_hash'])) {
            $passMatched = true;
            file_put_contents($debug_log, "  >>> Pass: Match hash (bcrypt)\n", FILE_APPEND);
        }
        
        // C: Direct match with 'password_hash' column if it contains a cleartext string (legacy edge case)
        if (!$passMatched && !empty($user['password_hash']) && $passwordEntered === $user['password_hash']) {
            $passMatched = true;
            file_put_contents($debug_log, "  >>> Pass: Match hash (raw string)\n", FILE_APPEND);
        }

        if ($passMatched) {
            file_put_contents($debug_log, "  >>> Result: SUCCESS (Role: {$dbRole})\n", FILE_APPEND);
            
            // Log Activity
            $actStmt = $conn->prepare("INSERT INTO activity_logs (id, actor_id, action, entity_type, entity_id, details) VALUES (:id, :actor_id, :action, 'user', :ent_id, 'User logged in via Web')");
            $actStmt->execute([
                ':id' => uniqid('ACT'),
                ':actor_id' => $user['id'],
                ':action' => $data->action,
                ':ent_id' => $user['id']
            ]);

            echo json_encode([
                "status" => "success", 
                "message" => "Login successful", 
                "data" => [
                    "id" => $user['id'],
                    "name" => $user['name'],
                    "email" => $user['email'],
                    "role" => $user['role'],
                    "profile_pic" => $user['profile_pic_url']
                ]
            ]);
        } else {
            file_put_contents($debug_log, "  >>> Result: Password Mismatch for '{$email}'\n", FILE_APPEND);
            echo json_encode(["status" => "error", "message" => "Invalid credentials."]);
        }
    }
    // REGISTER USER OR DESIGNER
    elseif ($data->action == 'register_user' || $data->action == 'register_designer') {
        $name = $data->name ?? '';
        $email = $data->email ?? '';
        $password = $data->password ?? '';
        $phone = $data->phone ?? '0000000000';
        $dob = $data->dob ?? '2000-01-01';
        $role = ($data->action == 'register_designer') ? 'designer' : 'user';

        if (empty($name) || empty($email) || empty($password)) {
            echo json_encode(["status" => "error", "message" => "All fields (name, email, password) are required."]);
            exit;
        }

        // Check if email exists
        $check_stmt = $conn->prepare("SELECT id FROM user WHERE email = :email");
        $check_stmt->bindParam(':email', $email);
        $check_stmt->execute();
        if ($check_stmt->rowCount() > 0) {
            echo json_encode(["status" => "error", "message" => "Email already exists."]);
            exit;
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);
        
        // Generate a random ID to match the schema's char(20) style
        $id = uniqid(strtoupper(substr($role, 0, 1))); // e.g. U... or D...

        $stmt = $conn->prepare("INSERT INTO user (id, name, email, username, password_hash, password, phone, dob, role) VALUES (:id, :name, :email, :username, :hash, :pass, :phone, :dob, :role)");
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        
        // Mock a username for now
        $username = explode('@', $email)[0] . rand(100,999);
        $stmt->bindParam(':username', $username);
        
        $stmt->bindParam(':hash', $hash);
        $stmt->bindParam(':pass', $password);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':dob', $dob);
        $stmt->bindParam(':role', $role);

        if ($stmt->execute()) {
            
            // Log Activity
            $actStmt = $conn->prepare("INSERT INTO activity_logs (id, actor_id, action, entity_type, entity_id, details) VALUES (:id, :actor_id, :action, 'user', :ent_id, 'User registered')");
            $actStmt->execute([
                ':id' => uniqid('ACT'),
                ':actor_id' => $id,
                ':action' => 'register_' . $role,
                ':ent_id' => $id
            ]);

            // If it's a designer, also create an empty designer profile block
            if ($role === 'designer') {
                $did = uniqid('D');
                $dstmt = $conn->prepare("INSERT INTO designer (id, user_id) VALUES (:did, :uid)");
                $dstmt->bindParam(':did', $did);
                $dstmt->bindParam(':uid', $id);
                $dstmt->execute();
            }
            
            echo json_encode([
                "status" => "success", 
                "message" => ucfirst($role) . " registered successfully.", 
                "data" => ["id" => $id]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Registration failed."]);
        }
    } 
    // FORGOT PASSWORD REQUEST
    elseif ($data->action == 'forgot_password_request') {
        $email = $data->email ?? '';
        
        if (empty($email)) {
            echo json_encode(["status" => "error", "message" => "Email is required."]);
            exit;
        }

        $stmt = $conn->prepare("SELECT id FROM user WHERE email = :email LIMIT 1");
        $stmt->bindParam(':email', $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $otp = rand(1000, 9999);
            
            // Save OTP to DB - Use MySQL NOW() to avoid PHP/DB timezone mismatch
            $update_stmt = $conn->prepare("UPDATE user SET reset_otp = :otp, reset_otp_expiry = DATE_ADD(NOW(), INTERVAL 10 MINUTE) WHERE email = :email");
            $update_stmt->bindParam(':otp', $otp);
            $update_stmt->bindParam(':email', $email);
            $update_stmt->execute();

            // Send Email using PHPMailer
            require_once '../includes/phpmailer/Exception.php';
            require_once '../includes/phpmailer/PHPMailer.php';
            require_once '../includes/phpmailer/SMTP.php';
            $mail_config = require '../config/mail.php';

            $mail = new PHPMailer\PHPMailer\PHPMailer(true);
            $email_sent = false;

            try {
                // Server settings
                $mail->isSMTP();
                $mail->Host       = $mail_config['host'];
                $mail->SMTPAuth   = true;
                $mail->Username   = $mail_config['username'];
                $mail->Password   = $mail_config['password'];
                $mail->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_SMTPS;
                $mail->Port       = $mail_config['port'];

                // Recipients
                $mail->setFrom($mail_config['from_email'], $mail_config['from_name']);
                $mail->addAddress($email);

                // Content
                $mail->isHTML(true);
                $mail->Subject = 'Your VibeUp OTP Code';
                $mail->Body    = "Your verification code is: <b>$otp</b><br><br>This code will expire in 10 minutes.";
                $mail->AltBody = "Your verification code is: $otp\n\nThis code will expire in 10 minutes.";

                $mail->send();
                $email_sent = true;
            } catch (Exception $e) {
                // Fallback to mail() or just log error
                error_log("PHPMailer Error: " . $mail->ErrorInfo);
            }

            // LOG FOR LOCAL DEVELOPMENT fallback
            $log_entry = "[" . date('Y-m-d H:i:s') . "] TO: $email | SUBJECT: Your VibeUp OTP Code | MESSAGE: $otp | STATUS: " . ($email_sent ? 'SENT' : 'FAILED') . "\n---\n";
            file_put_contents('mail_log.txt', $log_entry, FILE_APPEND);

            echo json_encode([
                "status" => "success", 
                "message" => "OTP sent to email."
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Email not found."]);
        }
    }
    // VERIFY OTP
    elseif ($data->action == 'verify_otp') {
        $email = $data->email ?? '';
        $otp = $data->otp ?? '';

        if (empty($email) || empty($otp)) {
            echo json_encode(["status" => "error", "message" => "Email and OTP are required."]);
            exit;
        }

        $stmt = $conn->prepare("SELECT id FROM user WHERE email = :email AND reset_otp = :otp AND reset_otp_expiry > NOW() LIMIT 1");
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':otp', $otp);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            echo json_encode(["status" => "success", "message" => "OTP verified successfully."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid or expired OTP."]);
        }
    }
    // RESET PASSWORD
    elseif ($data->action == 'reset_password') {
        $email = $data->email ?? '';
        $new_password = $data->new_password ?? '';
        
        if (empty($email) || empty($new_password)) {
            echo json_encode(["status" => "error", "message" => "Email and new password are required."]);
            exit;
        }

        $hash = password_hash($new_password, PASSWORD_DEFAULT);

        $stmt = $conn->prepare("UPDATE user SET password_hash = :hash, password = :pass, reset_otp = NULL, reset_otp_expiry = NULL WHERE email = :email");
        $stmt->bindParam(':hash', $hash);
        $stmt->bindParam(':pass', $new_password);
        $stmt->bindParam(':email', $email);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Password reset successfully."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to reset password."]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid action."]);
    }
?>
