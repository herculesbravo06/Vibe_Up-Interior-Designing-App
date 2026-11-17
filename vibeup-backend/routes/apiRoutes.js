const express = require('express');
const router = express.Router();
const { saveRoomLayout, getRoomLayout, updateRoomLayout, getRoomLayoutsByProject } = require('../controllers/roomController');
const { 
    getWishlist, addToWishlist, removeFromWishlist, 
    getBudget, addToBudget, removeFromBudget 
} = require('../controllers/userContentController');

// Room endpoints
router.post('/rooms', saveRoomLayout);
router.get('/rooms/:id', getRoomLayout);
router.put('/rooms/:id', updateRoomLayout);
router.get('/rooms/project/:projectId', getRoomLayoutsByProject);

// Wishlist endpoints
router.get('/wishlist/:userId', getWishlist);
router.post('/wishlist', addToWishlist);
router.delete('/wishlist/:userId/:itemId', removeFromWishlist);

// Budget endpoints
router.get('/budget/:userId', getBudget);
router.post('/budget', addToBudget);
router.delete('/budget/:userId/:itemId', removeFromBudget);

module.exports = router;
