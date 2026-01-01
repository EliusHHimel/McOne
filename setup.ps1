# McOne - Minecraft Server Setup Script for Windows (PowerShell)
# Usage: .\setup.ps1

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_DIR = $PSScriptRoot
$SERVER_DIR = Join-Path $SCRIPT_DIR "server"
$MINECRAFT_VERSION = "1.20.4"
$DOWNLOAD_URL = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  McOne - Minecraft Server Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Java is installed
Write-Host "Checking for Java installation..."
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "[OK] Java is installed: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Java is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java 17 or higher from:" -ForegroundColor Yellow
    Write-Host "https://adoptium.net/" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Create server directory
Write-Host ""
Write-Host "Creating server directory..."
if (!(Test-Path -Path $SERVER_DIR)) {
    New-Item -ItemType Directory -Path $SERVER_DIR | Out-Null
}
Set-Location $SERVER_DIR
Write-Host "[OK] Server directory created: $SERVER_DIR" -ForegroundColor Green

# Download Minecraft server
Write-Host ""
Write-Host "Downloading Minecraft server (version $MINECRAFT_VERSION)..."
Write-Host "This may take a few minutes..."

$serverJarPath = Join-Path $SERVER_DIR "server.jar"
try {
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $serverJarPath -UseBasicParsing
    Write-Host "[OK] Server downloaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download server.jar" -ForegroundColor Red
    Write-Host "Please download manually from: https://www.minecraft.net/en-us/download/server" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Accept EULA
Write-Host ""
Write-Host "Creating eula.txt..."
$eulaContent = @"
# By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
eula=true
"@
Set-Content -Path (Join-Path $SERVER_DIR "eula.txt") -Value $eulaContent
Write-Host "[OK] EULA accepted" -ForegroundColor Green

# Create server properties
Write-Host ""
Write-Host "Creating server.properties with default settings..."
$propertiesContent = @"
#Minecraft server properties
server-port=25565
gamemode=survival
difficulty=normal
max-players=20
online-mode=true
white-list=false
motd=A Minecraft Server powered by McOne
level-name=world
pvp=true
spawn-protection=16
max-world-size=29999984
view-distance=10
"@
Set-Content -Path (Join-Path $SERVER_DIR "server.properties") -Value $propertiesContent
Write-Host "[OK] server.properties created" -ForegroundColor Green

# Create start scripts
Write-Host ""
Write-Host "Creating launch scripts..."

# Windows batch script
$batchContent = @"
@echo off
java -Xmx2G -Xms1G -jar server.jar nogui
pause
"@
Set-Content -Path (Join-Path $SERVER_DIR "start.bat") -Value $batchContent

# Unix shell script
$shellContent = @"
#!/bin/bash
java -Xmx2G -Xms1G -jar server.jar nogui
"@
Set-Content -Path (Join-Path $SERVER_DIR "start.sh") -Value $shellContent

Write-Host "[OK] Launch scripts created (start.bat and start.sh)" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] Setup completed successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start your Minecraft server:"
Write-Host "  cd $SERVER_DIR"
Write-Host "  start.bat"
Write-Host ""
Write-Host "Server will run on port 25565"
Write-Host "You can modify settings in server.properties"
Write-Host ""
Read-Host "Press Enter to exit"
