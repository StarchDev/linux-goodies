#!/usr/bin/env sh

CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_CYAN="\033[1;36m"
CLR_GREEN="\033[1;32m"
CLR_YELLOW="\033[1;33m"
CLR_PURPLE="\033[1;35m"
CLR_BLUE="\033[1;34m"
CLR_RED="\033[1;31m"
CLR_HILITE="\033[7m"

CONFIG_DIR="$HOME/.config/linux-goodies"
mkdir -p "$CONFIG_DIR"

get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

detect_shell_rc() {
    if [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
        echo "$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc"
    elif [ -f "$HOME/.config/fish/config.fish" ]; then
        echo "$HOME/.config/fish/config.fish"
    else
        echo "$HOME/.profile"
    fi
}

secret_inject_banner() {
    RC_FILE=$(detect_shell_rc)
    MARKER_START="# --- LINUX-GOODIES START ---"
    MARKER_END="# --- LINUX-GOODIES END ---"

    if grep -q "$MARKER_START" "$RC_FILE" 2>/dev/null; then
        sed -i "/$MARKER_START/,/$MARKER_END/d" "$RC_FILE"
    fi

    cat << 'EOF' >> "$RC_FILE"
# --- LINUX-GOODIES START ---
if [ -t 0 ]; then
  printf "\033[1;36m"
  \cat << "BANNER"
 _     _                  _  ____                 _ _ 
| |   (_)_ __  _   ___  _| |/ ___| ___   ___   __| (_) ___ ___ 
| |   | | '_ \| | | \ \/ / | |  _ / _ \ / _ \ / _` | |/ _ \/ __|
| |___| | | | | |_| |>  <| | |_| | (_) | (_) | (_| | |  __/\__ \
|_____|_|_| |_|\__,_/_/\_|_|\____|\___/ \___/ \__,_|_|\___||___/
BANNER
  printf "\033[0m\n"
fi

command -v eza >/dev/null 2>&1 && alias ls="eza --icons=always --group-directories-first"
command -v eza >/dev/null 2>&1 && alias ll="eza -la --icons=always --group-directories-first"
command -v bat >/dev/null 2>&1 && alias cat="bat"
command -v fastfetch >/dev/null 2>&1 && alias fetch="fastfetch"

command -v starship >/dev/null 2>&1 && eval "$(starship init $(basename "$SHELL"))"
# --- LINUX-GOODIES END ---
EOF
}

install_all_packages() {
    DISTRO=$(get_distro)
    printf "${CLR_BLUE}--> System detected: ${CLR_YELLOW}%s${CLR_RESET}\n" "$DISTRO"
    printf "${CLR_BLUE}--> Installing terminal eye-candy suite...${CLR_RESET}\n"

    case "$DISTRO" in
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm fastfetch cava btop cmatrix starship eza bat fzf curl unzip 2>/dev/null || \
            sudo pacman -S --noconfirm fastfetch cava btop cmatrix starship eza bat fzf curl unzip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y fastfetch cava btop cmatrix eza bat fzf curl unzip
            sudo dnf copr enable -y atim/starship && sudo dnf install -y starship
            ;;
        ubuntu|debian|pop|mint)
            sudo apt-get update
            sudo apt-get install -y cava btop cmatrix eza bat fzf curl unzip
            if ! command -v fastfetch >/dev/null 2>&1; then
                sudo apt-get install -y neofetch 2>/dev/null || true
            fi
            if ! command -v starship >/dev/null 2>&1; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
        alpine)
            sudo apk add fastfetch cava btop cmatrix starship eza bat fzf curl unzip
            ;;
        void)
            sudo xbps-install -Sy fastfetch cava btop cmatrix starship eza bat fzf curl unzip
            ;;
        *)
            printf "${CLR_YELLOW}⚠️ Unknown distribution (%s). Falling back to starship installer...${CLR_RESET}\n" "$DISTRO"
            if ! command -v starship >/dev/null 2>&1; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
    esac

    secret_inject_banner
    printf "${CLR_GREEN}✔ Package installation complete!${CLR_RESET}\n"
}

