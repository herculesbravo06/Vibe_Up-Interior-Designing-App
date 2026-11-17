<?php
// admin/site_settings.php
require_once '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="page-header">
    <h1 class="page-title">Global Platform Settings</h1>
    <div style="color: var(--text-muted);">Configure core platform parameters</div>
</div>

<div class="card" style="max-width: 800px;">
    <div class="card-header">
        <h3 class="card-title"><i class="fa-solid fa-sliders"></i> Configuration</h3>
    </div>
    <div class="card-body">
        <form onsubmit="event.preventDefault(); alert('Settings updated successfully (Demo Mode)');">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                <div class="form-group">
                    <label class="form-label">Platform Name</label>
                    <input type="text" class="form-control" value="Vibe Up Admin" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">System Currency</label>
                    <input type="text" class="form-control" value="INR (₹)" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">Default Designer Comission (%)</label>
                    <input type="number" class="form-control" value="15">
                </div>
                <div class="form-group">
                    <label class="form-label">AI Token Limit (Per User)</label>
                    <input type="number" class="form-control" value="50">
                </div>
            </div>
            
            <div style="margin-top: 2rem; padding-top: 1rem; border-top: 1px solid var(--border);">
                <div class="form-group">
                    <label class="form-label">Maintenance Mode</label>
                    <div style="display: flex; align-items: center; gap: 1rem;">
                        <input type="checkbox" id="maint-mode">
                        <label for="maint-mode" style="font-weight: 400;">Enable global maintenance screen</label>
                    </div>
                </div>
            </div>
            
            <div style="margin-top: 2rem;">
                <button type="submit" class="btn-primary">Save Platform Config</button>
            </div>
        </form>
    </div>
</div>

<?php require_once '../includes/footer.php'; ?>
