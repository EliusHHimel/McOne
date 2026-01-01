# McOne - Minecraft Server Setup Script for Windows (PowerShell)
# Usage: .\setup.ps1

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_DIR = $PSScriptRoot
$SERVER_DIR = Join-Path $SCRIPT_DIR "server"
$VERSION_FETCHER = Join-Path $SCRIPT_DIR "fetch_versions.py"
$MINECRAFT_VERSION = ""
$DOWNLOAD_URL = ""

# Fallback version mappings
$FALLBACK_VERSIONS = @{
    "1.20.4" = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
    "1.20.3" = "https://piston-data.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar"
    "1.20.2" = "https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
    "1.20.1" = "https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar"
    "1.20"   = "https://piston-data.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar"
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  McOne - Minecraft Server Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python 3 is available
function Test-Python {
    try {
        $null = python --version 2>&1
        return $true
    } catch {
        try {
            $null = python3 --version 2>&1
            return $true
        } catch {
            return $false
        }
    }
}

# Get Python command
function Get-PythonCmd {
    try {
        $null = python3 --version 2>&1
        return "python3"
    } catch {
        return "python"
    }
}

# Select Minecraft version
function Select-MinecraftVersion {
    Write-Host ""
    
    $pythonAvailable = Test-Python
    $useFallback = $false
    
    if ($pythonAvailable -and (Test-Path $VERSION_FETCHER)) {
        Write-Host "Fetching available Minecraft versions..." -ForegroundColor Cyan
        
        $pythonCmd = Get-PythonCmd
        try {
            $versionsJson = & $pythonCmd $VERSION_FETCHER latest 5 2>$null | ConvertFrom-Json
            
            if ($versionsJson -and $versionsJson.versions) {
                $versions = $versionsJson.versions
                
                Write-Host ""
                Write-Host "Available Minecraft Versions (Latest 5):" -ForegroundColor Cyan
                Write-Host "=========================================" -ForegroundColor Cyan
                
                for ($i = 0; $i -lt $versions.Count; $i++) {
                    if ($i -eq 0) {
                        Write-Host "$($i+1)) $($versions[$i].id) (Latest)" -ForegroundColor Green
                    } else {
                        Write-Host "$($i+1)) $($versions[$i].id)"
                    }
                }
                Write-Host "6) Enter version manually" -ForegroundColor Yellow
                Write-Host "=========================================" -ForegroundColor Cyan
                Write-Host ""
                
                while ($true) {
                    $choice = Read-Host "Select version number (1-6) or press Enter for latest"
                    
                    if ([string]::IsNullOrWhiteSpace($choice)) {
                        $choice = "1"
                    }
                    
                    # Check for manual entry
                    if ($choice -eq "6") {
                        while ($true) {
                            $manualVersion = Read-Host "Enter Minecraft version (e.g., 1.19.4)"
                            
                            if (![string]::IsNullOrWhiteSpace($manualVersion)) {
                                Write-Host "Searching for version $manualVersion..." -ForegroundColor Cyan
                                
                                try {
                                    $versionInfo = & $pythonCmd $VERSION_FETCHER find $manualVersion 2>$null | ConvertFrom-Json
                                    
                                    if ($versionInfo -and !$versionInfo.error -and $versionInfo.url) {
                                        $script:MINECRAFT_VERSION = $manualVersion
                                        $script:DOWNLOAD_URL = $versionInfo.url
                                        Write-Host "[OK] Found version: $manualVersion" -ForegroundColor Green
                                        return
                                    } else {
                                        Write-Host "[ERROR] Version $manualVersion was not found." -ForegroundColor Red
                                        Write-Host "The version might be incorrect or unavailable." -ForegroundColor Yellow
                                        
                                        $retry = Read-Host "Try another version? (y/n)"
                                        if ($retry -notmatch '^[Yy]') {
                                            break
                                        }
                                    }
                                } catch {
                                    Write-Host "[ERROR] Failed to search for version." -ForegroundColor Red
                                    $retry = Read-Host "Try another version? (y/n)"
                                    if ($retry -notmatch '^[Yy]') {
                                        break
                                    }
                                }
                            }
                        }
                        continue
                    }
                    
                    # Validate numeric choice
                    try {
                        $choiceNum = [int]$choice
                        if ($choiceNum -ge 1 -and $choiceNum -le 5) {
                            $selectedVersion = $versions[$choiceNum - 1]
                            $script:MINECRAFT_VERSION = $selectedVersion.id
                            $script:DOWNLOAD_URL = $selectedVersion.url
                            Write-Host "[OK] Selected version: $($script:MINECRAFT_VERSION)" -ForegroundColor Green
                            return
                        } else {
                            Write-Host "[ERROR] Invalid selection. Please enter a number between 1 and 6" -ForegroundColor Red
                        }
                    } catch {
                        Write-Host "[ERROR] Invalid input. Please enter a number between 1 and 6" -ForegroundColor Red
                    }
                }
            } else {
                $useFallback = $true
            }
        } catch {
            Write-Host "Failed to fetch versions from official sources." -ForegroundColor Yellow
            $useFallback = $true
        }
    } else {
        if (!$pythonAvailable) {
            Write-Host "Python is not installed. Using fallback version list." -ForegroundColor Yellow
        }
        $useFallback = $true
    }
    
    # Fallback to hardcoded list
    if ($useFallback) {
        Write-Host ""
        Write-Host "Using fallback version list..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available Minecraft Versions (Latest 5):" -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Cyan
        
        $versions = $FALLBACK_VERSIONS.Keys | Sort-Object -Descending { [Version]($_ -replace '^(\d+\.\d+(\.\d+)?).*', '$1') }
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
        
        if ([string]::IsNullOrWhiteSpace($versionChoice)) {
            $versionChoice = 1
        }
        
        try {
            $choiceNum = [int]$versionChoice
            if ($choiceNum -ge 1 -and $choiceNum -le $versions.Count) {
                $script:MINECRAFT_VERSION = $versions[$choiceNum - 1]
                $script:DOWNLOAD_URL = $FALLBACK_VERSIONS[$script:MINECRAFT_VERSION]
                Write-Host "[OK] Selected version: $($script:MINECRAFT_VERSION)" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] Invalid selection. Defaulting to latest version." -ForegroundColor Yellow
                $script:MINECRAFT_VERSION = $versions[0]
                $script:DOWNLOAD_URL = $FALLBACK_VERSIONS[$script:MINECRAFT_VERSION]
            }
        } catch {
            Write-Host "[WARNING] Invalid input. Defaulting to latest version." -ForegroundColor Yellow
            $script:MINECRAFT_VERSION = $versions[0]
            $script:DOWNLOAD_URL = $FALLBACK_VERSIONS[$script:MINECRAFT_VERSION]
        }
    }
}

