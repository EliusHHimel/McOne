@echo off
REM McOne - Minecraft Server Setup Script for Windows
REM Usage: setup.bat

echo =========================================
echo   McOne - Minecraft Server Setup
echo =========================================
echo.

set SCRIPT_DIR=%~dp0
set SERVER_DIR=%SCRIPT_DIR%server
set MINECRAFT_VERSION=
set DOWNLOAD_URL=

REM Available Minecraft versions
echo.
echo Available Minecraft Versions:
echo =========================================
echo 1) 1.20.4 (Latest)
echo 2) 1.20.3
echo 3) 1.20.2
echo 4) 1.20.1
echo 5) 1.20
echo 6) 1.19.4
echo 7) 1.19.3
echo 8) 1.19.2
echo 9) 1.19.1
echo 10) 1.19
echo 11) 1.18.2
echo 12) 1.18.1
echo =========================================
echo.

set /p VERSION_CHOICE="Select version number (1-12) or press Enter for latest: "

REM Default to 1 if empty
if "%VERSION_CHOICE%"=="" set VERSION_CHOICE=1

REM Set version and URL based on choice
if "%VERSION_CHOICE%"=="1" (
    set MINECRAFT_VERSION=1.20.4
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar
) else if "%VERSION_CHOICE%"=="2" (
    set MINECRAFT_VERSION=1.20.3
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar
) else if "%VERSION_CHOICE%"=="3" (
    set MINECRAFT_VERSION=1.20.2
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar
) else if "%VERSION_CHOICE%"=="4" (
    set MINECRAFT_VERSION=1.20.1
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar
) else if "%VERSION_CHOICE%"=="5" (
    set MINECRAFT_VERSION=1.20
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar
) else if "%VERSION_CHOICE%"=="6" (
    set MINECRAFT_VERSION=1.19.4
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar
) else if "%VERSION_CHOICE%"=="7" (
    set MINECRAFT_VERSION=1.19.3
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar
) else if "%VERSION_CHOICE%"=="8" (
    set MINECRAFT_VERSION=1.19.2
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
) else if "%VERSION_CHOICE%"=="9" (
    set MINECRAFT_VERSION=1.19.1
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8399e1211e95faa421c1507b322dbeae86d604df/server.jar
) else if "%VERSION_CHOICE%"=="10" (
    set MINECRAFT_VERSION=1.19
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar
) else if "%VERSION_CHOICE%"=="11" (
    set MINECRAFT_VERSION=1.18.2
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar
) else if "%VERSION_CHOICE%"=="12" (
    set MINECRAFT_VERSION=1.18.1
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar
) else (
    echo [ERROR] Invalid selection. Defaulting to latest version.
    set MINECRAFT_VERSION=1.20.4
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar
)

echo [OK] Selected version: %MINECRAFT_VERSION%
echo.

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
