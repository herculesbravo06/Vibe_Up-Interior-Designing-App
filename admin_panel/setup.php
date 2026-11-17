<?php
// setup.php
// This script creates the vibe_up database, tables, and seeds an admin user
$host = "localhost";
$username = "root";
$password = ""; // Default XAMPP

echo "<pre style='font-family:monospace; background:#1e1e2d; color:#e0e0e0; padding:2rem; border-radius:12px; max-width:600px; margin:2rem auto;'>";
echo "🚀 <b>Vibe Up - Database Setup</b>\n";
echo "================================\n\n";

try {
    $conn = new PDO("mysql:host=$host", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Read and execute the SQL schema
    echo "📦 Reading schema.sql...\n";
    $sql = file_get_contents(__DIR__ . '/schema.sql');
    
    echo "🗄️  Creating database & tables...\n";
    $conn->exec($sql);
    echo "✅ Database and tables created!\n\n";
    
    // Now connect to the vibe_up database to seed data
    $conn = new PDO("mysql:host=$host;dbname=vibe_up", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // --- Seed Admin User ---
    echo "👤 Seeding admin user...\n";
    $admin_check = $conn->query("SELECT COUNT(*) FROM user WHERE role = 'admin'")->fetchColumn();
    
    if ($admin_check == 0) {
        $admin_id = 'ADMIN001';
        $admin_hash = password_hash('admin123', PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO user (id, name, email, username, password_hash, phone, dob, role) VALUES (:id, 'Admin', 'admin@vibeup.com', 'admin', :hash, '0000000000', '1990-01-01', 'admin')");
        $stmt->bindParam(':id', $admin_id);
        $stmt->bindParam(':hash', $admin_hash);
        $stmt->execute();
        echo "✅ Admin user created!\n";
        echo "   📧 Email: admin@vibeup.com\n";
        echo "   👤 Username: admin\n";
        echo "   🔑 Password: admin123\n\n";
    } else {
        echo "ℹ️  Admin user already exists, skipping.\n\n";
    }
    
    // --- Seed Sample Users ---
    echo "👥 Seeding sample users...\n";
    $user_check = $conn->query("SELECT COUNT(*) FROM user WHERE role = 'user'")->fetchColumn();
    
    if ($user_check == 0) {
        $users = [
            ['U10001', 'Alex Johnson', 'alex@example.com', 'alex_j', '9876543210', '1995-05-15'],
            ['U10002', 'Priya Sharma', 'priya@example.com', 'priya_s', '9876543211', '1998-08-22'],
            ['U10003', 'James Wilson', 'james@example.com', 'james_w', '9876543212', '1992-12-10'],
        ];
        foreach ($users as $u) {
            $hash = password_hash('user123', PASSWORD_DEFAULT);
            $stmt = $conn->prepare("INSERT INTO user (id, name, email, username, password_hash, phone, dob, role, profile_pic_url) VALUES (?, ?, ?, ?, ?, ?, ?, 'user', ?)");
            $stmt->execute([$u[0], $u[1], $u[2], $u[3], $hash, $u[4], $u[5], 'https://i.pravatar.cc/150?u='.$u[3]]);
        }
        echo "✅ 3 sample users created (password: user123)\n\n";
    } else {
        echo "ℹ️  Sample users already exist, skipping.\n\n";
    }
    
    // --- Seed Sample Designers ---
    echo "🎨 Seeding sample designers...\n";
    $designer_check = $conn->query("SELECT COUNT(*) FROM user WHERE role = 'designer'")->fetchColumn();
    
    if ($designer_check == 0) {
        $designers = [
            ['D20001', 'Sarah Jenkins', 'sarah@example.com', 'sarah_j', '9988776601', '1990-03-25', 'Modern minimalist specialist with 8+ years of experience.', 4.8, 8],
            ['D20002', 'Emma Watson', 'emma@example.com', 'emma_w', '9988776602', '1993-07-14', 'Contemporary and eclectic interior design expert.', 4.5, 5],
            ['D20003', 'Rahul Verma', 'rahul@example.com', 'rahul_v', '9988776603', '1988-11-30', 'Traditional and fusion style designer.', 4.9, 12],
        ];
        foreach ($designers as $d) {
            $hash = password_hash('designer123', PASSWORD_DEFAULT);
            // Create user entry
            $stmt = $conn->prepare("INSERT INTO user (id, name, email, username, password_hash, phone, dob, role, profile_pic_url) VALUES (?, ?, ?, ?, ?, ?, ?, 'designer', ?)");
            $stmt->execute([$d[0], $d[1], $d[2], $d[3], $hash, $d[4], $d[5], 'https://i.pravatar.cc/150?u='.$d[3]]);
            // Create designer profile
            $did = 'DP'.substr($d[0], 1);
            $stmt2 = $conn->prepare("INSERT INTO designer (id, user_id, bio, rating, experience_years) VALUES (?, ?, ?, ?, ?)");
            $stmt2->execute([$did, $d[0], $d[6], $d[7], $d[8]]);
        }
        echo "✅ 3 sample designers created (password: designer123)\n\n";
    } else {
        echo "ℹ️  Sample designers already exist, skipping.\n\n";
    }
    
    // --- Seed Sample Projects ---
    echo "📐 Seeding sample projects...\n";
    $proj_check = $conn->query("SELECT COUNT(*) FROM project")->fetchColumn();
    
    if ($proj_check == 0) {
        $projects = [
            ['P30001', 'U10001', 'Living Room Makeover', 'Complete redesign of the living room with modern furniture', 45000, 'INR', 'in_progress'],
            ['P30002', 'U10001', 'Master Bedroom Design', 'Cozy and elegant bedroom interior', 30000, 'INR', 'completed'],
            ['P30003', 'U10002', 'Kitchen Extension', 'Modern modular kitchen with island counter', 85000, 'INR', 'in_progress'],
            ['P30004', 'U10003', 'Home Office Setup', 'Minimalist work-from-home space', 20000, 'INR', 'draft'],
        ];
        foreach ($projects as $p) {
            $stmt = $conn->prepare("INSERT INTO project (id, user_id, name, description, total_estimated_cost, currency, status) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute($p);
        }
        
        // Add rooms to projects
        $rooms = [
            ['R40001', 'P30001', 'Living Room', 6.5, 4.2, 3.0, 25000],
            ['R40002', 'P30002', 'Master Bedroom', 5.0, 4.0, 3.0, 30000],
            ['R40003', 'P30003', 'Kitchen', 4.5, 3.5, 3.0, 50000],
            ['R40004', 'P30003', 'Dining Area', 3.5, 3.0, 3.0, 35000],
            ['R40005', 'P30004', 'Office Room', 3.5, 3.0, 3.0, 20000],
        ];
        foreach ($rooms as $r) {
            $stmt = $conn->prepare("INSERT INTO room (id, project_id, name, length_m, width_m, height_m, budget_estimate) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute($r);
        }
        
        // Assign designers to some projects
        $dreqs = [
            ['DR50001', 'P30001', 'U10001', 'DP10001', 'accepted'],
            ['DR50002', 'P30003', 'U10002', 'DP20002', 'accepted'],
            ['DR50003', 'P30004', 'U10003', 'DP30003', 'pending'],
        ];
        foreach ($dreqs as $dr) {
            $stmt = $conn->prepare("INSERT INTO designer_request (id, project_id, user_id, designer_id, status) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute($dr);
        }
        
        echo "✅ 4 sample projects with rooms & designer assignments created!\n\n";
    } else {
        echo "ℹ️  Sample projects already exist, skipping.\n\n";
    }
    
    // --- Seed Sample Catalogue Items ---
    echo "🛋️  Seeding catalogue items...\n";
    $cat_check = $conn->query("SELECT COUNT(*) FROM catalogue_items")->fetchColumn();
    
    if ($cat_check == 0) {
        $items = [
            ['C60001', 'Nordic Fabric Sofa', 'sofa', 45000, 'INR', 'fabric', '["https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=400"]'],
            ['C60002', 'Minimalist Lounge Chair', 'sofa', 18000, 'INR', 'leather', '["https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&q=80&w=400"]'],
            ['C60003', 'Modern Coffee Table', 'table', 12000, 'INR', 'wood', '["https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&q=80&w=400"]'],
            ['C60004', 'Velvet Accent Chair', 'sofa', 25000, 'INR', 'velvet', '["https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?auto=format&fit=crop&q=80&w=400"]'],
            ['C60005', 'Pendant Ceiling Light', 'lighting', 8500, 'INR', 'metal', '["https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&q=80&w=400"]'],
            ['C60006', 'Handwoven Jute Rug', 'rugs', 6500, 'INR', 'jute', '["https://images.unsplash.com/photo-1600166898405-da9535204843?auto=format&fit=crop&q=80&w=400"]'],
            ['C60007', 'Floating Wall Shelf', 'storage', 3500, 'INR', 'engineered wood', '["https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&q=80&w=400"]'],
            ['C60008', 'Abstract Canvas Art', 'decor', 4200, 'INR', 'canvas', '["https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80&w=400"]'],
            ['C60009', 'Study Desk Oak', 'table', 22000, 'INR', 'oak wood', '["https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?auto=format&fit=crop&q=80&w=400"]'],
            ['C60010', 'Floor Standing Lamp', 'lighting', 5800, 'INR', 'brass', '["https://images.unsplash.com/photo-1507473885765-e6ed057ab6fe?auto=format&fit=crop&q=80&w=400"]'],
        ];
        foreach ($items as $it) {
            $dims = json_encode(["width" => rand(30,120), "height" => rand(40,150), "depth" => rand(20,80)]);
            $tags = json_encode(["premium", "bestseller"]);
            $stmt = $conn->prepare("INSERT INTO catalogue_items (id, name, category, price, currency, material, images, dimensions, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$it[0], $it[1], $it[2], $it[3], $it[4], $it[5], $it[6], $dims, $tags]);
        }
        echo "✅ 10 catalogue items with images seeded!\n\n";
    } else {
        echo "ℹ️  Catalogue items already exist, skipping.\n\n";
    }
    
    // --- Seed Sample Feedback ---
    echo "💬 Seeding sample feedback...\n";
    $fb_check = $conn->query("SELECT COUNT(*) FROM feedback")->fetchColumn();
    
    if ($fb_check == 0) {
        $feedbacks = [
            ['F70001', 'U10001', 'D20001', 5, 'Excellent work on my living room! Sarah truly understood my vision.', 'designer'],
            ['F70002', 'U10002', null, 4, 'Great app, very intuitive to use. Would love more AR features.', 'app'],
            ['F70003', 'U10003', 'D20003', 5, 'Rahul is amazing! Very creative and professional.', 'designer'],
        ];
        foreach ($feedbacks as $fb) {
            $stmt = $conn->prepare("INSERT INTO feedback (id, from_user_id, to_user_id, rating, comment, type) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->execute($fb);
        }
        echo "✅ 3 sample feedback entries created!\n\n";
    } else {
        echo "ℹ️  Feedback already exists, skipping.\n\n";
    }
    
    echo "================================\n";
    echo "🎉 <b>Setup complete!</b>\n\n";
    echo "📋 <b>Login Credentials:</b>\n";
    echo "   Admin:    admin@vibeup.com / admin123\n";
    echo "   Users:    alex@example.com / user123\n";
    echo "   Designer: sarah@example.com / designer123\n\n";
    echo "👉 <a href='admin/login.php' style='color:#6c63ff;'>Go to Admin Panel →</a>\n";

} catch(PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

$conn = null;
echo "</pre>";
?>
