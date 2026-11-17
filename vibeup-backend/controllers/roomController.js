const db = require('../config/db');

// Helper to emit events safely
const emitToProject = (req, projectId, event, data) => {
    if (req.io) {
        req.io.to(`project_${projectId}`).emit(event, data);
        // Also broadcast globally for dashboard oversight
        req.io.emit('global_activity', { type: event, projectId, ...data });
    }
};

// @desc Save a new room layout
// @route POST /api/rooms
const saveRoomLayout = async (req, res) => {
    try {
        const { project_id, layout_data } = req.body;
        
        if (!project_id) {
            return res.status(400).json({ success: false, message: 'project_id is required' });
        }
        
        const safeLayoutData = layout_data || [];

        const [result] = await db.execute(
            'INSERT INTO room_layouts (project_id, layout_data) VALUES (?, ?)',
            [project_id, JSON.stringify(safeLayoutData)]
        );

        console.log(`✅ VR Layout saved: ID=${result.insertId}, project=${project_id}`);

        // EMIT REAL-TIME EVENT
        emitToProject(req, project_id, 'layout_updated', {
            layout_id: result.insertId,
            item_count: safeLayoutData.length,
            timestamp: new Date().toISOString()
        });

        res.status(201).json({
            success: true,
            message: 'Room layout saved successfully',
            layout_id: result.insertId
        });
    } catch (error) {
        console.error('❌ Error saving room layout:', error.message);
        res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
    }
};

// @desc Fetch a room layout
const getRoomLayout = async (req, res) => {
    try {
        const { id } = req.params;
        const [rows] = await db.execute(
            'SELECT * FROM room_layouts WHERE id = ?',
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Room layout not found' });
        }

        const row = rows[0];
        if (typeof row.layout_data === 'string') {
            try { row.layout_data = JSON.parse(row.layout_data); } catch (e) { /* keep as-is */ }
        }

        res.status(200).json({
            success: true,
            data: row
        });
    } catch (error) {
        console.error('❌ Error fetching room:', error.message);
        res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
    }
};

// @desc Update an existing room layout
const updateRoomLayout = async (req, res) => {
    try {
        const { id } = req.params;
        const { layout_data } = req.body;

        if (!layout_data) {
            return res.status(400).json({ success: false, message: 'layout_data is required' });
        }

        // We need project_id to emit correctly, so we fetch it first or require it in body
        const [existing] = await db.execute('SELECT project_id FROM room_layouts WHERE id = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ success: false, message: 'Room layout not found' });
        }
        const projectId = existing[0].project_id;

        const [result] = await db.execute(
            'UPDATE room_layouts SET layout_data = ? WHERE id = ?',
            [JSON.stringify(layout_data), id]
        );

        console.log(`✅ VR Layout updated: ID=${id}`);

        // EMIT REAL-TIME EVENT
        emitToProject(req, projectId, 'layout_updated', {
            layout_id: id,
            item_count: layout_data.length,
            timestamp: new Date().toISOString()
        });

        res.status(200).json({ success: true, message: 'Room layout updated successfully' });
    } catch (error) {
        console.error('❌ Error updating room:', error.message);
        res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
    }
};

// @desc Get all room layouts for a project
const getRoomLayoutsByProject = async (req, res) => {
    try {
        const { projectId } = req.params;
        const [rows] = await db.execute(
            'SELECT * FROM room_layouts WHERE project_id = ? ORDER BY updated_at DESC',
            [projectId]
        );
        
        rows.forEach(row => {
            if (typeof row.layout_data === 'string') {
                try { row.layout_data = JSON.parse(row.layout_data); } catch (e) { /* keep as-is */ }
            }
        });

        res.status(200).json({
            success: true,
            data: rows
        });
    } catch (error) {
        console.error('❌ Error fetching layouts for project:', error.message);
        res.status(500).json({ success: false, message: 'Server Error: ' + error.message });
    }
};

module.exports = {
    saveRoomLayout,
    getRoomLayout,
    updateRoomLayout,
    getRoomLayoutsByProject
};
