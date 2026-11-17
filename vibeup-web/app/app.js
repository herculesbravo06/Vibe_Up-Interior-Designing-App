/* ═══════════════════════════════════════════════════════════════
   VIBEUP WEB APP — Core Application JavaScript
   API Client, Auth Manager, Utilities
   ═══════════════════════════════════════════════════════════════ */

const currentHost = window.location.hostname || 'localhost';
const APP_CONFIG = {
    apiUrl: window.location.protocol + '//' + currentHost + '/scratch/admin_panel/', // Base PHP API
    phpApi: window.location.protocol + '//' + currentHost + '/scratch/admin_panel/', 
    nodeApi: window.location.protocol + '//' + currentHost + ':5000/api/',
    heartbeatInterval: 120000, // 2 minutes
    activityPollInterval: 10000, // 10 seconds
};

// ─────────────────────────────────────────────────────────────
// API CLIENT
// ─────────────────────────────────────────────────────────────
const Api = {
    async post(endpoint, data) {
        try {
            const res = await fetch(APP_CONFIG.phpApi + endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data),
            });
            return await res.json();
        } catch (e) {
            console.error('API POST error:', e);
            return { status: 'error', message: e.message };
        }
    },

    async get(endpoint) {
        try {
            const res = await fetch(APP_CONFIG.phpApi + endpoint, {
                method: 'GET',
            });
            return await res.json();
        } catch (e) {
            console.error('API GET error:', e);
            return { status: 'error', message: e.message };
        }
    },

    async nodePost(endpoint, data) {
        try {
            const res = await fetch(APP_CONFIG.nodeApi + endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data),
            });
            return await res.json();
        } catch (e) {
            console.error('Node API error:', e);
            return { status: 'error', message: e.message };
        }
    },

    async nodeGet(endpoint) {
        try {
            const res = await fetch(APP_CONFIG.nodeApi + endpoint);
            return await res.json();
        } catch (e) {
            return { status: 'error', message: e.message };
        }
    },

    // ─── Auth ───
    async login(email, password, role = 'user') {
        const action = role === 'designer' ? 'login_designer' : 'login_user';
        return this.post('api/auth.php', { action, email, password });
    },

    async register(name, email, password, phone, dob) {
        const data = { action: 'register_user', name, email, password };
        if (phone) data.phone = phone;
        if (dob) data.dob = dob;
        return this.post('api/auth.php', data);
    },

    // ─── Designers ───
    async getDesigners() {
        return this.get('api/designers.php');
    },

    async getDesignerDetails(id) {
        return this.get(`api/designers.php?id=${id}`);
    },

    async getDesignerStats(designerId) {
        return this.get(`api_v2/get_designer_stats.php?designer_id=${designerId}`);
    },

    // ─── Projects ───
    async getUserProjects(userId) {
        return this.get(`api/projects.php?user_id=${userId}`);
    },

    async createProject(projectData) {
        return this.post('api/projects.php', projectData);
    },

    async updateProject(projectData) {
        return this.post('api/projects.php', projectData);
    },

    // ─── Design Requests ───
    async createDesignRequest(data) {
        return this.post('api_v2/requests.php', { action: 'create', ...data });
    },

    async getDesignRequests(params = {}) {
        let url = 'api_v2/requests.php?action=list';
        if (params.designer_id) url += `&designer_id=${params.designer_id}`;
        if (params.user_id) url += `&user_id=${params.user_id}`;
        if (params.status) url += `&status=${params.status}`;
        return this.get(url);
    },

    async updateRequestStatus(requestId, newStatus, actorId) {
        return this.post('api_v2/requests.php', {
            action: 'update_status',
            request_id: requestId,
            status: newStatus,
            actor_id: actorId,
        });
    },

    // ─── Feedback ───
    async submitFeedback(data) {
        return this.post('api/feedback.php', data);
    },

    async getDesignerFeedback(designerId) {
        return this.get(`api/feedback.php?designer_id=${designerId}`);
    },

    // ─── Catalogue ───
    async getCatalogue() {
        return this.get('api/catalogue.php?action=sync');
    },

    async getCatalogueItems(category) {
        let url = 'api/catalogue.php?action=items';
        if (category) url += `&category=${category}`;
        return this.get(url);
    },

    // ─── Notifications ───
    async getNotifications(userId) {
        return this.get(`api_v2/notifications.php?user_id=${userId}`);
    },

    // ─── VR/Room Sync ───
    async saveRoomLayout(projectId, layoutData) {
        return this.nodePost('rooms', {
            project_id: parseInt(projectId) || 1,
            layout_data: layoutData,
        });
    },

    async getRoomLayout(layoutId) {
        return this.nodeGet(`rooms/${layoutId}`);
    },

    // ─── AI Assistant ───
    async askAI(message, userId, history = [], options = {}) {
        return this.nodePost('ai/chat', {
            message,
            userId,
            messages: history,
            ...options
        });
    },

    async generateAiImage(prompt, userId) {
        return this.nodePost('ai/generate-image', {
            prompt,
            userId
        });
    },

    async getAiHistory(userId) {
        return this.nodeGet(`ai/history/${userId}`);
    },

    // ─── Chat ───
    async getChats(userId) {
        return this.get(`api/chat.php?action=conversations&user_id=${userId}`);
    },

    async getMessages(chatId) {
        return this.get(`api/chat.php?action=messages&chat_id=${chatId}`);
    },

    async sendMessage(data) {
        // action=send
        return this.post('api/chat.php', { action: 'send', ...data });
    },

    // ─── Heartbeat ───
    async sendHeartbeat(userId) {
        if (!userId) return;
        try {
            await fetch(APP_CONFIG.phpApi + 'api/heartbeat.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ user_id: userId }),
            });
        } catch (e) { /* silent */ }
    },

    // ─── Wishlist (Database Sync) ───
    async getWishlist(userId) {
        return this.nodeGet(`wishlist/${userId}`);
    },

    async addToWishlist(data) {
        return this.nodePost('wishlist', data);
    },

    async removeFromWishlist(userId, itemId) {
        try {
            const res = await fetch(`${APP_CONFIG.nodeApi}wishlist/${userId}/${itemId}`, {
                method: 'DELETE'
            });
            return await res.json();
        } catch (e) {
            return { status: 'error', message: e.message };
        }
    },

    // ─── Budget (Database Sync) ───
    async getBudget(userId) {
        return this.nodeGet(`budget/${userId}`);
    },

    async addToBudget(data) {
        return this.nodePost('budget', data);
    },

    async removeFromBudget(userId, itemId) {
        try {
            const res = await fetch(`${APP_CONFIG.nodeApi}budget/${userId}/${itemId}`, {
                method: 'DELETE'
            });
            return await res.json();
        } catch (e) {
            return { status: 'error', message: e.message };
        }
    },

    // ─── Migration ───
    async migrateStorageToDb(userId) {
        const migrationKey = `migrated_${userId}`;
        if (localStorage.getItem(migrationKey)) return;

        console.log("🚀 Starting data migration for user:", userId);

        // 1. Migrate Wishlist
        const localWishlist = JSON.parse(localStorage.getItem('vibeup_wishlist') || '[]');
        for (const item of localWishlist) {
            const isAi = typeof item === 'object' && item.type === 'ai-concept';
            await this.addToWishlist({
                userId,
                itemId: isAi ? item.id : item,
                itemData: isAi ? item : { id: item },
                isAi: isAi
            });
        }

        // 2. Migrate Budget
        const localBudget = JSON.parse(localStorage.getItem('vibeup_budget') || '[]');
        for (const item of localBudget) {
            await this.addToBudget({
                userId,
                itemId: item.id,
                itemName: item.name,
                category: item.category,
                price: item.price,
                quantity: item.quantity,
                imageUrl: item.image
            });
        }

        localStorage.setItem(migrationKey, 'true');
        console.log("✅ Migration complete!");
    },

    // ─── AI Assistant ───
    async askAI(message, userId, history = [], options = {}) {
        return this.nodePost('ai/chat', { message, userId, messages: history, ...options });
    },

    async getAiHistory(userId) {
        return this.nodeGet(`ai/history/${userId}`);
    }
};