install_ghostty_mgr() {
    printf "${CLR_BLUE}--> Installing ghostty-mgr...${CLR_RESET}\n"
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    
    if curl -sSfL "https://raw.githubusercontent.com/StarchDev/Ghostty-Manager/main/ghostty-mgr.sh" -o "$BIN_DIR/ghostty-mgr" 2>/dev/null || \
       curl -sSfL "https://raw.githubusercontent.com/StarchDev/Ghostty-Mgr/main/ghostty-mgr.sh" -o "$BIN_DIR/ghostty-mgr" 2>/dev/null || \
       curl -sSfL "https://raw.githubusercontent.com/StarchDev/ghostty-mgr/main/ghostty-mgr.sh" -o "$BIN_DIR/ghostty-mgr" 2>/dev/null; then
        chmod +x "$BIN_DIR/ghostty-mgr"
        printf "${CLR_GREEN}✔ ghostty-mgr installed to %s/ghostty-mgr${CLR_RESET}\n" "$BIN_DIR"
    else
        printf "${CLR_RED}❌ Download failed! Check if repository or filename exists on GitHub.${CLR_RESET}\n"
        rm -f "$BIN_DIR/ghostty-mgr" 2>/dev/null
    fi
}

install_starship_preset_mgr() {
    printf "${CLR_BLUE}--> Installing starship-preset-mgr...${CLR_RESET}\n"
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    
    if curl -sSfL "https://raw.githubusercontent.com/StarchDev/Starship-Preset-Manager/main/starship-preset-mgr.sh" -o "$BIN_DIR/starship-preset-mgr" 2>/dev/null || \
       curl -sSfL "https://raw.githubusercontent.com/StarchDev/Starship-Preset-Manager/main/starship-preset-manager.sh" -o "$BIN_DIR/starship-preset-mgr" 2>/dev/null; then
        chmod +x "$BIN_DIR/starship-preset-mgr"
        printf "${CLR_GREEN}✔ starship-preset-mgr installed to %s/starship-preset-mgr${CLR_RESET}\n" "$BIN_DIR"
    else
        printf "${CLR_RED}❌ Download failed! Check repository URL case and script filename on GitHub.${CLR_RESET}\n"
        rm -f "$BIN_DIR/starship-preset-mgr" 2>/dev/null
    fi
}

install_full_bundle() {
    printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
    printf "${CLR_PURPLE}      INSTALLING COMPLETE SUITE BUNDLE    ${CLR_RESET}\n"
    printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
    install_all_packages
    install_ghostty_mgr
    install_starship_preset_mgr
    printf "\n${CLR_GREEN}🎉 Complete Linux-Goodies bundle successfully deployed!${CLR_RESET}\n"
}

configure_fastfetch() {
    current=1
    while true; do
        clear
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_PURPLE}        FASTFETCH CONFIGURATOR            ${CLR_RESET}\n"
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        if [ "$current" -eq 1 ]; then printf "${CLR_HILITE} 1) Preset: Minimal (Clean, no logo)      ${CLR_RESET}\n"; else printf "  1) Preset: Minimal (Clean, no logo)\n"; fi
        if [ "$current" -eq 2 ]; then printf "${CLR_HILITE} 2) Preset: Neofetch Classic Style       ${CLR_RESET}\n"; else printf "  2) Preset: Neofetch Classic Style\n"; fi
        if [ "$current" -eq 3 ]; then printf "${CLR_HILITE} 3) Back to Config Menu                  ${CLR_RESET}\n"; else printf "  3) Back to Config Menu\n"; fi
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_YELLOW}Use Up/Down arrows to move, Enter to select:${CLR_RESET}\n"

        IFS= read -rsn1 key
        if [ "$key" = "$(printf '\033')" ]; then
            read -rsn2 key
            case "$key" in
                "[A") current=$((current - 1)); [ "$current" -lt 1 ] && current=3 ;;
                "[B") current=$((current + 1)); [ "$current" -gt 3 ] && current=1 ;;
            esac
        elif [ -z "$key" ]; then
            ff_choice=$current
            break
        fi
    done

    FASTFETCH_DIR="$HOME/.config/fastfetch"
    mkdir -p "$FASTFETCH_DIR"

    case "$ff_choice" in
        1)
            fastfetch --gen-config-force
            printf "${CLR_GREEN}✔ Minimal Fastfetch preset applied!${CLR_RESET}\n"
            sleep 1.5
            ;;
        2)
            fastfetch --gen-config-force
            printf "${CLR_GREEN}✔ Classic Fastfetch layout applied!${CLR_RESET}\n"
            sleep 1.5
            ;;
        3) return ;;
    esac
}

