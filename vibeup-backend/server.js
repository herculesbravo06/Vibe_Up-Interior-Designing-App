const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();
const { syncDatabase } = require('./utils/dbSync');

// 🛡️ Global Exception Handlers (Permanence)
process.on('uncaughtException', (err) => {
    console.error('🔥 CRITICAL ERROR (Uncaught Exception):', err);
    // Keep server running in development; logic for graceful restart can be added here
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('🌊 UNHANDLED REJECTION at:', promise, 'reason:', reason);
});

const apiRoutes = require('./routes/apiRoutes');
const aiRoutes = require('./routes/aiRoutes');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST", "PUT"]
    }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.static('public'));

// Request logging
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Share io instance with routes/controllers via req
app.use((req, res, next) => {
    req.io = io;
    next();
});

// Base route
app.get('/', (req, res) => {
    res.json({ message: 'VibeUp Backend API is online!', realtime: 'enabled', timestamp: new Date().toISOString() });
});

app.use('/api', apiRoutes);
app.use('/api/ai', aiRoutes);


// Socket.io connection handling
io.on('connection', (socket) => {
    console.log(`🔌 New client connected: ${socket.id}`);
    
    socket.on('join_project', (projectId) => {
        socket.join(`project_${projectId}`);
        console.log(`📁 Client ${socket.id} joined project_${projectId}`);
    });

    socket.on('disconnect', () => {
        console.log('❌ Client disconnected');
    });
});

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

// Initialize Environment and Start Server
async function boot() {
    console.log('🏗️  Starting VibeUp Backend Initialization...');
    const dbReady = await syncDatabase();
    
    if (!dbReady) {
        console.warn('⚠️  Database sync failed, starting with degraded functionality.');
    }

    server.listen(PORT, HOST, () => {
        console.log(`🚀 VibeUp VR Backend running on http://${HOST}:${PORT}`);
        console.log(`📱 Mobile access: http://172.16.6.137:${PORT}`);
        console.log(`🕶️  VR endpoint: POST http://172.16.6.137:${PORT}/api/rooms`);
    });
}

boot();
