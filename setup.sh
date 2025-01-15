#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the absolute path of the bin/laws script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAWS_PATH="$SCRIPT_DIR/bin/laws"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SYMLINK_PATH="$INSTALL_DIR/laws"

# Function to check if we need sudo for the given directory
need_sudo() {
    [ ! -w "$1" ]
}

# Function to handle symlink creation/removal with or without sudo
handle_symlink() {
    local action=$1  # "create" or "remove"
    local cmd=""
    
    if [ "$action" = "create" ]; then
        cmd="ln -sf '$LAWS_PATH' '$SYMLINK_PATH'"
    else
        cmd="rm -f '$SYMLINK_PATH'"
    fi
    
    if need_sudo "$INSTALL_DIR"; then
        echo -e "${YELLOW}Requesting sudo access...${NC}"
        eval "sudo $cmd"
    else
        eval "$cmd"
    fi
}

echo -e "${YELLOW}Checking LAWS installation status...${NC}"

# Check if symlink already exists
if [ -L "$SYMLINK_PATH" ]; then
    # Uninstall
    echo -e "LAWS is currently installed at $SYMLINK_PATH"
    echo -e "${YELLOW}Removing LAWS symlink...${NC}"
    
    handle_symlink "remove"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}LAWS has been uninstalled successfully!${NC}"
    else
        echo -e "${RED}Failed to uninstall LAWS${NC}"
        exit 1
    fi
else
    # Install
    # First check if the laws script exists
    if [ ! -f "$LAWS_PATH" ]; then
        echo -e "${RED}Error: Could not find laws script at $LAWS_PATH${NC}"
        exit 1
    fi

    # Make sure the laws script is executable
    chmod +x "$LAWS_PATH"

    echo -e "Installing LAWS..."
    echo -e "Creating symlink in ${INSTALL_DIR}..."
    
    handle_symlink "create"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}LAWS has been installed successfully!${NC}"
        echo -e "\nYou can now use the 'laws' command from anywhere."
        echo -e "Try: ${YELLOW}laws --help${NC}"
        
        # Check if the directory is in PATH
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            echo -e "\n${YELLOW}Warning: $INSTALL_DIR is not in your PATH${NC}"
            echo "You may need to add it to your PATH to use the 'laws' command"
        fi
    else
        echo -e "${RED}Installation failed${NC}"
        exit 1
    fi
fi