// ─────────────────────────────────────────────────────────────
// AUTH MANAGER
// ─────────────────────────────────────────────────────────────
const Auth = {
    isLoggedIn() {
        return !!localStorage.getItem('vibeup_user_id');
    },

    getUser() {
        return {
            id: localStorage.getItem('vibeup_user_id') || '',
            name: localStorage.getItem('vibeup_user_name') || 'User',
            email: localStorage.getItem('vibeup_user_email') || '',
            role: localStorage.getItem('vibeup_user_role') || 'user',
            designerId: localStorage.getItem('vibeup_designer_id') || '',
        };
    },

    saveUser(data) {
        const id = data.id || data.user_id || data.uid || '';
        if (!id) {
            console.error('Auth.saveUser: Missing user ID in data', data);
        }
        localStorage.setItem('vibeup_user_id', id);
        localStorage.setItem('vibeup_user_name', data.name || data.user_name || 'User');
        localStorage.setItem('vibeup_user_email', data.email || '');
        localStorage.setItem('vibeup_user_role', data.role || 'user');
        if (data.designer_id) {
            localStorage.setItem('vibeup_designer_id', data.designer_id);
        }
    },

    logout() {
        localStorage.removeItem('vibeup_user_id');
        localStorage.removeItem('vibeup_user_name');
        localStorage.removeItem('vibeup_user_email');
        localStorage.removeItem('vibeup_user_role');
        localStorage.removeItem('vibeup_designer_id');
        window.location.href = getBasePath() + 'app/auth/login.html';
    },

    requireAuth() {
        if (!this.isLoggedIn()) {
            window.location.href = getBasePath() + 'app/auth/login.html';
            return false;
        }
        return true;
    },

    requireDesigner() {
        if (!this.isLoggedIn()) {
            window.location.href = getBasePath() + 'app/auth/login.html';
            return false;
        }
        if (this.getUser().role !== 'designer') {
            window.location.href = getBasePath() + 'app/dashboard/index.html';
            return false;
        }
        return true;
    },

    startHeartbeat() {
        const user = this.getUser();
        if (user.id) {
            Api.sendHeartbeat(user.id);
            setInterval(() => Api.sendHeartbeat(user.id), APP_CONFIG.heartbeatInterval);
        }
    },
};

