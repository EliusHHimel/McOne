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
set VERSION_FETCHER=%SCRIPT_DIR%fetch_versions.py

REM Check if Python is available
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=python
    goto :version_selection
)

python3 --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=python3
    goto :version_selection
)

REM Python not available, use fallback
echo [WARNING] Python not found. Using fallback version list.
goto :fallback_versions

:version_selection
REM Try to fetch versions using Python
echo Fetching available Minecraft versions...
%PYTHON_CMD% "%VERSION_FETCHER%" latest 5 >versions_temp.json 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Failed to fetch versions. Using fallback list.
    del versions_temp.json 2>nul
    goto :fallback_versions
)

REM Display versions from JSON (simplified - show latest 5)
echo.
echo Available Minecraft Versions (Latest 5):
echo =========================================
echo 1) Latest version (auto-detected)
echo 2) Second latest
echo 3) Third latest
echo 4) Fourth latest
echo 5) Fifth latest
echo 6) Enter version manually
echo =========================================
echo.

set /p VERSION_CHOICE="Select version number (1-6) or press Enter for latest: "

if "%VERSION_CHOICE%"=="" set VERSION_CHOICE=1

if "%VERSION_CHOICE%"=="6" goto :manual_entry

REM Get version from JSON based on choice
for /f "tokens=*" %%a in ('%PYTHON_CMD% -c "import json; data=json.load(open('versions_temp.json')); v=data['versions'][min(%VERSION_CHOICE%-1, len(data['versions'])-1)]; print(v['id'])"') do set MINECRAFT_VERSION=%%a
for /f "tokens=*" %%a in ('%PYTHON_CMD% -c "import json; data=json.load(open('versions_temp.json')); v=data['versions'][min(%VERSION_CHOICE%-1, len(data['versions'])-1)]; print(v['url'])"') do set DOWNLOAD_URL=%%a

del versions_temp.json 2>nul
echo [OK] Selected version: %MINECRAFT_VERSION%
echo.
goto :check_java

:manual_entry
del versions_temp.json 2>nul
:manual_entry_loop
set /p MANUAL_VERSION="Enter Minecraft version (e.g., 1.19.4): "

if "%MANUAL_VERSION%"=="" (
    echo [ERROR] Version cannot be empty
    goto :manual_entry_loop
)

echo Searching for version %MANUAL_VERSION%...
%PYTHON_CMD% "%VERSION_FETCHER%" find %MANUAL_VERSION% >version_info.json 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Version %MANUAL_VERSION% was not found.
    echo The version might be incorrect or unavailable.
    del version_info.json 2>nul
    set /p RETRY="Try another version? (y/n): "
    if /i "%RETRY%"=="y" goto :manual_entry_loop
    goto :fallback_versions
)

for /f "tokens=*" %%a in ('%PYTHON_CMD% -c "import json; data=json.load(open('version_info.json')); print(data.get('url', ''))"') do set DOWNLOAD_URL=%%a

if "%DOWNLOAD_URL%"=="" (
    echo [ERROR] Could not get download URL for version %MANUAL_VERSION%
    del version_info.json 2>nul
    set /p RETRY="Try another version? (y/n): "
    if /i "%RETRY%"=="y" goto :manual_entry_loop
    goto :fallback_versions
)

set MINECRAFT_VERSION=%MANUAL_VERSION%
del version_info.json 2>nul
echo [OK] Found version: %MINECRAFT_VERSION%
echo.
goto :check_java

:fallback_versions
REM Fallback version list
echo.
echo Available Minecraft Versions (Latest 5):
echo =========================================
echo 1) 1.20.4 (Latest)
echo 2) 1.20.3
echo 3) 1.20.2
echo 4) 1.20.1
echo 5) 1.20
echo =========================================
echo.

set /p VERSION_CHOICE="Select version number (1-5) or press Enter for latest: "

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
) else (
    echo [ERROR] Invalid selection. Defaulting to latest version.
    set MINECRAFT_VERSION=1.20.4
    set DOWNLOAD_URL=https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar
)

echo [OK] Selected version: %MINECRAFT_VERSION%
echo.

:check_java
REM Check if Java is installed and compatible
echo Checking for Java installation...

REM Determine required Java version for Minecraft version
set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION:~0,4%"=="1.21" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,6%"=="1.20.5" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,6%"=="1.20.6" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,6%"=="1.20.7" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,6%"=="1.20.8" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,6%"=="1.20.9" set REQUIRED_JAVA=21
if "%MINECRAFT_VERSION:~0,4%"=="1.18" set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION:~0,4%"=="1.19" set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION:~0,5%"=="1.20." set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION%"=="1.20" set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION:~0,4%"=="1.17" set REQUIRED_JAVA=17
if "%MINECRAFT_VERSION:~0,4%"=="1.12" set REQUIRED_JAVA=11
if "%MINECRAFT_VERSION:~0,4%"=="1.13" set REQUIRED_JAVA=11
if "%MINECRAFT_VERSION:~0,4%"=="1.14" set REQUIRED_JAVA=11
if "%MINECRAFT_VERSION:~0,4%"=="1.15" set REQUIRED_JAVA=11
if "%MINECRAFT_VERSION:~0,4%"=="1.16" set REQUIRED_JAVA=11

echo Minecraft %MINECRAFT_VERSION% requires Java %REQUIRED_JAVA% or higher

java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java is not installed!
    echo.
    echo Please install Java %REQUIRED_JAVA% or higher from:
    echo https://adoptium.net/
    echo.
    pause
    exit /b 1
)

REM Get Java version using PowerShell
for /f "tokens=*" %%i in ('powershell -Command "& {try { $v = (java -version 2>&1 | Select-Object -First 1); if ($v -match '\"(\d+)\.(\d+)') { if ([int]$Matches[1] -eq 1) { [int]$Matches[2] } else { [int]$Matches[1] } } elseif ($v -match '\"(\d+)') { [int]$Matches[1] } else { 0 } } catch { 0 }}"') do set JAVA_MAJOR=%%i

echo [OK] Java is installed (Java %JAVA_MAJOR%)
java -version

if %JAVA_MAJOR% GEQ %REQUIRED_JAVA% (
    echo [OK] Java version is compatible
) else (
    echo [ERROR] Java %JAVA_MAJOR% is too old for Minecraft %MINECRAFT_VERSION%
    echo         Required: Java %REQUIRED_JAVA% or higher
    echo.
    echo Please install Java %REQUIRED_JAVA% or higher from:
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
