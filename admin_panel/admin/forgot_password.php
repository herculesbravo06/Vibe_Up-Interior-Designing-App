<?php
// admin/forgot_password.php
session_start();
require_once '../config/database.php';

$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = trim($_POST['email'] ?? '');

    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = "Please enter a valid email address.";
    } else {
        $db = new Database();
        $conn = $db->getConnection();
        
        $stmt = $conn->prepare("SELECT id FROM user WHERE email = :email AND role = 'admin' LIMIT 1");
        $stmt->bindParam(':email', $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            // In a real application, you would generate a token and send an email using PHPMailer or similar.
            // For now, we simulate an email sent.
            $_SESSION['success_message'] = "If that email exists in our system, a password reset link has been sent.";
            header("Location: login.php");
            exit;
        } else {
            // We show the same message to prevent email enumeration
            $_SESSION['success_message'] = "If that email exists in our system, a password reset link has been sent.";
            header("Location: login.php");
            exit;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Vibe Up Admin</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-body">

    <div class="auth-container">
        <div class="auth-logo">
            <i class="fa-solid fa-couch"></i> Vibe Up
        </div>
        <div class="auth-tagline">Admin Password Recovery</div>
        
        <?php if (!empty($error)): ?>
            <div class="alert alert-danger">
                <?php echo htmlspecialchars($error); ?>
            </div>
        <?php endif; ?>

        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem; text-align: left;">
            Enter your email address and we will send you instructions on how to reset your password.
        </p>

        <form method="POST" action="">
            <div class="form-group">
                <label for="email" class="form-label">Email Address</label>
                <input type="email" id="email" name="email" class="form-control" placeholder="admin@example.com" required>
            </div>
            
            <button type="submit" class="btn-primary">Send Reset Link</button>
        </form>

        <div class="auth-links">
            <a href="login.php"><i class="fa-solid fa-arrow-left"></i> Back to Login</a>
        </div>
    </div>

</body>
</html>
