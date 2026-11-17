@echo off
title VibeUp v2.0 - Stop Local Servers
color 0C

echo ========================================================
echo        STOPPING VIBEUP LOCAL SERVICES
echo ========================================================
echo.

echo Stopping Node.js processes...
taskkill /F /IM node.exe /T 2>NUL

echo Stopping Apache HTTP Server...
taskkill /F /IM httpd.exe /T 2>NUL

echo Stopping MySQL Server...
"C:\xampp\mysql\bin\mysqladmin.exe" -u root shutdown 2>NUL || taskkill /F /IM mysqld.exe /T 2>NUL

echo.
echo [OK] All VibeUp local services have been stopped.
echo ========================================================
pause
