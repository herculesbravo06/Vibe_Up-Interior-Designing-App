const mysql = require('mysql2/promise');
require('dotenv').config();

async function updateDb() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'vibe_up'
    });

    console.log('🚀 Updating database schema...');

    try {
        await connection.query(`
            CREATE TABLE IF NOT EXISTS ai_chats (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                message TEXT,
                response TEXT,
                type VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('✅ ai_chats table ready');

        await connection.query(`
            CREATE TABLE IF NOT EXISTS ai_images (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                prompt TEXT,
                image_url TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('✅ ai_images table ready');

        await connection.query(`
            CREATE TABLE IF NOT EXISTS vastu_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                room_type VARCHAR(255),
                suggestion TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('✅ vastu_logs table ready');

    } catch (err) {
        console.error('❌ Error updating database:', err.message);
    } finally {
        await connection.end();
        process.exit();
    }
}

updateDb();
