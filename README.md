# VibeUp v2.0 - AI & AR Interior Design Ecosystem

![VibeUp Architecture](https://img.shields.io/badge/Architecture-Full--Stack%20Ecosystem-indigo)
![Flutter](https://img.shields.io/badge/Mobile-Flutter%203.x-blue?logo=flutter)
![Node.js](https://img.shields.io/badge/Backend-Node.js%20%26%20Express-green?logo=node.js)
![PHP](https://img.shields.io/badge/Admin%20%26%20API-PHP%208.x-purple?logo=php)
![MySQL](https://img.shields.io/badge/Database-MySQL%20%2F%20MariaDB-orange?logo=mysql)
![AI Models](https://img.shields.io/badge/AI-Gemini%20%7C%20Groq%20%7C%20Stability%20%7C%20ElevenLabs-red)

**VibeUp v2.0** is an intelligent, full-stack interior design and spatial planning platform. It unites cross-platform Augmented Reality (AR), AI-driven generative design, Vastu Shastra architectural reasoning, interactive 3D web planning, and an administrative hub into an integrated ecosystem.

---

## 🏛 System Architecture

The repository is organized into modular services:

```
├── vibe_up_mobile/        # Flutter Mobile App (iOS / Android / Desktop)
│   ├── lib/               # AR furniture placement, AI chats, catalog, consultations
│   └── assets/            # 3D models, textures, webviews, and app configurations
│
├── vibeup-backend/        # Node.js AI Engine & Orchestrator
│   ├── ai/                # Multi-LLM routing (Gemini, Groq LLaMA, Stability AI, ElevenLabs)
│   ├── unity/             # C# spatial interaction managers for Unity/VR integration
│   └── server.js          # REST & WebSocket realtime server
│
├── vibeup-web/            # Interactive Web App & 3D Designer
│   ├── index.html         # Web planner canvas & UI controls
│   ├── script.js          # Room layout, catalog interactions, and rendering
│   └── style.css          # Modern dark-mode styling
│
├── admin_panel/           # PHP Administrative Dashboard & API Gateway
│   ├── api/ & api_v2/     # REST endpoints for users, designers, chats, and requests
│   ├── admin/             # Analytics, user management, designer reviews
│   └── setup.php          # Interactive database initialization script
│
└── vibeup-database/       # Relational Database Schemas
    ├── vibe_up_schema.sql # Complete production DDL schema
    └── vibe_up_schema_utf8.sql
```

---

## 🔒 Security & Environment Setup

This project follows strict security practices. **Never commit actual `.env` files, API keys, or production credentials to version control.**

### 1. Backend Configuration (`vibeup-backend`)
Copy the environment template:
```bash
cd vibeup-backend
cp .env.example .env
```
Fill in your configuration in `.env`:
* **Database**: `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
* **AI Providers**:
  * `GEMINI_API_KEY`: [Google AI Studio](https://aistudio.google.com/app/apikey)
  * `GROQ_API_KEY`: [Groq Console](https://console.groq.com/keys)
  * `ELEVENLABS_API_KEY`: [ElevenLabs](https://elevenlabs.io)
  * `STABILITY_API_KEY`: [Stability AI](https://platform.stability.ai)

### 2. Mobile App Configuration (`vibe_up_mobile`)
Copy the environment template:
```bash
cd vibe_up_mobile/assets
cp .env.example .env
```
Set your `GEMINI_API_KEY` for mobile generative design and chat assistance.

---

## 🚀 Getting Started

### Prerequisites
* **PHP 8.0+** & **MySQL 8.0+ / MariaDB** (e.g., via XAMPP)
* **Node.js 18+** & npm
* **Flutter SDK 3.0+**

### Step 1: Database Setup
1. Start Apache and MySQL via XAMPP.
2. Navigate to `http://localhost/scratch/admin_panel/setup.php` in your browser to automatically initialize the `vibe_up` database and default tables.
3. (Optional) Run `admin_panel/seed_dummy_data.sql` to populate sample designers, catalog items, and mock design requests.

### Step 2: Start the AI Backend
```bash
cd vibeup-backend
npm install
npm run dev
# Server runs on http://localhost:5000
```

### Step 3: Run the Mobile App
```bash
cd vibe_up_mobile
flutter pub get
flutter run
```

### Step 4: Web 3D Designer & Admin
* Access the Web Studio at: `http://localhost/scratch/vibeup-web/`
* Access the Admin Panel at: `http://localhost/scratch/admin_panel/`

---

## 🛡 License
Internal / Proprietary. All rights reserved.