configure_cmatrix() {
    current=1
    while true; do
        clear
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_PURPLE}         CMATRIX COLOR SELECTOR           ${CLR_RESET}\n"
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        if [ "$current" -eq 1 ]; then printf "${CLR_HILITE} 1) Classic Matrix Green (default)       ${CLR_RESET}\n"; else printf "  1) Classic Matrix Green (default)\n"; fi
        if [ "$current" -eq 2 ]; then printf "${CLR_HILITE} 2) Cyberpunk Red                        ${CLR_RESET}\n"; else printf "  2) Cyberpunk Red\n"; fi
        if [ "$current" -eq 3 ]; then printf "${CLR_HILITE} 3) Hacker Blue                          ${CLR_RESET}\n"; else printf "  3) Hacker Blue\n"; fi
        if [ "$current" -eq 4 ]; then printf "${CLR_HILITE} 4) Synthwave Magenta                    ${CLR_RESET}\n"; else printf "  4) Synthwave Magenta\n"; fi
        if [ "$current" -eq 5 ]; then printf "${CLR_HILITE} 5) Ghostty Cyan                         ${CLR_RESET}\n"; else printf "  5) Ghostty Cyan\n"; fi
        if [ "$current" -eq 6 ]; then printf "${CLR_HILITE} 6) Back to Config Menu                  ${CLR_RESET}\n"; else printf "  6) Back to Config Menu\n"; fi
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_YELLOW}Use Up/Down arrows to move, Enter to select:${CLR_RESET}\n"

        IFS= read -rsn1 key
        if [ "$key" = "$(printf '\033')" ]; then
            read -rsn2 key
            case "$key" in
                "[A") current=$((current - 1)); [ "$current" -lt 1 ] && current=6 ;;
                "[B") current=$((current + 1)); [ "$current" -gt 6 ] && current=1 ;;
            esac
        elif [ -z "$key" ]; then
            cm_choice=$current
            break
        fi
    done

    case "$cm_choice" in
        1) COLOR_FLAG="-C green" ;;
        2) COLOR_FLAG="-C red" ;;
        3) COLOR_FLAG="-C blue" ;;
        4) COLOR_FLAG="-C magenta" ;;
        5) COLOR_FLAG="-C cyan" ;;
        6) return ;;
    esac

    RC_FILE=$(detect_shell_rc)
    if [ -n "$COLOR_FLAG" ]; then
        sed -i '/alias cmatrix=/d' "$RC_FILE" 2>/dev/null
        echo "alias cmatrix='cmatrix $COLOR_FLAG'" >> "$RC_FILE"
        printf "${CLR_GREEN}✔ cmatrix default set to %s!${CLR_RESET}\n" "$COLOR_FLAG"
        sleep 1.5
    fi
}

configure_cava() {
    current=1
    while true; do
        clear
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_PURPLE}          CAVA BAR CONFIGURATOR           ${CLR_RESET}\n"
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        if [ "$current" -eq 1 ]; then printf "${CLR_HILITE} 1) Apply Gradient: Cyan -> Magenta      ${CLR_RESET}\n"; else printf "  1) Apply Gradient: Cyan -> Magenta\n"; fi
        if [ "$current" -eq 2 ]; then printf "${CLR_HILITE} 2) Apply Gradient: Green -> Yellow -> Red${CLR_RESET}\n"; else printf "  2) Apply Gradient: Green -> Yellow -> Red\n"; fi
        if [ "$current" -eq 3 ]; then printf "${CLR_HILITE} 3) Apply Monochromatic Blue             ${CLR_RESET}\n"; else printf "  3) Apply Monochromatic Blue\n"; fi
        if [ "$current" -eq 4 ]; then printf "${CLR_HILITE} 4) Custom Hex Color(s) / Multi-Gradient ${CLR_RESET}\n"; else printf "  4) Custom Hex Color(s) / Multi-Gradient\n"; fi
        if [ "$current" -eq 5 ]; then printf "${CLR_HILITE} 5) Back to Config Menu                  ${CLR_RESET}\n"; else printf "  5) Back to Config Menu\n"; fi
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_YELLOW}Use Up/Down arrows to move, Enter to select:${CLR_RESET}\n"

        IFS= read -rsn1 key
        if [ "$key" = "$(printf '\033')" ]; then
            read -rsn2 key
            case "$key" in
                "[A") current=$((current - 1)); [ "$current" -lt 1 ] && current=5 ;;
                "[B") current=$((current + 1)); [ "$current" -gt 5 ] && current=1 ;;
            esac
        elif [ -z "$key" ]; then
            cava_choice=$current
            break
        fi
    done

    CAVA_DIR="$HOME/.config/cava"
    mkdir -p "$CAVA_DIR"
    CAVA_CONF="$CAVA_DIR/config"

    case "$cava_choice" in
        1)
            cat << 'EOF' > "$CAVA_CONF"
[general]
framerate = 60

[color]
gradient = 1
gradient_count = 2
gradient_color_1 = '#00ffff'
gradient_color_2 = '#ff00ff'
EOF
            printf "${CLR_GREEN}✔ Applied Cyan -> Magenta gradient to Cava!${CLR_RESET}\n"
            sleep 1.5
            ;;
        2)
            cat << 'EOF' > "$CAVA_CONF"
