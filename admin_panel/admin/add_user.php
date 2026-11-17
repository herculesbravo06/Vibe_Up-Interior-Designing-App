<?php
// admin/add_user.php
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
    $role = $_POST['role'] ?? 'user';

    try {
        // Simple password hash (adjust if using a specific salt in the app)
        $hashed_password = md5($password); 
        
        $stmt = $conn->prepare("INSERT INTO user (name, email, username, password, phone, role) VALUES (:name, :email, :username, :password, :phone, :role)");
        $stmt->execute([
            'name' => $name,
            'email' => $email,
            'username' => $username,
            'password' => $hashed_password,
            'phone' => $phone,
            'role' => $role
        ]);
        
        $message = '<div class="alert alert-success">User created successfully! <a href="users.php">View Users</a></div>';
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Add New User</h1>
    <a href="users.php" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Back to List</a>
</div>

<?= $message ?>

<div class="card" style="max-width: 700px;">
    <div class="card-body">
        <form method="POST">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="name" class="form-control" placeholder="John Doe" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" placeholder="johndoe123" required>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="john@example.com" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="text" name="phone" class="form-control" placeholder="+91 9876543210">
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Role</label>
                    <select name="role" class="form-control">
                        <option value="user">Client</option>
                        <option value="admin">Administrator</option>
                    </select>
                </div>
            </div>

            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary" style="width: 200px;">Create User</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
