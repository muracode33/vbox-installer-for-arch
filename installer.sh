#!/bin/bash

# --- Colors ---
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Banner ---
clear
echo -e "${CYAN}"
echo " __     ___      _               _ ____                "
echo " \ \   / (_)_ __| |_ _   _  __ _| | __ )  _____  __    "
echo "  \ \ / /| | '__| __| | | |/ _\` | |  _ \ / _ \ \/ /    "
echo "   \ V / | | |  | |_| |_| | (_| | | |_) | (_) >  <     "
echo "    \_/  |_|_|   \__|\__,_|\__,_|_|____/ \___/_/\_\    "
echo "                                                       "
echo "                INSTALLER SCRIPT                       "
echo -e "${NC}          ${BLUE}created by muracode33${NC}\n"

# --- Status Check Function ---
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $1"
    else
        echo -e "${RED}[ERROR]${NC} $1 failed. Please check the logs."
        exit 1
    fi
}

# 1. Update System
echo -e "${BLUE}>> Updating package database...${NC}"
sudo pacman -Syu --noconfirm
check_status "System update"

# 2. Kernel & Headers Detection
echo -e "\n${BLUE}>> Detecting kernel to install correct headers...${NC}"
KERNEL_TYPE=$(uname -r)
if [[ $KERNEL_TYPE == *"lts"* ]]; then
    PKG="linux-lts-headers"
elif [[ $KERNEL_TYPE == *"zen"* ]]; then
    PKG="linux-zen-headers"
elif [[ $KERNEL_TYPE == *"hardened"* ]]; then
    PKG="linux-hardened-headers"
else
    PKG="linux-headers"
fi
echo -e "${CYAN}Targeting: $PKG${NC}"
sudo pacman -S --needed --noconfirm $PKG
check_status "$PKG installation"

# 3. Core Installation
echo -e "\n${BLUE}>> Installing VirtualBox and dependencies...${NC}"
sudo pacman -S --needed --noconfirm virtualbox virtualbox-host-dkms qt6-wayland base-devel
check_status "Core packages installation"

# 4. Modules & Persistence
echo -e "\n${BLUE}>> Configuring kernel modules...${NC}"
sudo modprobe vboxdrv
# Create persistence file for modules
echo -e "vboxdrv\nvboxnetadp\nvboxnetflt" | sudo tee /etc/modules-load.d/virtualbox.conf > /dev/null
check_status "Kernel modules configuration"

# 5. User Group Management
echo -e "\n${BLUE}>> Configuring user permissions for ($USER)...${NC}"
sudo usermod -aG vboxusers $USER
check_status "User added to vboxusers group"

# 6. AUR Extension Pack
echo -e "\n${BLUE}>> Searching for AUR helper for Extension Pack...${NC}"
if command -v yay &> /dev/null; then
    yay -S --noconfirm virtualbox-ext-oracle
elif command -v paru &> /dev/null; then
    paru -S --noconfirm virtualbox-ext-oracle
else
    echo -e "${RED}[!] AUR helper (yay/paru) not found.${NC}"
    echo "Please install 'virtualbox-ext-oracle' manually for USB 3.0 support."
fi

echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}      INSTALLATION COMPLETED SUCCESSFULLY!     ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo -e "Please ${RED}REBOOT${NC} your system to apply all changes."
