# McOne

**One command to set up a Minecraft server on any operating system!**

McOne is a simple, cross-platform Minecraft server setup utility that automates the entire process of setting up a Minecraft server. With just one command, you can have a fully functional Minecraft server ready to go.

## Features

- 🚀 **One-Command Setup**: Get your server running with a single command
- 🌍 **Cross-Platform**: Works on Linux, macOS, and Windows
- ☕ **Java Detection**: Automatically detects Java installation and provides guidance
- ⚙️ **Auto-Configuration**: Creates all necessary configuration files
- 📦 **Latest Version**: Downloads the latest stable Minecraft server
- 🎮 **Ready to Play**: Server is ready to start immediately after setup

## Quick Start

### Linux / macOS

Open your terminal and run:

```bash
bash setup.sh
```

### Windows

Choose one of the following methods:

**Method 1: Command Prompt**
```cmd
setup.bat
```

**Method 2: PowerShell**
```powershell
.\setup.ps1
```

**Note**: If you get an execution policy error in PowerShell, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Prerequisites

- **Java 17 or higher** is required to run Minecraft servers
- The setup script will guide you through installing Java if it's not already installed
- On Linux, you may need `sudo` privileges for automatic Java installation

## What Does It Do?

The setup script will:

1. ✅ Detect your operating system
2. ✅ Check for Java installation (offers to install if missing on Linux/macOS)
3. ✅ Create a `server` directory
4. ✅ Download the latest Minecraft server JAR file
5. ✅ Accept the Minecraft EULA
6. ✅ Create a default `server.properties` configuration
7. ✅ Generate launch scripts for your platform

## Starting Your Server

After setup completes, navigate to the server directory and run the start script:

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

## Server Configuration

The server is created with these default settings:

- **Port**: 25565 (default Minecraft port)
- **Game Mode**: Survival
- **Difficulty**: Normal
- **Max Players**: 20
- **RAM**: 2GB max, 1GB min (can be adjusted in start scripts)

You can modify these settings by editing the `server/server.properties` file.

## Memory Configuration

The default start scripts allocate 2GB of RAM to the server. To change this, edit the start script:

**Linux/macOS (start.sh)**:
```bash
java -Xmx4G -Xms2G -jar server.jar nogui
```

**Windows (start.bat)**:
```cmd
java -Xmx4G -Xms2G -jar server.jar nogui
```

Replace `4G` and `2G` with your desired maximum and minimum memory allocation.

## Connecting to Your Server

1. Start Minecraft (Java Edition)
2. Go to Multiplayer
3. Add Server
4. Enter your server address:
   - **Local**: `localhost` or `127.0.0.1`
   - **LAN**: Your local IP address (e.g., `192.168.1.100`)
   - **Public**: Your public IP address (port forwarding required)

## Port Forwarding (For Public Servers)

To allow players outside your network to connect:

1. Access your router's admin panel
2. Forward port `25565` (TCP/UDP) to your computer's local IP
3. Share your public IP address with players

## Troubleshooting

### Java Not Found
If Java is not installed:
- **Windows**: Download from [Adoptium](https://adoptium.net/)
- **macOS**: Install via Homebrew: `brew install openjdk@17`
- **Linux**: Use your package manager (apt, yum, dnf, pacman)

### Permission Denied (Linux/macOS)
Make the script executable:
```bash
chmod +x setup.sh
cd server
chmod +x start.sh
```

### Server Won't Start
- Ensure Java 17+ is installed: `java -version`
- Check that port 25565 is not already in use
- Verify you have enough RAM available

### Download Failed
If the automatic download fails:
1. Manually download `server.jar` from [Minecraft.net](https://www.minecraft.net/en-us/download/server)
2. Place it in the `server` directory
3. Run the setup script again (it will skip the download)

## Directory Structure

After setup, your directory will look like this:

```
McOne/
├── setup.sh          # Setup script for Linux/macOS
├── setup.bat         # Setup script for Windows (CMD)
├── setup.ps1         # Setup script for Windows (PowerShell)
├── README.md         # This file
└── server/           # Created by setup
    ├── server.jar    # Minecraft server
    ├── eula.txt      # EULA acceptance
    ├── server.properties  # Server configuration
    ├── start.sh      # Launch script (Linux/macOS)
    └── start.bat     # Launch script (Windows)
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This project is provided as-is for educational and personal use.

## Disclaimer

- By using this script, you agree to the [Minecraft End User License Agreement](https://aka.ms/MinecraftEULA)
- This is an unofficial tool and is not affiliated with Mojang or Microsoft
- Always keep your server software up to date for security

## Support

If you encounter issues or have questions:
1. Check the Troubleshooting section above
2. Review the [Minecraft Server Wiki](https://minecraft.fandom.com/wiki/Server)
3. Open an issue on this repository

---

**Happy Mining! ⛏️**