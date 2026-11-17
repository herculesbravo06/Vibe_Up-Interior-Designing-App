-- Migration: Add scene_data column to room table
-- This column stores the JSON string representing the 3D layout of the room.

ALTER TABLE `room` ADD COLUMN IF NOT EXISTS `scene_data` LONGTEXT NULL AFTER `budget_estimate`;

-- Optional: If you want to migrate existing data or ensure the column exists
-- ALTER TABLE `room` MODIFY COLUMN `scene_data` LONGTEXT NULL;
