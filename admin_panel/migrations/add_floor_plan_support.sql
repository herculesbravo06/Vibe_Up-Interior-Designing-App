-- Migration: Add floor plan support to project table
-- Run this against your database to enable the Upload Floor Plan feature

ALTER TABLE project ADD COLUMN IF NOT EXISTS type VARCHAR(20) DEFAULT 'generate';
ALTER TABLE project ADD COLUMN IF NOT EXISTS floor_plan_url VARCHAR(500) NULL;

-- Add room detection columns
ALTER TABLE room ADD COLUMN IF NOT EXISTS room_type VARCHAR(50) DEFAULT 'general';
ALTER TABLE room ADD COLUMN IF NOT EXISTS coordinates TEXT NULL;
ALTER TABLE room ADD COLUMN IF NOT EXISTS design_status VARCHAR(20) DEFAULT 'pending';
ALTER TABLE room ADD COLUMN IF NOT EXISTS model_3d_url VARCHAR(500) NULL;

-- Export tracking table
CREATE TABLE IF NOT EXISTS project_export (
    id VARCHAR(50) PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    pdf_url VARCHAR(500),
    jpeg_url VARCHAR(500),
    model_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
