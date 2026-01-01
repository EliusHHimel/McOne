@echo off
REM McOne - Minecraft Server Setup Script for Windows
REM Usage: setup.bat

echo =========================================
echo   McOne - Minecraft Server Setup
echo =========================================
echo.

set SCRIPT_DIR=%~dp0
set SERVER_DIR=%SCRIPT_DIR%server
set MINECRAFT_VERSION=1.20.4
REM Note: Update this URL when new versions are released
REM Get the latest server URL from: https://www.minecraft.net/en-us/download/server
set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar

REM Check if Java is installed
echo Checking for Java installation...
java -version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Java is installed
    java -version
) else (
    echo [ERROR] Java is not installed!
    echo.
    echo Please install Java 17 or higher from:
    echo https://adoptium.net/
    echo.
    pause
    exit /b 1
)

REM Create server directory
echo.
echo Creating server directory...
if not exist "%SERVER_DIR%" mkdir "%SERVER_DIR%"
cd /d "%SERVER_DIR%"
echo [OK] Server directory created: %SERVER_DIR%

REM Download Minecraft server
echo.
echo Downloading Minecraft server (version %MINECRAFT_VERSION%)...
echo This may take a few minutes...

REM Try using PowerShell to download
powershell -Command "& {Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile 'server.jar'}"

if exist "server.jar" (
    echo [OK] Server downloaded successfully!
) else (
    echo [ERROR] Failed to download server.jar
    echo Please download manually from: https://www.minecraft.net/en-us/download/server
    pause
    exit /b 1
)

REM Accept EULA
echo.
echo =========================================
echo Minecraft End User License Agreement
echo =========================================
echo.
echo To run a Minecraft server, you must agree to the Minecraft EULA.
echo Please review it at: https://aka.ms/MinecraftEULA
echo.
set /p EULA_ACCEPT="Do you agree to the Minecraft EULA? (yes/no): "
if /i not "%EULA_ACCEPT%"=="yes" if /i not "%EULA_ACCEPT%"=="y" (
    echo [ERROR] You must accept the EULA to run a Minecraft server.
    pause
    exit /b 1
)

echo.
echo Creating eula.txt...
(
    echo # By changing the setting below to TRUE you are indicating your agreement to our EULA ^(https://aka.ms/MinecraftEULA^).
    echo eula=true
) > eula.txt
echo [OK] EULA accepted

REM Create server properties
echo.
echo Creating server.properties with default settings...
(
    echo #Minecraft server properties
    echo server-port=25565
    echo gamemode=survival
    echo difficulty=normal
    echo max-players=20
    echo online-mode=true
    echo white-list=false
    echo motd=A Minecraft Server powered by McOne
    echo level-name=world
    echo pvp=true
    echo spawn-protection=16
    echo max-world-size=29999984
    echo view-distance=10
) > server.properties
echo [OK] server.properties created

REM Create start script
echo.
echo Creating launch scripts...
(
    echo @echo off
    echo java -Xmx2G -Xms1G -jar server.jar nogui
    echo pause
) > start.bat
echo [OK] Launch script created ^(start.bat^)

REM Create Unix launch script for WSL users
(
    echo #!/bin/bash
    echo java -Xmx2G -Xms1G -jar server.jar nogui
) > start.sh

echo.
echo =========================================
echo [SUCCESS] Setup completed successfully!
echo =========================================
echo.
echo To start your Minecraft server:
echo   cd %SERVER_DIR%
echo   start.bat
echo.
echo Server will run on port 25565
echo You can modify settings in server.properties
echo.
pause
