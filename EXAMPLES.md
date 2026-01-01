# Quick Start Examples

This file provides copy-paste examples for setting up your Minecraft server.

## For Linux Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
# The script will automatically fetch the latest 5 versions
# You can press Enter for the latest, select 1-5, or choose option 6 to enter a version manually
```

## For macOS Users

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
bash setup.sh
# The script will automatically fetch the latest 5 versions
# You can press Enter for the latest, select 1-5, or choose option 6 to enter a version manually
```

## For Windows Users (Command Prompt)

```cmd
REM Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

REM Run setup (one command!)
setup.bat
REM The script will try to fetch versions if Python is installed
REM Otherwise it will use a fallback list
```

## For Windows Users (PowerShell)

```powershell
# Clone the repository (if not already cloned)
git clone https://github.com/EliusHHimel/McOne.git
cd McOne

# Run setup (one command!)
.\setup.ps1
# The script will automatically fetch versions if Python is available
# You can select from the list or enter a version manually
```

## Version Selection Example

When you run the setup script (with Python 3 installed), you'll see something like:

```
Fetching available Minecraft versions...

Available Minecraft Versions (Latest 5):
=========================================
1) 1.21.11 (Latest)
2) 1.21.10
3) 1.21.9
4) 1.21.8
5) 1.21.7
6) Enter version manually
=========================================

Select version number (1-6) or press Enter for latest:
```

### Options:
- **Press Enter** → Automatically selects the latest version
- **Type 1-5** → Selects one of the displayed versions
- **Type 6** → Lets you enter any Minecraft version manually

### Manual Entry Example:

If you choose option 6, you'll see:

```
Enter Minecraft version (e.g., 1.19.4): 1.19.4
Searching for version 1.19.4...
[OK] Found version: 1.19.4
```

The script will:
1. Search Mojang's official version manifest
2. If not found, search jars.vexyhost.com
3. If not found, try common URL patterns
4. If still not found, report that the version doesn't exist

## Without Python

If Python 3 is not installed, you'll see:

```
Python 3 is not installed. Using fallback version list.

Available Minecraft Versions (Latest 5):
=========================================
1) 1.20.4 (Latest)
2) 1.20.3
3) 1.20.2
4) 1.20.1
5) 1.20
=========================================

Select version number (1-5) or press Enter for latest:
```

This fallback list is updated periodically and includes the most stable recent versions.

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