# Call version selection
Select-MinecraftVersion

Write-Host ""

# Determine required Java version based on Minecraft version
function Get-RequiredJavaVersion {
    param([string]$MinecraftVersion)
    
    if ($MinecraftVersion -match '^(\d+)\.(\d+)(\.(\d+))?') {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        $patch = if ($Matches[4]) { [int]$Matches[4] } else { 0 }
        
        if ($major -eq 1) {
            if ($minor -ge 21) {
                return 21
            } elseif ($minor -eq 20 -and $patch -ge 5) {
                return 21
            } elseif ($minor -ge 18) {
                return 17
            } elseif ($minor -eq 17) {
                return 17
            } elseif ($minor -ge 12) {
                return 11
            } else {
                return 8
            }
        } else {
            return 21
        }
    }
    
    return 21
}

# Get major Java version from version string
function Get-JavaMajorVersion {
    param([string]$VersionString)
    
    if ($VersionString -match '(?:version\s+)?"?(\d+)\.(\d+)') {
        $first = [int]$Matches[1]
        $second = [int]$Matches[2]
        
        if ($first -eq 1) {
            return $second
        } else {
            return $first
        }
    } elseif ($VersionString -match '"?(\d+)') {
        return [int]$Matches[1]
    }
    
    return 0
}

# Check if Java is installed and compatible
Write-Host "Checking for Java installation..."

$requiredJava = Get-RequiredJavaVersion -MinecraftVersion $MINECRAFT_VERSION
Write-Host "Minecraft $MINECRAFT_VERSION requires Java $requiredJava or higher" -ForegroundColor Cyan

try {
    $javaVersionOutput = java -version 2>&1 | Select-Object -First 3 | Out-String
    $javaVersionString = ($javaVersionOutput -split "`n")[0]
    $javaMajor = Get-JavaMajorVersion -VersionString $javaVersionString
    
    Write-Host "[OK] Java is installed: $javaVersionString" -ForegroundColor Green
    Write-Host "    Detected Java $javaMajor" -ForegroundColor Green
    
    if ($javaMajor -ge $requiredJava) {
        Write-Host "[OK] Java version is compatible" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Java $javaMajor is too old for Minecraft $MINECRAFT_VERSION" -ForegroundColor Red
        Write-Host "        Required: Java $requiredJava or higher" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please install Java $requiredJava or higher from:" -ForegroundColor Yellow
        Write-Host "https://adoptium.net/" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "[ERROR] Java is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java $requiredJava or higher from:" -ForegroundColor Yellow
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
