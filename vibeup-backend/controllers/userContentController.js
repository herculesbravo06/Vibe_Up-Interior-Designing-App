const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'vibe_up',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

const getWishlist = async (req, res) => {
    try {
        const { userId } = req.params;
        const [rows] = await pool.query('SELECT * FROM wishlist WHERE user_id = ?', [userId]);
        res.json({ status: 'success', data: rows });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

const addToWishlist = async (req, res) => {
    try {
        const { userId, itemId, itemData, isAi } = req.body;
        await pool.query(
            'INSERT INTO wishlist (user_id, item_id, item_data, is_ai) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE item_data = ?',
            [userId, itemId, JSON.stringify(itemData), isAi, JSON.stringify(itemData)]
        );
        res.json({ status: 'success', message: 'Item added to wishlist' });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

const removeFromWishlist = async (req, res) => {
    try {
        const { userId, itemId } = req.params;
        await pool.query('DELETE FROM wishlist WHERE user_id = ? AND item_id = ?', [userId, itemId]);
        res.json({ status: 'success', message: 'Item removed from wishlist' });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

const getBudget = async (req, res) => {
    try {
        const { userId } = req.params;
        const [rows] = await pool.query('SELECT * FROM budget_items WHERE user_id = ?', [userId]);
        res.json({ status: 'success', data: rows });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

const addToBudget = async (req, res) => {
    try {
        const { userId, itemId, itemName, category, price, quantity, imageUrl } = req.body;
        await pool.query(
            'INSERT INTO budget_items (user_id, item_id, item_name, category, price, quantity, image_url) VALUES (?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE quantity = ?, price = ?',
            [userId, itemId, itemName, category, price, quantity, imageUrl, quantity, price]
        );
        res.json({ status: 'success', message: 'Budget item updated' });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

const removeFromBudget = async (req, res) => {
    try {
        const { userId, itemId } = req.params;
        await pool.query('DELETE FROM budget_items WHERE user_id = ? AND item_id = ?', [userId, itemId]);
        res.json({ status: 'success', message: 'Item removed from budget' });
    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

module.exports = {
    getWishlist,
    addToWishlist,
    removeFromWishlist,
    getBudget,
    addToBudget,
    removeFromBudget
};
