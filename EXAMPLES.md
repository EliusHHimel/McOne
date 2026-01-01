# Quick Start Examples

This file provides copy-paste examples for setting up your Minecraft server.

## For Linux Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
```

## For macOS Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
```

## For Windows Users (Command Prompt)

```cmd
REM Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

REM Run setup (one command!)
setup.bat
```

## For Windows Users (PowerShell)

```powershell
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
.\setup.ps1
```

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