// ─────────────────────────────────────────────────────────────
// UTILITIES
// ─────────────────────────────────────────────────────────────
function getBasePath() {
    // Detect base path dynamically
    const path = window.location.pathname;
    const appIndex = path.indexOf('/vibeup-web/');
    if (appIndex !== -1) return path.substring(0, appIndex) + '/vibeup-web/';
    return '/scratch/vibeup-web/';
}

function navigateTo(page) {
    window.location.href = getBasePath() + page;
}

function timeAgo(timestamp) {
    if (!timestamp) return '';
    const dt = new Date(timestamp);
    const diff = Date.now() - dt.getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}d ago`;
    return dt.toLocaleDateString();
}

function showToast(message, type = 'info') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    const icons = { success: '✓', error: '✕', info: 'ℹ', warning: '⚠' };
    toast.innerHTML = `<span>${icons[type] || 'ℹ'}</span><span>${message}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(30px)';
        toast.style.transition = 'all 0.3s';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

// ─────────────────────────────────────────────────────────────
// SIDEBAR RENDERER
// ─────────────────────────────────────────────────────────────
function renderSidebar(activeItem = 'home', role = 'user') {
    const user = Auth.getUser();
    const basePath = getBasePath();

    const userNav = [
        { id: 'home', label: 'Home', icon: '🏠', href: 'app/dashboard/index.html' },
        { id: 'new-project', label: 'New Project', icon: '➕', href: 'app/project/new-project.html' },
        { id: 'projects', label: 'My Projects', icon: '📁', href: 'app/project/projects.html' },
        { id: 'design-board', label: 'Design Board', icon: '📋', href: 'app/project/design-board.html' },
        { id: 'budget', label: 'Budget Estimation', icon: '💰', href: 'app/project/budget.html' },
        { id: 'designers', label: 'Find Designers', icon: '👤', href: 'app/project/designer-list.html' },
        { id: 'catalogue', label: 'Catalogue', icon: '🛍️', href: 'app/catalogue/index.html' },
        { id: 'ai-studio', label: 'AI Design Studio', icon: '🎨', href: 'app/project/ai-design-studio.html' },
        { id: 'ai', label: 'AI Assistant', icon: '✨', href: 'app/project/ai-assistant.html' },
        { id: 'chat', label: 'Messages', icon: '💬', href: 'app/chat/index.html' },
    ];

    const designerNav = [
        { id: 'home', label: 'Dashboard', icon: '🏠', href: 'app/designer/dashboard.html' },
        { id: 'requests', label: 'Manage Requests', icon: '📥', href: 'app/designer/requests.html' },
        { id: 'projects', label: 'My Projects', icon: '📁', href: 'app/designer/projects.html' },
        { id: 'design-board', label: 'Design Board', icon: '📋', href: 'app/project/design-board.html' },
        { id: 'budget', label: 'Budget Pro', icon: '💰', href: 'app/project/budget.html' },
        { id: 'ai-studio', label: 'AI Pro Studio', icon: '🎨', href: 'app/project/ai-design-studio.html' },
        { id: 'chat', label: 'Messages', icon: '💬', href: 'app/chat/index.html' },
        { id: 'ai', label: 'AI Assistant', icon: '✨', href: 'app/project/ai-assistant.html' },
    ];

    const navItems = role === 'designer' ? designerNav : userNav;
    const initials = (user.name || 'U').charAt(0).toUpperCase();

    const html = `
        <div class="sidebar" id="sidebar">
            <div class="sidebar-logo">
                <a href="${basePath}index.html"><span class="logo-accent">V</span>ibe<span class="logo-dim">Up</span></a>
            </div>
            <nav class="sidebar-nav">
                <div class="sidebar-section-title">${role === 'designer' ? 'Designer Studio' : 'Navigation'}</div>
                ${navItems.map(item => `
                    <a href="${basePath}${item.href}" class="nav-item ${activeItem === item.id ? 'active' : ''}">
                        <span class="nav-icon">${item.icon}</span>
                        ${item.label}
                    </a>
                `).join('')}
                
                <!-- Mode switching removed as per requirements -->
            </nav>
            <div class="sidebar-footer">
                <div class="sidebar-user" onclick="Auth.logout()">
                    <div class="sidebar-user-avatar">${initials}</div>
                    <div class="sidebar-user-info">
                        <div class="sidebar-user-name">${escapeHtml(user.name)}</div>
                        <div class="sidebar-user-role">${role === 'designer' ? 'Designer' : 'User'} · Logout</div>
                    </div>
                </div>
            </div>
        </div>
    `;

    // Insert at start of body
    document.body.insertAdjacentHTML('afterbegin', html);
}
