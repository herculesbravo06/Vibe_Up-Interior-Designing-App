-- schema.sql
-- Run this script in your MySQL server (via phpMyAdmin or CLI) to initialize the database.

-- Create database
CREATE DATABASE IF NOT EXISTS `vibe_up` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `vibe_up`;

-- Note: In the provided dump, foreign keys reference tables without dropping them first securely if they exist.
-- To allow re-running, disable foreign key checks temporarily.
SET FOREIGN_KEY_CHECKS = 0;

-- v1 tables
DROP TABLE IF EXISTS `ai_prompts`;
DROP TABLE IF EXISTS `catalogue_items`;
DROP TABLE IF EXISTS `catalogue_categories`;
DROP TABLE IF EXISTS `designer`;
DROP TABLE IF EXISTS `designer_qualification`;
DROP TABLE IF EXISTS `designer_request`;
DROP TABLE IF EXISTS `feedback`;
DROP TABLE IF EXISTS `room`;
DROP TABLE IF EXISTS `project`;
DROP TABLE IF EXISTS `user`;

-- v2 tables (chat, AI design, AR)
DROP TABLE IF EXISTS `user_ar_sessions`;
DROP TABLE IF EXISTS `ar_models`;
DROP TABLE IF EXISTS `layout_recommendations`;
DROP TABLE IF EXISTS `room_uploads`;
DROP TABLE IF EXISTS `design_furniture_mapping`;
DROP TABLE IF EXISTS `furniture_items`;
DROP TABLE IF EXISTS `moodboard_elements`;
DROP TABLE IF EXISTS `moodboards`;
DROP TABLE IF EXISTS `generated_images`;
DROP TABLE IF EXISTS `design_requests`;
DROP TABLE IF EXISTS `design_styles`;
DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `chats`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `activity_logs`;

SET FOREIGN_KEY_CHECKS = 1;

