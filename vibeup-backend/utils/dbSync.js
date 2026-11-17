const mysql = require('mysql2/promise');
require('dotenv').config();

/**
 * Synchronizes the database schema by ensuring all Node.js-managed tables exist.
 * 
 * IMPORTANT: The canonical `user` and `project` tables are managed by the PHP
 * admin panel. This script only ensures the Node.js-specific tables (wishlist, 
 * budget, AI logs, room layouts) exist with compatible column types.
 * 
 * User IDs are VARCHAR(50) to match the PHP `user.id` (char(20)) format.
 */
async function syncDatabase() {
  let conn;
  try {
    const dbConfig = {
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true,
    };
    
    conn = await mysql.createConnection(dbConfig);
    console.log('🔄 [DB Sync] Connected to MySQL for environment verification...');
    
    const dbName = process.env.DB_NAME || 'vibe_up';
    await conn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
    await conn.query(`USE \`${dbName}\``);
    
    // NOTE: `user` and `project` tables are managed by PHP admin_panel.
    // We do NOT create or modify them here.

    // 1. Wishlist Table (user_id = VARCHAR(50) for PHP char(20) compatibility)
    await conn.query(`
      CREATE TABLE IF NOT EXISTS wishlist (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        item_id VARCHAR(255),
        item_data JSON,
        is_ai BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (user_id, item_id)
      )`);

    // 2. Budget Items Table
    await conn.query(`
      CREATE TABLE IF NOT EXISTS budget_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        item_id VARCHAR(255) NOT NULL,
        item_name VARCHAR(255),
        category VARCHAR(255),
        price DECIMAL(10, 2),
        quantity INT DEFAULT 1,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (user_id, item_id)
      )`);

    // 3. AI Chat Logs
    await conn.query(`
      CREATE TABLE IF NOT EXISTS ai_chats (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        message TEXT,
        response TEXT,
        type VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);

    // 4. Vastu Logs
    await conn.query(`
      CREATE TABLE IF NOT EXISTS vastu_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        room_type VARCHAR(255),
        suggestion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);

    // 5. AI Generated Images
    await conn.query(`
      CREATE TABLE IF NOT EXISTS ai_images (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        prompt TEXT,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);

    // 6. Room Layouts (managed by Node.js for VR sync)
    await conn.query(`
      CREATE TABLE IF NOT EXISTS room_layouts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id VARCHAR(50),
        layout_data LONGTEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )`);

    console.log('✅ [DB Sync] Database environment verified and synchronized.');
    return true;
  } catch (err) {
    console.error('❌ [DB Sync] Critical Setup Error:', err.message);
    return false;
  } finally {
    if (conn) await conn.end();
  }
}

module.exports = { syncDatabase };
