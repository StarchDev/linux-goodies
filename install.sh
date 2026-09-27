#!/usr/bin/env sh

# Colors for output
CLR_RESET="\033[0m"
CLR_CYAN="\033[1;36m"
CLR_GREEN="\033[1;32m"
CLR_RED="\033[1;31m"
CLR_YELLOW="\033[1;33m"

printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
printf "${CLR_CYAN}       INSTALLING LINUX-GOODIES           ${CLR_RESET}\n"
printf "${CLR_CYAN}==========================================${CLR_RESET}\n"

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    printf "${CLR_RED}❌ Error: 'curl' is required to install linux-goodies.${CLR_RESET}\n"
    exit 1
fi

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

printf "${CLR_YELLOW}--> Downloading linux-goodies...${CLR_RESET}\n"

# Replace StarchDev with your actual GitHub username if different
RAW_URL="https://raw.githubusercontent.com/StarchDev/linux-goodies/main/linux-goodies.sh"

if curl -sSfL "$RAW_URL" -o "$INSTALL_DIR/linux-goodies"; then
    chmod +x "$INSTALL_DIR/linux-goodies"
    printf "${CLR_GREEN}✔ Successfully installed!${CLR_RESET}\n"
    
    # Check if ~/.local/bin is in PATH
    case ":$PATH:" in
        *:$INSTALL_DIR:*) ;;
        *)
            printf "${CLR_YELLOW}⚠️ Note: $INSTALL_DIR is not currently in your PATH.${CLR_RESET}\n"
            printf "${CLR_YELLOW}Add it to your shell config (.bashrc / .zshrc) with:${CLR_RESET}\n"
            printf "  export PATH=\"\$HOME/.local/bin:\$PATH\"\n"
            ;;
    esac

    printf "\n${CLR_GREEN}🎉 You can now run your suite anytime by typing:${CLR_RESET} ${CLR_CYAN}linux-goodies${CLR_RESET}\n"
else
    printf "${CLR_RED}❌ Download failed! Make sure the script file is named 'linux-goodies.sh' and pushed to GitHub.${CLR_RESET}\n"
    exit 1
fi
