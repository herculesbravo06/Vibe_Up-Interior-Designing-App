<?php
// admin/edit_user.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

$id = $_GET['id'] ?? '';
$user = null;

if ($id) {
    $stmt = $conn->prepare("SELECT * FROM user WHERE id = :id");
    $stmt->execute(['id' => $id]);
    $user = $stmt->fetch();
}

if (!$user) {
    header("Location: users.php");
    exit;
}

$message = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $role = $_POST['role'] ?? 'user';

    try {
        $update = $conn->prepare("UPDATE user SET name = :name, email = :email, phone = :phone, role = :role WHERE id = :id");
        $update->execute([
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'role' => $role,
            'id' => $id
        ]);
        $message = '<div class="alert alert-success">User updated successfully!</div>';
        // Refresh user data
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();
    } catch (Exception $e) {
        $message = '<div class="alert alert-danger">Error: ' . $e->getMessage() . '</div>';
    }
}

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Edit User: <?= htmlspecialchars($user['name']) ?></h1>
    <a href="users.php" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Back to List</a>
</div>

<?= $message ?>

<div class="card" style="max-width: 600px;">
    <div class="card-body">
        <form method="POST">
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-control" value="<?= htmlspecialchars($user['name']) ?>" required>
            </div>
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" value="<?= htmlspecialchars($user['email']) ?>" required>
            </div>
            <div class="form-group">
                <label class="form-label">Phone Number</label>
                <input type="text" name="phone" class="form-control" value="<?= htmlspecialchars($user['phone']) ?>" required>
            </div>
            <div class="form-group">
                <label class="form-label">Role</label>
                <select name="role" class="form-control">
                    <option value="user" <?= $user['role'] == 'user' ? 'selected' : '' ?>>Client</option>
                    <option value="designer" <?= $user['role'] == 'designer' ? 'selected' : '' ?>>Designer</option>
                    <option value="admin" <?= $user['role'] == 'admin' ? 'selected' : '' ?>>Administrator</option>
                </select>
            </div>
            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
