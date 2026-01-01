#!/bin/bash

# McOne - Minecraft Server Setup Script
# Cross-platform Minecraft server setup utility
# Usage: bash setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
MINECRAFT_VERSION="1.20.4"
# Note: Update this URL when new versions are released
# Get the latest server URL from: https://www.minecraft.net/en-us/download/server
DOWNLOAD_URL="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  McOne - Minecraft Server Setup"
echo "========================================="
echo ""

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    echo -e "${GREEN}Detected OS: $OS${NC}"
}

# Check if Java is installed
check_java() {
    echo ""
    echo "Checking for Java installation..."
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        echo -e "${GREEN}Java is installed: $JAVA_VERSION${NC}"
        return 0
    else
        echo -e "${YELLOW}Java is not installed!${NC}"
        return 1
    fi
}

# Install Java based on OS
install_java() {
    echo ""
    echo "Attempting to install Java..."
    
    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo "Using apt-get to install Java..."
            sudo apt-get update
            sudo apt-get install -y openjdk-17-jre-headless
        elif command -v yum &> /dev/null; then
            echo "Using yum to install Java..."
            sudo yum install -y java-17-openjdk-headless
        elif command -v dnf &> /dev/null; then
            echo "Using dnf to install Java..."
            sudo dnf install -y java-17-openjdk-headless
        elif command -v pacman &> /dev/null; then
            echo "Using pacman to install Java..."
            sudo pacman -S --noconfirm jre17-openjdk-headless
        else
            echo -e "${RED}Could not detect package manager. Please install Java 17 or higher manually.${NC}"
            echo "Visit: https://adoptium.net/"
            exit 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            echo "Using Homebrew to install Java..."
            brew install openjdk@17
        else
            echo -e "${YELLOW}Homebrew not found. Please install Java manually from:${NC}"
            echo "https://adoptium.net/"
            exit 1
        fi
    else
        echo -e "${RED}Automatic Java installation not supported on this OS.${NC}"
        echo "Please install Java 17 or higher manually from: https://adoptium.net/"
        exit 1
    fi
}

# Create server directory
create_server_directory() {
    echo ""
    echo "Creating server directory..."
    mkdir -p "$SERVER_DIR"
    cd "$SERVER_DIR"
    echo -e "${GREEN}Server directory created: $SERVER_DIR${NC}"
}

# Download Minecraft server
download_server() {
    echo ""
    echo "Downloading Minecraft server (version $MINECRAFT_VERSION)..."
    
    if command -v curl &> /dev/null; then
        curl -L -o server.jar "$DOWNLOAD_URL"
    elif command -v wget &> /dev/null; then
        wget -O server.jar "$DOWNLOAD_URL"
    else
        echo -e "${RED}Neither curl nor wget found. Please install one of them.${NC}"
        exit 1
    fi
    
    if [ -f "server.jar" ]; then
        echo -e "${GREEN}Server downloaded successfully!${NC}"
    else
        echo -e "${RED}Failed to download server.jar${NC}"
        exit 1
    fi
}

# Accept EULA
accept_eula() {
    echo ""
    echo "========================================="
    echo "Minecraft End User License Agreement"
    echo "========================================="
    echo ""
    echo "To run a Minecraft server, you must agree to the Minecraft EULA."
    echo "Please review it at: https://aka.ms/MinecraftEULA"
    echo ""
    read -p "Do you agree to the Minecraft EULA? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]] && [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}You must accept the EULA to run a Minecraft server.${NC}"
        exit 1
    fi
    
    echo "Creating eula.txt..."
    echo "# By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA)." > eula.txt
    echo "eula=true" >> eula.txt
    echo -e "${GREEN}EULA accepted${NC}"
}

# Create server properties
create_server_properties() {
    echo ""
    echo "Creating server.properties with default settings..."
    cat > server.properties << 'EOF'
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
EOF
    echo -e "${GREEN}server.properties created${NC}"
}

# Create start script
create_start_script() {
    echo ""
    echo "Creating launch scripts..."
    
    # Unix/Linux/Mac start script
    cat > start.sh << 'EOF'
#!/bin/bash
java -Xmx2G -Xms1G -jar server.jar nogui
EOF
    chmod +x start.sh
    
    # Windows start script
    cat > start.bat << 'EOF'
@echo off
java -Xmx2G -Xms1G -jar server.jar nogui
pause
EOF
    
    echo -e "${GREEN}Launch scripts created (start.sh and start.bat)${NC}"
}

# Main setup function
main() {
    detect_os
    
    if ! check_java; then
        read -p "Do you want to install Java automatically? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_java
            if ! check_java; then
                echo -e "${RED}Java installation failed. Please install manually.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Please install Java 17 or higher and run this script again.${NC}"
            exit 1
        fi
    fi
    
    create_server_directory
    download_server
    accept_eula
    create_server_properties
    create_start_script
    
    echo ""
    echo "========================================="
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo "========================================="
    echo ""
    echo "To start your Minecraft server:"
    echo "  cd $SERVER_DIR"
    if [[ "$OS" == "windows" ]]; then
        echo "  start.bat"
    else
        echo "  ./start.sh"
    fi
    echo ""
    echo "Server will run on port 25565"
    echo "You can modify settings in server.properties"
    echo ""
}

main
