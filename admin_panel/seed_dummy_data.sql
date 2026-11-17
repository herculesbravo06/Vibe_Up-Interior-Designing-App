-- seed_dummy_data.sql
-- Run after schema.sql to populate test data

USE `vibe_up`;

-- Plain text passwords stored for api_v2 compatibility as per schema.sql
-- All bcrypt hashes correspond to 'admin_setup'

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Users (Admin, Users, Designers)
INSERT INTO `user` (`id`, `name`, `email`, `username`, `password_hash`, `password`, `phone`, `dob`, `role`) VALUES
('U90001', 'Admin User', 'admin@vibeup.com', 'admin', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9999999999', '1985-01-01', 'admin'),
('U10001', 'John Miller', 'john.miller@gmail.com', 'johnm', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543210', '1995-04-12', 'user'),
('U10002', 'Ananya Patel', 'ananya.p@gmail.com', 'ananyap', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543211', '1998-08-22', 'user'),
('U10003', 'Rahul Verma', 'rahul.v@gmail.com', 'rahulv', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543212', '1992-12-10', 'user'),
('U10004', 'Sanya Malhotra', 'sanya.m@outlook.com', 'sanyam', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543213', '1996-05-15', 'user'),
('U10005', 'Vikram Singh', 'vikram.s@yahoo.com', 'vikrams', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543214', '1991-03-20', 'user'),
('U20001', 'Alex Turner', 'alex.t@gmail.com', 'alext', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543220', '1990-06-10', 'designer'),
('U20002', 'Meera Iyer', 'meera.i@gmail.com', 'meerai', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543221', '1993-02-14', 'designer'),
('U20003', 'Sarah Jones', 'sarah.j@gmail.com', 'sarahj', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543222', '1988-11-30', 'designer'),
('U20004', 'Kabir Khan', 'kabir.k@design.io', 'kabirk', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543223', '1994-07-12', 'designer'),
('U20005', 'Elena Rossi', 'elena.r@luxury.it', 'elenar', '$2y$10$wN1G27uW8uO778C53s7R3ezlQ2H7l5W3U6R76I7K796iM7a4i6Gj2', 'admin_setup', '9876543224', '1987-09-05', 'designer');

-- 2. Designer Profiles
INSERT INTO `designer` (`id`, `user_id`, `bio`, `experience_years`, `rating`) VALUES
('D20001', 'U20001', 'Modern minimalist specialist with a focus on Scandinavian aesthetics.', 8, 4.8),
('D20002', 'U20002', 'Vibrant and eclectic designer specializing in bohemian and fusion styles.', 5, 4.5),
('D20003', 'U20003', 'Luxury interior architect with 12+ years of high-end residential experience.', 12, 4.9),
('D20004', 'U20004', 'Industrial loft enthusiast skilled in raw materials and open floor plans.', 4, 4.2),
('D20005', 'U20005', 'Classical Italian designer focusing on elegance and timeless furniture.', 15, 5.0);

-- 3. Designer Qualifications
INSERT INTO `designer_qualification` (`id`, `designer_id`, `qualification_name`, `institute_name`, `year_completed`) VALUES
('Q1', 'D20001', 'B.Des Interior', 'NID Ahmedabad', '2016'),
('Q2', 'D20002', 'Diploma in Design', 'JJ School of Arts', '2019'),
('Q3', 'D20003', 'M.Arch Interior', 'Oxford University', '2012'),
('Q4', 'D20004', 'B.Tech Wood Tech', 'IIT Kanpur', '2020'),
('Q5', 'D20005', 'Master of Fine Arts', 'Florence Academy', '2008');

-- 4. Projects
INSERT INTO `project` (`id`, `user_id`, `name`, `description`, `status`, `total_estimated_cost`) VALUES
('P10001', 'U10001', 'Living Room Revamp', 'Modernizing my living room with warm lighting.', 'in_progress', 450000.00),
('P10002', 'U10001', 'Master Bedroom', 'Minimalist master bedroom design.', 'draft', 300000.00),
('P10003', 'U10002', 'Balcony Garden', 'Small balcony with lots of plants.', 'completed', 85000.00),
('P10004', 'U10003', 'Modular Kitchen', 'Modern high-tech kitchen with island.', 'in_progress', 750000.00),
('P10005', 'U10004', 'Gaming Den', 'Neon lighting and soundproofing for streamers.', 'draft', 200000.00),
('P10006', 'U10005', 'Office Cabin', 'Ergonomic workspace for a corporate exec.', 'in_progress', 150000.00);

-- 5. Rooms
INSERT INTO `room` (`id`, `project_id`, `name`, `length_m`, `width_m`, `height_m`, `budget_estimate`) VALUES
('R1', 'P10001', 'Main Hall', 6.0, 5.0, 3.0, 300000.00),
('R2', 'P10002', 'Bedroom', 4.5, 4.0, 3.0, 200000.00),
('R3', 'P10003', 'Outdoor Space', 3.0, 1.5, 3.0, 50000.00),
('R4', 'P10004', 'Kitchen Area', 4.0, 3.0, 3.0, 600000.00),
('R5', 'P10005', 'Game Room', 3.5, 3.5, 3.0, 150000.00),
('R6', 'P10006', 'Cabin 1', 3.0, 3.0, 3.0, 100000.00);

-- 6. Designer Requests (v1 linkage)
INSERT INTO `designer_request` (`id`, `user_id`, `designer_id`, `project_id`, `status`) VALUES
('DR1', 'U10001', 'D20001', 'P10001', 'accepted'),
('DR2', 'U10001', 'D20002', 'P10002', 'pending'),
('DR3', 'U10002', 'D20003', 'P10003', 'accepted'),
('DR4', 'U10003', 'D20001', 'P10004', 'pending'),
('DR5', 'U10004', 'D20004', 'P10005', 'declined'),
('DR6', 'U10005', 'D20005', 'P10006', 'accepted');

-- 7. Catalogue Categories
INSERT INTO `catalogue_categories` (`id`, `name`, `image_url`) VALUES
(1, 'Sofas', 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800'),
(2, 'Beds', 'https://images.unsplash.com/photo-1505693314120-0d443867821c?w=800'),
(3, 'Dining', 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=800'),
(4, 'Offices', 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800'),
(5, 'Storage', 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=800'),
(6, 'Lighting', 'https://images.unsplash.com/photo-1513506496266-4d4c31be0552?w=800'),
(7, 'Decor', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800');

-- 8. Catalogue Items
INSERT INTO `catalogue_items` (`id`, `name`, `category`, `price`, `material`, `images`) VALUES
('C101', 'Imperial Velvet Sofa', 'Sofas', 125000.00, 'Luxury Velvet', '["https://images.unsplash.com/photo-1550581190-9c1c48d21d6c?w=600"]'),
('C102', 'Scandinavian Ash Sofa', 'Sofas', 85000.00, 'Fabric & Ash Wood', '["https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=600"]'),
('C103', 'Industrial Leather Loft', 'Sofas', 145000.00, 'Top Grain Leather', '["https://images.unsplash.com/photo-1540518614846-7eded433c457?w=600"]'),
('C201', 'Regis Gold-Trimmed Bed', 'Beds', 185000.00, 'Silk & Gold Plating', '["https://images.unsplash.com/photo-1505693314120-0d443867821c?w=600"]'),
('C202', 'Nordic Slatted Bed', 'Beds', 65000.00, 'Light Oak', '["https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600"]'),
('C301', 'Calacatta Marble Table', 'Dining', 210000.00, 'Italian Marble', '["https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=600"]'),
('C302', 'Draftsman Iron Table', 'Dining', 55000.00, 'Cast Iron & Pine', '["https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?w=600"]'),
('C401', 'Executive Walnut Desk', 'Offices', 88000.00, 'Black Walnut', '["https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600"]'),
('C402', 'Industrial Steel Desk', 'Offices', 42000.00, 'Cold-Rolled Steel', '["https://images.unsplash.com/photo-1593062096033-9a26b09da705?w=600"]'),
('C501', 'Monolith Wardrobe', 'Storage', 165000.00, 'Matte Lacquer', '["https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600"]'),
('C601', 'Brass Orb Chandelier', 'Lighting', 32000.00, 'Brushed Brass', '["https://images.unsplash.com/photo-1542728929-14a3ccd60698?w=600"]'),
('C602', 'Edison Bulb Multi-Light', 'Lighting', 18000.00, 'Aged Bronze', '["https://images.unsplash.com/photo-1513506496266-4d4c31be0552?w=600"]'),
('C701', 'Abstract Slate Canvas', 'Decor', 15000.00, 'Stretched Canvas', '["https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600"]');

-- 9. Design Styles (v2)
INSERT INTO `design_styles` (`id`, `name`, `description`, `base_prompt_suffix`) VALUES
('S1', 'Minimalist', 'Clean lines, neutral palette.', 'white walls, hardwood floor, minimalist furniture'),
('S2', 'Bohemian', 'Colorful, textured, natural.', 'lots of plants, macrame, warm lighting, eclectic rugs'),
('S3', 'Industrial', 'Raw materials, brick, metal.', 'exposed brick walls, iron ceiling beams, leather sofa'),
('S4', 'Scandinavian', 'Functional, simple, bright.', 'light wood, grey tones, cozy hygge atmosphere'),
('S5', 'Modern Classic', 'Elegant, structured, luxury.', 'crown molding, velvet furniture, gold accents');

-- 9. Design Requests (v2)
INSERT INTO `design_requests` (`id`, `user_id`, `room_id`, `style_id`, `status`) VALUES
('DR201', 'U10001', 'R1', 'S1', 'completed'),
('DR202', 'U10002', 'R3', 'S2', 'processing'),
('DR203', 'U10003', 'R4', 'S3', 'pending'),
('DR204', 'U10004', 'R5', 'S1', 'failed'),
('DR205', 'U10005', 'R6', 'S4', 'completed');

-- 10. Generated Images
INSERT INTO `generated_images` (`id`, `request_id`, `image_url`, `is_refined`) VALUES
('GI1', 'DR201', 'uploads/ai/gen_1_1.jpg', 0),
('GI2', 'DR201', 'uploads/ai/gen_1_2.jpg', 1),
('GI3', 'DR202', 'uploads/ai/gen_2_1.jpg', 0),
('GI4', 'DR205', 'uploads/ai/gen_5_1.jpg', 0),
('GI5', 'DR205', 'uploads/ai/gen_5_2.jpg', 1);

-- 11. Moodboards
INSERT INTO `moodboards` (`id`, `request_id`, `title`) VALUES
('MB1', 'DR201', 'Zen Living Concept'),
('MB2', 'DR205', 'Bright Workspace');

-- 12. Moodboard Elements
INSERT INTO `moodboard_elements` (`id`, `moodboard_id`, `element_type`, `content_url`) VALUES
('ME1', 'MB1', 'image', 'uploads/mood/swatch_white.jpg'),
('ME2', 'MB1', 'color', '#F5F5F5'),
('ME3', 'MB1', 'furniture', 'uploads/items/c1.png'),
('ME4', 'MB2', 'text', 'Focus on indirect natural light'),
('ME5', 'MB2', 'image', 'uploads/mood/desk_ref.jpg');

-- 13. Furniture Items (v2 internal)
INSERT INTO `furniture_items` (`id`, `name`, `category`, `price`, `image_url`) VALUES
('FI1', 'Tulip Chair', 'Seating', 12000.00, 'uploads/fur/tulip.jpg'),
('FI2', 'Arc Lamp', 'Lighting', 8500.00, 'uploads/fur/arc.jpg'),
('FI3', 'Suede Ottoman', 'Misc', 4500.00, 'uploads/fur/ottoman.jpg'),
('FI4', 'Glass Desk', 'Table', 15000.00, 'uploads/fur/desk.jpg'),
('FI5', 'Velvet Pillow', 'Decor', 1200.00, 'uploads/fur/pillow.jpg');

-- 14. Design Furniture Mapping
INSERT INTO `design_furniture_mapping` (`id`, `request_id`, `furniture_id`, `confidence_score`) VALUES
('DFM1', 'DR201', 'FI1', 0.95),
('DFM2', 'DR201', 'FI2', 0.88),
('DFM3', 'DR205', 'FI4', 0.92);

-- 15. Room Uploads
INSERT INTO `room_uploads` (`id`, `user_id`, `video_url`, `status`) VALUES
('RU1', 'U10001', 'uploads/scan/living_scan.mp4', 'ready'),
('RU2', 'U10002', 'uploads/scan/balcony_scan.mp4', 'ready'),
('RU3', 'U10003', 'uploads/scan/kitchen_scan.mp4', 'processing');

-- 16. Layout Recommendations
INSERT INTO `layout_recommendations` (`id`, `upload_id`, `recommendation_json`) VALUES
('LR1', 'RU1', '{"layout": "open", "zones": ["seating", "dining"]}'),
('LR2', 'RU2', '{"layout": "vertical_garden", "zones": ["relaxation"]}');

-- 17. AR Models
INSERT INTO `ar_models` (`id`, `furniture_id`, `usdz_url`, `glb_url`) VALUES
('AR1', 'FI1', 'assets/ar/tulip.usdz', 'assets/ar/tulip.glb'),
('AR2', 'FI2', 'assets/ar/arc.usdz', 'assets/ar/arc.glb');

-- 18. User AR Sessions
INSERT INTO `user_ar_sessions` (`id`, `user_id`, `model_id`) VALUES
('AS1', 'U10001', 'AR1'),
('AS2', 'U10001', 'AR2'),
('AS3', 'U10002', 'AR1');

-- 19. Chats
INSERT INTO `chats` (`id`, `user1_id`, `user2_id`) VALUES
('CH1', 'U10001', 'U20001'),
('CH2', 'U10002', 'U20003'),
('CH3', 'U10005', 'U20005'),
('CH4', 'U10001', 'U90001'),
('CH5', 'U20001', 'U90001');

-- 20. Messages
INSERT INTO `messages` (`id`, `chat_id`, `sender_id`, `receiver_id`, `message_text`, `is_read`) VALUES
('M1', 'CH1', 'U10001', 'U20001', 'Hi Alex, lets start!', 1),
('M2', 'CH1', 'U20001', 'U10001', 'Sure John, send me the room dimensions.', 1),
('M3', 'CH2', 'U10002', 'U20003', 'Sarah, the garden looks great!', 1),
('M4', 'CH4', 'U90001', 'U10001', 'Welcome to VibeUp Admin Support.', 0),
('M5', 'CH5', 'U20001', 'U90001', 'I have a bug in my portfolio page.', 0);

-- 21. Notifications
INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `message`, `reference_id`) VALUES
('N1', 'U20001', 'request_new', 'New Request', 'John Miller sent a request.', 'DR1'),
('N2', 'U10001', 'request_accepted', 'Request Accepted', 'Alex Turner is on board!', 'DR1'),
('N3', 'U20003', 'request_accepted', 'Request Accepted', 'You accepted Ananyas project.', 'DR3'),
('N4', 'U10001', 'message_new', 'New Message', 'Alex: Sure John...', 'CH1'),
('N5', 'U90001', 'admin_update', 'System Maint', 'Server update at 2AM.', NULL);

-- 22. Activity Logs
INSERT INTO `activity_logs` (`id`, `actor_id`, `action`, `entity_type`, `entity_id`) VALUES
('L1', 'U10001', 'upload', 'room_upload', 'RU1'),
('L2', 'U20001', 'accept', 'designer_request', 'DR1'),
('L3', 'U90001', 'delete', 'user', 'U99999'),
('L4', 'U10002', 'create', 'moodboard', 'MB1'),
('L5', 'U10003', 'process', 'design_request', 'DR203');

-- 23. Feedback
INSERT INTO `feedback` (`id`, `from_user_id`, `to_user_id`, `project_id`, `rating`, `comment`) VALUES
('F1', 'U10002', 'U20003', 'P10003', 5, 'Best designer ever!'),
('F2', 'U10005', 'U20005', 'P10006', 4, 'Very professional.'),
('F3', 'U10001', 'U20001', 'P10001', 5, 'Amazing living room concept.');

-- 24. AI Prompts (v1 table)
INSERT INTO `ai_prompts` (`id`, `user_id`, `room_id`, `prompt_text`, `style`, `status`) VALUES
('AIP1', 'U10001', 'R1', 'Modern living room with plants', 'Modern', 'done'),
('AIP2', 'U10002', 'R3', 'Cozy balcony garden', 'Bohemian', 'done');

SET FOREIGN_KEY_CHECKS = 1;

-- Final Update of last_activity for current online status simulation
UPDATE `user` SET `last_activity` = NOW();
