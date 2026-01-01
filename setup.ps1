# McOne - Minecraft Server Setup Script for Windows (PowerShell)
# Usage: .\setup.ps1

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_DIR = $PSScriptRoot
$SERVER_DIR = Join-Path $SCRIPT_DIR "server"
$MINECRAFT_VERSION = ""
$DOWNLOAD_URL = ""

# Version mappings
$VERSION_URLS = @{
    "1.20.4" = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
    "1.20.3" = "https://piston-data.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar"
    "1.20.2" = "https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
    "1.20.1" = "https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar"
    "1.20"   = "https://piston-data.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar"
    "1.19.4" = "https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar"
    "1.19.3" = "https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar"
    "1.19.2" = "https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
    "1.19.1" = "https://piston-data.mojang.com/v1/objects/8399e1211e95faa421c1507b322dbeae86d604df/server.jar"
    "1.19"   = "https://piston-data.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar"
    "1.18.2" = "https://piston-data.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar"
    "1.18.1" = "https://piston-data.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar"
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  McOne - Minecraft Server Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Select Minecraft version
Write-Host ""
Write-Host "Available Minecraft Versions:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$versions = $VERSION_URLS.Keys | Sort-Object -Descending { [Version]($_ -replace '^(\d+\.\d+(\.\d+)?).*', '$1') }
$i = 1
foreach ($version in $versions) {
    if ($i -eq 1) {
        Write-Host "$i) $version (Latest)" -ForegroundColor Green
    } else {
        Write-Host "$i) $version"
    }
    $i++
}
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$versionChoice = Read-Host "Select version number (1-$($versions.Count)) or press Enter for latest"

# Default to 1 if empty
if ([string]::IsNullOrWhiteSpace($versionChoice)) {
    $versionChoice = 1
}

# Validate and set version
try {
    $choiceNum = [int]$versionChoice
    if ($choiceNum -ge 1 -and $choiceNum -le $versions.Count) {
        $MINECRAFT_VERSION = $versions[$choiceNum - 1]
        $DOWNLOAD_URL = $VERSION_URLS[$MINECRAFT_VERSION]
        Write-Host "[OK] Selected version: $MINECRAFT_VERSION" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Invalid selection. Defaulting to latest version." -ForegroundColor Yellow
        $MINECRAFT_VERSION = $versions[0]
        $DOWNLOAD_URL = $VERSION_URLS[$MINECRAFT_VERSION]
    }
} catch {
    Write-Host "[WARNING] Invalid input. Defaulting to latest version." -ForegroundColor Yellow
    $MINECRAFT_VERSION = $versions[0]
    $DOWNLOAD_URL = $VERSION_URLS[$MINECRAFT_VERSION]
}

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
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Minecraft End User License Agreement" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run a Minecraft server, you must agree to the Minecraft EULA."
Write-Host "Please review it at: https://aka.ms/MinecraftEULA" -ForegroundColor Yellow
Write-Host ""
$eulaAccept = Read-Host "Do you agree to the Minecraft EULA? (yes/no)"
if ($eulaAccept -notmatch '^(yes|y)$') {
    Write-Host "[ERROR] You must accept the EULA to run a Minecraft server." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

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
