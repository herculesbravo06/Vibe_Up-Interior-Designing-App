@echo off
title VibeUp v2.0 - Local Server Launcher
color 0A

echo ========================================================
echo        VIBEUP v2.0 - LOCAL ENVIRONMENT LAUNCHER
echo ========================================================
echo.

:: 1. Start MySQL
echo [1/3] Checking MySQL...
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] MySQL is already running.
) else (
    echo Starting MySQL...
    start "" /B "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini" --standalone
    timeout /t 3 /nobreak >nul
    echo [OK] MySQL started on port 3306.
)

:: 2. Start Apache
echo [2/3] Checking Apache...
tasklist /FI "IMAGENAME eq httpd.exe" 2>NUL | find /I /N "httpd.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] Apache is already running.
) else (
    echo Starting Apache HTTP Server...
    start "" /B "C:\xampp\apache\bin\httpd.exe"
    timeout /t 2 /nobreak >nul
    echo [OK] Apache started on port 80.
)

:: 3. Start Node.js Backend
echo [3/3] Starting Node.js AI Backend...
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] Node.js is already running.
) else (
    cd /d "%~dp0vibeup-backend"
    start "VibeUp Backend Server (Port 5000)" cmd /k "node server.js"
    echo [OK] Node.js backend launched on http://localhost:5000
)

echo.
echo ========================================================
echo                VIBEUP LOCAL SERVICES LIVE
echo ========================================================
echo  * Web App & 3D Designer:  http://localhost/scratch/vibeup-web/
echo  * Admin Dashboard:        http://localhost/scratch/admin_panel/
echo  * Node.js AI Backend:     http://localhost:5000/
echo  * MySQL Database:         localhost:3306 (DB: vibe_up)
echo ========================================================
echo.
pause
