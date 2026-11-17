<?php
// admin/add_designer.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $bio = $_POST['bio'] ?? '';
    $exp = $_POST['experience_years'] ?? 0;
    $specialization = $_POST['specialization'] ?? '';

    try {
        $conn->beginTransaction();
        
        $hashed_password = md5($password);
        
        // 1. Insert into User table
        $stmt_u = $conn->prepare("INSERT INTO user (name, email, username, password, phone, role) VALUES (:name, :email, :username, :password, :phone, 'designer')");
        $stmt_u->execute([
            'name' => $name,
            'email' => $email,
            'username' => $username,
            'password' => $hashed_password,
            'phone' => $phone
        ]);
        
        $user_id = $conn->lastInsertId();
        
        // 2. Insert into Designer table
        $stmt_d = $conn->prepare("INSERT INTO designer (user_id, bio, experience_years, specialization, rating) VALUES (:uid, :bio, :exp, :spec, 5.0)");
        $stmt_d->execute([
            'uid' => $user_id,
            'bio' => $bio,
            'exp' => $exp,
            'spec' => $specialization
        ]);
        
        $conn->commit();
        $message = '<div class="alert alert-success">Designer created successfully! <a href="designers.php">View Designers</a></div>';
    } catch (Exception $e) {
        $conn->rollBack();
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Add New Designer</h1>
    <a href="designers.php" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Back to List</a>
</div>

<?= $message ?>

<div class="card" style="max-width: 800px;">
    <div class="card-body">
        <form method="POST">
            <h3 style="margin-bottom: 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; color: var(--primary);">Account Info</h3>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="name" class="form-control" placeholder="Ar. Jane Smith" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" placeholder="janesmith_design" required>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="jane@vibeup.com" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
            </div>

            <h3 style="margin: 2rem 0 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; color: var(--primary);">Professional Profile</h3>
            <div class="form-group">
                <label class="form-label">Bio / Philosophy</label>
                <textarea name="bio" class="form-control" rows="3" placeholder="Describe the designer's style..."></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Years of Experience</label>
                    <input type="number" name="experience_years" class="form-control" value="0">
                </div>
                <div class="form-group">
                    <label class="form-label">Specialization</label>
                    <input type="text" name="specialization" class="form-control" placeholder="Luxury, Minimalist, etc.">
                </div>
            </div>

            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary" style="width: 220px;">Register Designer</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