-- Table structure for table `user`
CREATE TABLE `user` (
  `id` char(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `password` varchar(255) DEFAULT NULL COMMENT 'Plain text password for api_v2 compatibility',
  `phone` varchar(15) NOT NULL,
  `profile_pic_url` text DEFAULT NULL,
  `dob` date NOT NULL,
  `role` enum('user','designer','admin') DEFAULT 'user',
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table structure for table `user`

ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

-- Table structure for table `project`
CREATE TABLE `project` (
  `id` char(20) NOT NULL,
  `user_id` char(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('draft','in_progress','completed') DEFAULT 'draft',
  `currency` varchar(3) DEFAULT 'INR',
  `total_estimated_cost` decimal(12,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `designer_id` char(20) DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `project`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_project_user` (`user_id`);


-- Table structure for table `room`
CREATE TABLE `room` (
  `id` char(20) NOT NULL,
  `project_id` char(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `length_m` decimal(6,2) DEFAULT NULL,
  `width_m` decimal(6,2) DEFAULT NULL,
  `height_m` decimal(6,2) DEFAULT NULL,
  `room_3d_model_url` text DEFAULT NULL,
  `budget_estimate` decimal(12,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `room`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_room_project` (`project_id`);


-- Table structure for table `designer`
CREATE TABLE `designer` (
  `id` char(20) NOT NULL,
  `user_id` char(20) NOT NULL,
  `bio` text DEFAULT NULL,
  `experience_years` int(11) DEFAULT NULL,
  `portfolio_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`portfolio_urls`)),
  `rating` decimal(2,1) DEFAULT 0.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `designer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_designer_user` (`user_id`);

-- Table structure for table `designer_qualification`
CREATE TABLE `designer_qualification` (
  `id` char(20) NOT NULL,
  `designer_id` char(20) NOT NULL,
  `qualification_name` varchar(50) NOT NULL,
  `institute_name` varchar(100) DEFAULT NULL,
  `year_completed` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `designer_qualification`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_qualification_designer` (`designer_id`);

-- Table structure for table `designer_request`
CREATE TABLE `designer_request` (
  `id` char(20) NOT NULL,
  `user_id` char(20) DEFAULT NULL,
  `designer_id` char(20) DEFAULT NULL,
  `project_id` char(20) DEFAULT NULL,
  `status` enum('pending','live','accepted','declined','solved') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `designer_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_request_user` (`user_id`),
  ADD KEY `fk_request_project` (`project_id`),
  ADD KEY `fk_request_designer` (`designer_id`);


-- Table structure for table `feedback`
CREATE TABLE `feedback` (
  `id` char(20) NOT NULL,
  `from_user_id` char(20) DEFAULT NULL,
  `to_user_id` char(20) DEFAULT NULL,
  `project_id` char(20) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('approved','blocked') DEFAULT 'approved'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_feedback_from_user` (`from_user_id`),
  ADD KEY `fk_feedback_to_user` (`to_user_id`),
  ADD KEY `fk_feedback_project` (`project_id`);


-- Table structure for table `ai_prompts`
CREATE TABLE `ai_prompts` (
  `id` char(20) NOT NULL,
  `user_id` char(20) DEFAULT NULL,
  `room_id` char(20) DEFAULT NULL,
  `prompt_text` text DEFAULT NULL,
  `style` varchar(50) DEFAULT NULL,
  `status` enum('queued','processing','done','failed') DEFAULT 'done',
  `result_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`result_images`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `ai_prompts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_prompt_user` (`user_id`),
  ADD KEY `fk_prompt_room` (`room_id`);

-- Table structure for table `catalogue_categories`
CREATE TABLE `catalogue_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `image_url` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `catalogue_items`
CREATE TABLE `catalogue_items` (
  `id` char(20) NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  `category` varchar(20) DEFAULT NULL,
  `dimensions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dimensions`)),
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'INR',
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `material` varchar(50) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `catalogue_items`
  ADD PRIMARY KEY (`id`);

-- Constraints for dumped tables
ALTER TABLE `ai_prompts`
  ADD CONSTRAINT `fk_prompt_room` FOREIGN KEY (`room_id`) REFERENCES `room` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_prompt_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `designer_qualification`
  ADD CONSTRAINT `fk_qualification_designer` FOREIGN KEY (`designer_id`) REFERENCES `designer` (`id`) ON DELETE CASCADE;

ALTER TABLE `designer_request`
  ADD CONSTRAINT `fk_request_designer` FOREIGN KEY (`designer_id`) REFERENCES `designer` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_request_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_request_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `feedback`
  ADD CONSTRAINT `fk_feedback_from_user` FOREIGN KEY (`from_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_feedback_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_feedback_to_user` FOREIGN KEY (`to_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `project`
  ADD CONSTRAINT `fk_project_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `room`
  ADD CONSTRAINT `fk_room_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE;


-- ============================================================
-- V2 TABLES: Chat, AI Design, Moodboard, Furniture, AR
-- ============================================================

-- AI DESIGN & REQUESTS
CREATE TABLE `design_styles` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `name` varchar(50) NOT NULL,
  `description` text,
  `base_prompt_suffix` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `design_requests` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `user_id` char(20) NOT NULL,
  `room_id` char(20) DEFAULT NULL,
  `style_id` char(20) DEFAULT NULL,
  `prompt_override` text,
  `status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `generated_images` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `request_id` char(20) NOT NULL,
  `image_url` text NOT NULL,
  `is_refined` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MOODBOARD SYSTEM
CREATE TABLE `moodboards` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `request_id` char(20) NOT NULL,
  `title` varchar(100) DEFAULT 'My Moodboard',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `moodboard_elements` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `moodboard_id` char(20) NOT NULL,
  `element_type` enum('image','color','text','furniture') NOT NULL,
  `content_url` text,
  `pos_x` float DEFAULT 0,
  `pos_y` float DEFAULT 0,
  `scale` float DEFAULT 1.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- FURNITURE & MAPPING
CREATE TABLE `furniture_items` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `name` varchar(100) NOT NULL,
  `category` varchar(50),
  `price` decimal(10,2),
  `image_url` text,
  `model_3d_url` text,
  `affiliate_url` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `design_furniture_mapping` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `request_id` char(20) NOT NULL,
  `furniture_id` char(20) NOT NULL,
  `confidence_score` float DEFAULT 0.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- AR & ROOM SCANNING
CREATE TABLE `room_uploads` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `user_id` char(20) NOT NULL,
  `video_url` text,
  `processed_model_url` text,
  `status` enum('uploaded','processing','ready','error') DEFAULT 'uploaded',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `layout_recommendations` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `upload_id` char(20) NOT NULL,
  `recommendation_json` longtext,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `ar_models` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `furniture_id` char(20) NOT NULL,
  `usdz_url` text,
  `glb_url` text,
  `scale_factor` float DEFAULT 1.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `user_ar_sessions` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `user_id` char(20) NOT NULL,
  `model_id` char(20) NOT NULL,
  `last_placed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- CHAT SYSTEM
CREATE TABLE `chats` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `user1_id` char(20) NOT NULL,
  `user2_id` char(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `unique_chat` (`user1_id`, `user2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `messages` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `chat_id` char(20) NOT NULL,
  `sender_id` char(20) NOT NULL,
  `receiver_id` char(20) NOT NULL,
  `message_text` text NOT NULL,
  `file_url` text DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- NOTIFICATION SYSTEM
CREATE TABLE `notifications` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `user_id` char(20) NOT NULL,
  `type` enum('request_new','request_accepted','request_declined','message_new','design_uploaded','admin_update') NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text DEFAULT NULL,
  `reference_id` char(20) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ACTIVITY LOGS (admin audit trail)
CREATE TABLE `activity_logs` (
  `id` char(20) NOT NULL PRIMARY KEY,
  `actor_id` char(20) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` char(20) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- V2 TABLE CONSTRAINTS
ALTER TABLE `chats`
  ADD CONSTRAINT `fk_chat_user1` FOREIGN KEY (`user1_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_chat_user2` FOREIGN KEY (`user2_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `messages`
  ADD CONSTRAINT `fk_message_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_message_sender` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_message_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `design_requests`
  ADD CONSTRAINT `fk_dreq_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `generated_images`
  ADD CONSTRAINT `fk_genimg_request` FOREIGN KEY (`request_id`) REFERENCES `design_requests` (`id`) ON DELETE CASCADE;

ALTER TABLE `moodboards`
  ADD CONSTRAINT `fk_mb_request` FOREIGN KEY (`request_id`) REFERENCES `design_requests` (`id`) ON DELETE CASCADE;

ALTER TABLE `moodboard_elements`
  ADD CONSTRAINT `fk_mbe_moodboard` FOREIGN KEY (`moodboard_id`) REFERENCES `moodboards` (`id`) ON DELETE CASCADE;

ALTER TABLE `design_furniture_mapping`
  ADD CONSTRAINT `fk_dfm_request` FOREIGN KEY (`request_id`) REFERENCES `design_requests` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dfm_furniture` FOREIGN KEY (`furniture_id`) REFERENCES `furniture_items` (`id`) ON DELETE CASCADE;

ALTER TABLE `room_uploads`
  ADD CONSTRAINT `fk_rupload_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `layout_recommendations`
  ADD CONSTRAINT `fk_layout_upload` FOREIGN KEY (`upload_id`) REFERENCES `room_uploads` (`id`) ON DELETE CASCADE;

ALTER TABLE `ar_models`
  ADD CONSTRAINT `fk_ar_furniture` FOREIGN KEY (`furniture_id`) REFERENCES `furniture_items` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_ar_sessions`
  ADD CONSTRAINT `fk_arsess_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_arsess_model` FOREIGN KEY (`model_id`) REFERENCES `ar_models` (`id`) ON DELETE CASCADE;

ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_log_actor` FOREIGN KEY (`actor_id`) REFERENCES `user` (`id`) ON DELETE SET NULL;
