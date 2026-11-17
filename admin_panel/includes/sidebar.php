<?php
// includes/sidebar.php
$current_page = basename($_SERVER['PHP_SELF']);
?>
<aside class="sidebar">
    <div class="sidebar-header">
        <h2><i class="fa-solid fa-couch" style="color: var(--primary);"></i> Vibe Up</h2>
    </div>
    <div class="sidebar-menu">
        <ul>
            <li class="<?= $current_page == 'index.php' ? 'active' : '' ?>">
                <a href="index.php"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
            </li>
            
            <li class="has-dropdown <?= in_array($current_page, ['users.php', 'clients.php', 'designers.php', 'admins.php']) ? 'active' : '' ?>">
                <div class="menu-toggle">
                    <i class="fa-solid fa-user-gear"></i> User Management
                    <i class="fa-solid fa-chevron-right"></i>
                </div>
                <ul class="dropdown-container">
                    <li class="<?= $current_page == 'users.php' ? 'active' : '' ?>"><a href="users.php">All Users</a></li>
                    <li class="<?= $current_page == 'designers.php' ? 'active' : '' ?>"><a href="designers.php">Designers</a></li>
                    <li class="<?= $current_page == 'admins.php' ? 'active' : '' ?>"><a href="admins.php">Admin Staff</a></li>
                </ul>
            </li>

            <li class="<?= $current_page == 'designer_requests.php' ? 'active' : '' ?>">
                <a href="designer_requests.php"><i class="fa-solid fa-envelope-open-text"></i> Join Requests</a>
            </li>

            <li class="<?= $current_page == 'projects.php' ? 'active' : '' ?>">
                <a href="projects.php"><i class="fa-solid fa-folder-tree"></i> Project Management</a>
            </li>

            <li class="<?= $current_page == 'feedback.php' ? 'active' : '' ?>">
                <a href="feedback.php"><i class="fa-solid fa-star-half-stroke"></i> User Feedbacks</a>
            </li>

            <li class="<?= $current_page == 'reports.php' ? 'active' : '' ?>">
                <a href="reports.php"><i class="fa-solid fa-file-invoice"></i> Reports Generation</a>
            </li>
            <li class="<?= $current_page == 'activity_logs.php' ? 'active' : '' ?>">
                <a href="activity_logs.php"><i class="fa-solid fa-shield-halved"></i> Activity Logs</a>
            </li>
            <li class="<?= $current_page == 'chat_logs.php' ? 'active' : '' ?>">
                <a href="chat_logs.php"><i class="fa-solid fa-comments"></i> Chat Transcripts</a>
            </li>

            <li class="has-dropdown <?= in_array($current_page, ['ai_logs.php', 'audit_logs.php', 'site_settings.php']) ? 'active' : '' ?>">
                <div class="menu-toggle">
                    <i class="fa-solid fa-shield-halved"></i> System Logs
                    <i class="fa-solid fa-chevron-right"></i>
                </div>
                <ul class="dropdown-container">
                    <li class="<?= $current_page == 'ai_logs.php' ? 'active' : '' ?>"><a href="ai_logs.php">AI Generations</a></li>
                    <li class="<?= $current_page == 'site_settings.php' ? 'active' : '' ?>"><a href="site_settings.php">Site Settings</a></li>
                </ul>
            </li>

            <li class="<?= $current_page == 'catalogue.php' ? 'active' : '' ?>">
                <a href="catalogue.php"><i class="fa-solid fa-box-open"></i> Inventory Mgmt</a>
            </li>
        </ul>
    </div>
</aside>

<div class="main-content">
    <header class="topbar">
        <div class="search-bar" style="color: var(--text-muted);">
            <i class="fa-solid fa-search"></i> <span style="margin-left: 0.5rem;">Search...</span>
        </div>
        <div class="user-profile">
            <span style="font-weight: 500;"><?= htmlspecialchars($_SESSION['admin_username'] ?? 'Admin') ?></span>
            <img src="https://ui-avatars.com/api/?name=Admin&background=6366f1&color=fff" alt="Admin Profile">
            <a href="logout.php" style="margin-left: 1rem; color: var(--danger); text-decoration: none;" title="Logout">
                <i class="fa-solid fa-sign-out-alt"></i>
            </a>
        </div>
    </header>
    <main class="page-content">