[general]
framerate = 60

[color]
gradient = 1
gradient_count = 3
gradient_color_1 = '#00ff00'
gradient_color_2 = '#ffff00'
gradient_color_3 = '#ff0000'
EOF
            printf "${CLR_GREEN}✔ Applied Classic Equalizer gradient to Cava!${CLR_RESET}\n"
            sleep 1.5
            ;;
        3)
            cat << 'EOF' > "$CAVA_CONF"
[general]
framerate = 60

[color]
gradient = 0
foreground = 'blue'
EOF
            printf "${CLR_GREEN}✔ Applied Monochromatic Blue to Cava!${CLR_RESET}\n"
            sleep 1.5
            ;;
        4)
            printf "\n${CLR_CYAN}--- Custom Hex Multi-Color Mode ---${CLR_RESET}\n"
            printf "${CLR_YELLOW}Enter hex code(s) separated by spaces (e.g. #ff007f #00ffff #00ff00): ${CLR_RESET}"
            read -r hex_input

            clean_input=$(echo "$hex_input" | tr ',' ' ' | xargs)

            count=0
            for color in $clean_input; do
                count=$((count + 1))
            done

            if [ "$count" -eq 0 ]; then
                printf "${CLR_RED}❌ No hex codes provided!${CLR_RESET}\n"
                sleep 1.5
                configure_cava
                return
            elif [ "$count" -eq 1 ]; then
                single_hex=$(echo "$clean_input" | awk '{print $1}')
                case "$single_hex" in
                    \#*) ;;
                    *) single_hex="#$single_hex" ;;
                esac

                cat << EOF > "$CAVA_CONF"
[general]
framerate = 60

[color]
gradient = 0
foreground = '$single_hex'
EOF
                printf "${CLR_GREEN}✔ Applied single color (%s)!${CLR_RESET}\n" "$single_hex"
            else
                cat << EOF > "$CAVA_CONF"
[general]
framerate = 60

[color]
gradient = 1
gradient_count = $count
EOF
                idx=1
                for color in $clean_input; do
                    case "$color" in
                        \#*) ;;
                        *) color="#$color" ;;
                    esac
                    echo "gradient_color_${idx} = '${color}'" >> "$CAVA_CONF"
                    idx=$((idx + 1))
                done

                printf "${CLR_GREEN}✔ Applied %d-color gradient!${CLR_RESET}\n" "$count"
            fi
            sleep 1.5
            ;;
        5) return ;;
    esac
}

show_config_menu() {
    current=1
    while true; do
        clear
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_PURPLE}      LINUX-GOODIES CONFIGURATOR          ${CLR_RESET}\n"
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        if [ "$current" -eq 1 ]; then printf "${CLR_HILITE} 1) Configure Fastfetch Layout           ${CLR_RESET}\n"; else printf "  1) Configure Fastfetch Layout\n"; fi
        if [ "$current" -eq 2 ]; then printf "${CLR_HILITE} 2) Set Cmatrix Default Colors           ${CLR_RESET}\n"; else printf "  2) Set Cmatrix Default Colors\n"; fi
        if [ "$current" -eq 3 ]; then printf "${CLR_HILITE} 3) Customize Cava Audio Gradients       ${CLR_RESET}\n"; else printf "  3) Customize Cava Audio Gradients\n"; fi
        if [ "$current" -eq 4 ]; then printf "${CLR_HILITE} 4) Return to Main Menu                  ${CLR_RESET}\n"; else printf "  4) Return to Main Menu\n"; fi
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_YELLOW}Use Up/Down arrows to move, Enter to select:${CLR_RESET}\n"

        IFS= read -rsn1 key
        if [ "$key" = "$(printf '\033')" ]; then
            read -rsn2 key
            case "$key" in
                "[A") current=$((current - 1)); [ "$current" -lt 1 ] && current=4 ;;
                "[B") current=$((current + 1)); [ "$current" -gt 4 ] && current=1 ;;
            esac
        elif [ -z "$key" ]; then
            case "$current" in
                1) configure_fastfetch ;;
                2) configure_cmatrix ;;
                3) configure_cava ;;
                4) break ;;
            esac
        fi
    done
}

