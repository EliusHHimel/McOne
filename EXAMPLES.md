# Quick Start Examples

This file provides copy-paste examples for setting up your Minecraft server.

## For Linux Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
# You'll be prompted to select a Minecraft version
# Press Enter to use the latest version or enter a number (1-12)
```

## For macOS Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
# You'll be prompted to select a Minecraft version
# Press Enter to use the latest version or enter a number (1-12)
```

## For Windows Users (Command Prompt)

```cmd
REM Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

REM Run setup (one command!)
setup.bat
REM You'll be prompted to select a Minecraft version
REM Press Enter to use the latest version or enter a number (1-12)
```

## For Windows Users (PowerShell)

```powershell
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
.\setup.ps1
# You'll be prompted to select a Minecraft version
# Press Enter to use the latest version or enter a number (1-12)
```

## Version Selection Example

When you run the setup script, you'll see:

```
Available Minecraft Versions:
=========================================
1) 1.20.4 (Latest)
2) 1.20.3
3) 1.20.2
4) 1.20.1
5) 1.20
6) 1.19.4
7) 1.19.3
8) 1.19.2
9) 1.19.1
10) 1.19
11) 1.18.2
12) 1.18.1
=========================================

Select version number (1-12) or press Enter for latest:
```

Simply press Enter for the latest version, or type a number (1-12) to choose a specific version.

## Starting the Server After Setup

### Linux / macOS
```bash
cd server
./start.sh
```

### Windows
```cmd
cd server
start.bat
```

## Customizing Memory Allocation

Edit the start script to change RAM allocation:

### Linux / macOS (edit server/start.sh)
```bash
# Change from default 2GB to 4GB
java -Xmx4G -Xms2G -jar server.jar nogui
```

### Windows (edit server/start.bat)
```cmd
@echo off
java -Xmx4G -Xms2G -jar server.jar nogui
pause
```

## That's It!

Your Minecraft server is now ready. Connect using `localhost` on the same machine,
or your IP address for remote connections (remember to configure port forwarding if needed).
