<?php
// includes/header.php
session_start();

// Check if user is logged in
if (!isset($_SESSION['admin_id'])) {
    header("Location: login.php");
    exit;
}

// Update last activity for logged-in user
if (isset($_SESSION['admin_id'])) {
    $db_h = new Database();
    $conn_h = $db_h->getConnection();
    $stmt_h = $conn_h->prepare("UPDATE user SET last_activity = NOW() WHERE id = :id");
    $stmt_h->execute(['id' => $_SESSION['admin_id']]);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Vibe Up Admin</title>
    <!-- Modern Font -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="../assets/css/style.css">
    
    <!-- Chart JS for dashboard graphs -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="wrapper">