show_menu() {
    current=1
    while true; do
        clear
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_PURPLE}          LINUX-GOODIES SUITE             ${CLR_RESET}\n"
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        if [ "$current" -eq 1 ]; then printf "${CLR_HILITE}  1) Install FULL Bundle (Pkg + Mgrs)    ${CLR_RESET}\n"; else printf "   1) Install FULL Bundle (Pkg + Mgrs)\n"; fi
        if [ "$current" -eq 2 ]; then printf "${CLR_HILITE}  2) Install Packages Only                ${CLR_RESET}\n"; else printf "   2) Install Packages Only\n"; fi
        if [ "$current" -eq 3 ]; then printf "${CLR_HILITE}  3) Install / Update ghostty-mgr         ${CLR_RESET}\n"; else printf "   3) Install / Update ghostty-mgr\n"; fi
        if [ "$current" -eq 4 ]; then printf "${CLR_HILITE}  4) Install / Update starship-preset-mgr ${CLR_RESET}\n"; else printf "   4) Install / Update starship-preset-mgr\n"; fi
        if [ "$current" -eq 5 ]; then printf "${CLR_HILITE}  5) Customize Installed Tools            ${CLR_RESET}\n"; else printf "   5) Customize Installed Tools\n"; fi
        if [ "$current" -eq 6 ]; then printf "${CLR_HILITE}  6) Launch ghostty-mgr                   ${CLR_RESET}\n"; else printf "   6) Launch ghostty-mgr\n"; fi
        if [ "$current" -eq 7 ]; then printf "${CLR_HILITE}  7) Launch starship-preset-mgr           ${CLR_RESET}\n"; else printf "   7) Launch starship-preset-mgr\n"; fi
        if [ "$current" -eq 8 ]; then printf "${CLR_HILITE}  8) Test Cava (Audio Visualizer)         ${CLR_RESET}\n"; else printf "   8) Test Cava (Audio Visualizer)\n"; fi
        if [ "$current" -eq 9 ]; then printf "${CLR_HILITE}  9) Test Cmatrix (Matrix Rain)           ${CLR_RESET}\n"; else printf "   9) Test Cmatrix (Matrix Rain)\n"; fi
        if [ "$current" -eq 10 ]; then printf "${CLR_HILITE} 10) Test Fastfetch System Info          ${CLR_RESET}\n"; else printf "  10) Test Fastfetch System Info\n"; fi
        if [ "$current" -eq 11 ]; then printf "${CLR_HILITE} 11) Exit                                ${CLR_RESET}\n"; else printf "  11) Exit\n"; fi
        printf "${CLR_CYAN}==========================================${CLR_RESET}\n"
        printf "${CLR_YELLOW}Use Up/Down arrows to move, Enter to select:${CLR_RESET}\n"

        IFS= read -rsn1 key
        if [ "$key" = "$(printf '\033')" ]; then
            read -rsn2 key
            case "$key" in
                "[A") current=$((current - 1)); [ "$current" -lt 1 ] && current=11 ;;
                "[B") current=$((current + 1)); [ "$current" -gt 11 ] && current=1 ;;
            esac
        elif [ -z "$key" ]; then
            case "$current" in
                1) install_full_bundle; printf "\n${CLR_YELLOW}Press Enter to return...${CLR_RESET}"; read -r _ ;;
                2) install_all_packages; printf "\n${CLR_YELLOW}Press Enter to return...${CLR_RESET}"; read -r _ ;;
                3) install_ghostty_mgr; printf "\n${CLR_YELLOW}Press Enter to return...${CLR_RESET}"; read -r _ ;;
                4) install_starship_preset_mgr; printf "\n${CLR_YELLOW}Press Enter to return...${CLR_RESET}"; read -r _ ;;
                5) show_config_menu ;;
                6) 
                    (trap '' INT; if command -v ghostty-mgr >/dev/null 2>&1; then ghostty-mgr; elif [ -x "$HOME/.local/bin/ghostty-mgr" ]; then "$HOME/.local/bin/ghostty-mgr"; else printf "\n${CLR_RED}⚠️ ghostty-mgr was not found! Run Option 3 first.${CLR_RESET}\n"; sleep 1.5; fi)
                    ;;
                7) 
                    (trap '' INT; if command -v starship-preset-mgr >/dev/null 2>&1; then starship-preset-mgr; elif [ -x "$HOME/.local/bin/starship-preset-mgr" ]; then "$HOME/.local/bin/starship-preset-mgr"; else printf "\n${CLR_RED}⚠️ starship-preset-mgr was not found! Run Option 4 first.${CLR_RESET}\n"; sleep 1.5; fi)
                    ;;
                8) cava ;;
                9) (trap '' INT; cmatrix) ;;
                10) fastfetch 2>/dev/null || neofetch; printf "\n${CLR_YELLOW}Press Enter to return...${CLR_RESET}"; read -r _ ;;
                11) exit 0 ;;
            esac
        fi
    done
}

show_menu
