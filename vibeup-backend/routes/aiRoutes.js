const express = require('express');
const router = express.Router();
const aiRouter = require('../ai/router');
const mysql = require('mysql2/promise');
require('dotenv').config();

// DB Connection for AI logging
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'vibe_up',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// 🛡️ Pool Error Listener (Connection Persistence)
pool.on('error', (err) => {
  console.error('⚠️ [MySQL Pool] Unexpected error on idle client:', err);
});

// AI Chat Endpoint
router.post('/chat', async (req, res) => {
  const { message, userId, messages = [], voiceOutput = false, type = 'text', projectId } = req.body;
  
  if (!message || !userId) {
    return res.status(400).json({ status: 'error', message: 'Missing message or userId' });
  }

  try {
    const result = await aiRouter.process(message, userId, { type, messages, voiceOutput });
    
    // 1. Log to DB (ai_chats)
    if (result.status === 'success') {
      const chatQuery = 'INSERT INTO ai_chats (user_id, message, response, type) VALUES (?, ?, ?, ?)';
      await pool.execute(chatQuery, [userId, message, result.response || '', result.type]);
      
      // 2. If Vastu suggestion was made, log it
      if (result.vastuApplied) {
        const vastuQuery = 'INSERT INTO vastu_logs (user_id, room_type, suggestion) VALUES (?, ?, ?)';
        await pool.execute(vastuQuery, [userId, 'general', result.response]);
      }
    }

    res.json(result);
  } catch (error) {
    console.error('Route error:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// AI Image Generation Endpoint
router.post('/generate-image', async (req, res) => {
   const { prompt, userId, projectId } = req.body;
   
   if (!prompt || !userId) {
     return res.status(400).json({ status: 'error', message: 'Missing prompt or userId' });
   }

   try {
     const result = await aiRouter.process(prompt, userId, { type: 'image' });
     
     if (result.status === 'success' && Array.isArray(result.data)) {
       // Log images to DB
       for (const url of result.data) {
         await pool.execute('INSERT INTO ai_images (user_id, prompt, image_url) VALUES (?, ?, ?)', [userId, prompt, url]);
       }
     }

     res.json(result);
   } catch (error) {
     res.status(500).json({ status: 'error', message: error.message });
   }
});

// GET AI Chat History for Sidebar
router.get('/history/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const [rows] = await pool.execute(
      'SELECT id, message, response, type, created_at FROM ai_chats WHERE user_id = ? ORDER BY created_at DESC LIMIT 50', 
      [userId]
    );
    res.json({ status: 'success', data: rows });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

module.exports = router;
