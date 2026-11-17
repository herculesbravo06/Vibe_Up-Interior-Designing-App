// Quick setup script: creates the vibe_up database and core Node.js tables
// NOTE: The canonical `user` and `project` tables are managed by the PHP admin panel.
const mysql = require('mysql2/promise');
require('dotenv').config();

async function setup() {
  let conn;
  try {
    conn = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true,
    });
    
    console.log('Connected to MySQL');
    
    const dbName = process.env.DB_NAME || 'vibe_up';
    await conn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
    console.log(`✅ Database ${dbName} ensured`);
    
    await conn.query(`USE \`${dbName}\``);
    
    // Wishlist (user_id VARCHAR(50) for PHP char(20) compatibility)
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
    console.log('✅ wishlist table ensured');

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
    console.log('✅ budget_items table ensured');

    await conn.query(`
      CREATE TABLE IF NOT EXISTS ai_chats (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        message TEXT,
        response TEXT,
        type VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);
    console.log('✅ ai_chats table ensured');

    await conn.query(`
      CREATE TABLE IF NOT EXISTS vastu_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        room_type VARCHAR(255),
        suggestion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);
    console.log('✅ vastu_logs table ensured');

    await conn.query(`
      CREATE TABLE IF NOT EXISTS ai_images (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50),
        prompt TEXT,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`);
    console.log('✅ ai_images table ensured');

    await conn.query(`
      CREATE TABLE IF NOT EXISTS room_layouts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        project_id VARCHAR(50),
        layout_data LONGTEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )`);
    console.log('✅ room_layouts table ensured');
    
    console.log('\\n🎉 Database setup complete!');
  } catch (err) {
    console.error('❌ Setup error:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

setup();
