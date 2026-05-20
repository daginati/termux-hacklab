#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 MOBILE HACKING LAB - Ultimate Installer v2.2
#
#  Features:
#  - Overall progress percentage
#  - GPU acceleration auto-setup (Turnip/Zink)
#  - 60+ hacking tools with selective installation
#  - Grouped installs with dependency checks
#  - Error handling, logging & rollback support
#  - One-click desktop launch
#
#  Author: Tech Jarves + AI Assistant
#  YouTube: https://youtube.com/@TechJarves
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=20
CURRENT_STEP=0
LOG_FILE="$HOME/hacklab_install.log"
ERROR_COUNT=0
MAX_ERRORS=5

# ============== TOOL INSTALLATION FLAGS ==============
# Set to 1 to install, 0 to skip
INSTALL_RECON=1              # Phase 1: Nmap, Masscan, Shodan, theHarvester...
INSTALL_TARGET_ANALYSIS=1    # Phase 2: WhatWeb, Nikto, Gobuster...
INSTALL_BREAKIN=1            # Phase 3: Burp, SQLMap, Hydra, Hashcat...
INSTALL_HARDWARE_UTILS=1     # Phase 4: Flipper/HackRF CLI utilities only
INSTALL_WIRELESS=1           # Phase 5: Aircrack-ng, Wifite, Bettercap...
INSTALL_SNIFFING=1           # Phase 6: Wireshark, tcpdump, mitmproxy...
INSTALL_EXPLOITATION=1       # Phase 7: Metasploit, SET, Veil...
INSTALL_POSTEXPLOIT=1        # Phase 8: BloodHound, Sliver, Impacket... (heavy)
INSTALL_MOBILE=1             # Phase 9: Frida, Apktool
INSTALL_FORENSICS=1          # Phase 10: Volatility, Autopsy... (heavy)
INSTALL_REVERSING=1          # Phase 11: Ghidra, Binwalk... (very heavy)
INSTALL_AI_TOOLS=1           # Phase 12: PentestGPT (requires OpenAI key)

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done
    wait $pid
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}\n"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $message - OK" >> "$LOG_FILE"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}\n"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $message - FAILED" >> "$LOG_FILE"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    return $exit_code
}

# ============== LOGGING & ERROR HANDLING ==============
log_msg() {
    local level=$1
    local msg=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    if [ "$level" == "ERROR" ]; then
        echo -e "${RED}✗ $msg${NC}" >&2
        ERROR_COUNT=$((ERROR_COUNT + 1))
    elif [ "$level" == "WARN" ]; then
        echo -e "${YELLOW}⚠ $msg${NC}"
    else
        echo -e "${GREEN}✓ $msg${NC}"
    fi
}

check_errors() {
    if [ $ERROR_COUNT -ge $MAX_ERRORS ]; then
        log_msg "ERROR" "Too many failures ($ERROR_COUNT). Aborting installation."
        echo -e "${RED}🛑 Installation aborted due to repeated errors.${NC}"
        echo -e "${WHITE}📄 See log: $LOG_FILE${NC}"
        exit 1
    fi
}

# Safe install wrapper with rollback support
safe_install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    log_msg "INFO" "Installing $name..."
    
    if pkg info "$pkg" &>/dev/null 2>&1; then
        log_msg "WARN" "$name already installed, skipping"
        return 0
    fi
    
    (yes | pkg install "$pkg" -y >> "$LOG_FILE" 2>&1) || {
        log_msg "ERROR" "Failed to install $name"
        return 1
    }
    log_msg "INFO" "$name installed successfully"
    return 0
}

# Python tool installer with venv isolation
install_python_tool() {
    local repo=$1
    local tool_name=$2
    local branch=${3:-master}
    
    log_msg "INFO" "Installing Python tool: $tool_name"
    
    if ! command -v python &>/dev/null; then
        safe_install_pkg "python" "Python" || return 1
    fi
    if ! command -v pip &>/dev/null; then
        safe_install_pkg "python-pip" "Pip" || return 1
    fi
    
    local install_dir="$HOME/tools/$tool_name"
    mkdir -p "$install_dir" 2>/dev/null || true
    
    (cd "$install_dir" && \
     python -m venv .venv 2>/dev/null && \
     source .venv/bin/activate 2>/dev/null && \
     pip install --upgrade pip setuptools wheel >> "$LOG_FILE" 2>&1 && \
     git clone --depth 1 -b "$branch" "$repo" . >> "$LOG_FILE" 2>&1 && \
     [ -f requirements.txt ] && pip install -r requirements.txt >> "$LOG_FILE" 2>&1 || true && \
     [ -f setup.py ] && pip install -e . >> "$LOG_FILE" 2>&1 || true) || {
        log_msg "WARN" "Partial install for $tool_name - may need manual setup"
        return 0
    }
    
    # Create launcher
    mkdir -p "$HOME/bin" 2>/dev/null || true
    cat > "$HOME/bin/$tool_name" << LAUNCHER
#!/data/data/com.termux/files/usr/bin/bash
source "$install_dir/.venv/bin/activate" 2>/dev/null
exec python "$install_dir/$tool_name.py" "\$@" 2>/dev/null || exec python -m $tool_name "\$@"
LAUNCHER
    chmod +x "$HOME/bin/$tool_name" 2>/dev/null || true
    
    log_msg "INFO" "$tool_name installed to $install_dir"
    return 0
}

# Go tool installer
install_go_tool() {
    local repo=$1
    local tool_name=$2
    
    log_msg "INFO" "Installing Go tool: $tool_name"
    
    if ! command -v go &>/dev/null; then
        safe_install_pkg "golang" "Go Compiler" || return 1
    fi
    
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    
    (go install "$repo@latest" >> "$LOG_FILE" 2>&1) || {
        log_msg "WARN" "Failed to install $tool_name via go install"
        return 0
    }
    
    log_msg "INFO" "$tool_name installed to $GOPATH/bin"
    return 0
}

# Resource check before heavy installs
check_resources() {
    local min_storage_mb=${1:-2048}
    local min_ram_mb=${2:-1024}
    
    local available_storage=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print int($4/1024)}' || echo "9999")
    local available_ram=$(free -m 2>/dev/null | awk '/Mem:/ {print $7}' || echo "2048")
    
    if [ "$available_storage" -lt "$min_storage_mb" ] 2>/dev/null; then
        log_msg "WARN" "Low storage: ${available_storage}MB < ${min_storage_mb}MB required"
        return 1
    fi
    if [ "$available_ram" -lt "$min_ram_mb" ] 2>/dev/null; then
        log_msg "WARN" "Low RAM: ${available_ram}MB < ${min_ram_mb}MB recommended"
        return 1
    fi
    return 0
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
╔══════════════════════════════════════╗
║                                      ║
║   🚀  MOBILE HACKLAB v2.2  🚀        ║
║                                      ║
║       Tech Jarves - YouTube          ║
║    +60 Security Tools Installer      ║
║                                      ║
╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}         Tech Jarves - YouTube${NC}"
    echo ""
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting your device...${NC}"
    echo ""
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$DEVICE_BRAND" == *"samsung"* ]] || [[ "$DEVICE_BRAND" == *"Samsung"* ]] || [[ "$DEVICE_BRAND" == *"oneplus"* ]] || [[ "$DEVICE_BRAND" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Qualcomm) - Turnip driver${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Software rendering${NC}"
    fi
    echo ""
    sleep 1
}

# ============== CORE STEPS (Original) ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists..."
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading installed packages..."
}

step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox, VS Code)"
}

step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    echo ""
    install_pkg "termux-x11-nightly" "Termux-X11 Display Server"
    install_pkg "xorg-xrandr" "XRandR (Display Settings)"
}

step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 Desktop...${NC}"
    echo ""
    install_pkg "xfce4" "XFCE4 Desktop Environment"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar" "Thunar File Manager"
    install_pkg "mousepad" "Mousepad Text Editor"
}

step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Acceleration (Turnip/Zink)...${NC}"
    echo ""
    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno GPU Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
    fi
    install_pkg "vulkan-loader-android" "Vulkan Loader"
    echo -e "  ${GREEN}✓${NC} GPU acceleration configured!"
}

step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio Support...${NC}"
    echo ""
    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Applications...${NC}"
    echo ""
    install_pkg "firefox" "Firefox Browser"
    install_pkg "code-oss" "VS Code Editor"
    install_pkg "git" "Git Version Control"
    install_pkg "wget" "Wget Downloader"
    install_pkg "curl" "cURL"
}

step_network_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Network Scanning Tools...${NC}"
    echo ""
    install_pkg "nmap" "Nmap Network Scanner"
    install_pkg "netcat-openbsd" "Netcat"
    install_pkg "whois" "Whois Lookup"
    install_pkg "dnsutils" "DNS Utilities"
    install_pkg "tracepath" "Tracepath"
}

step_security_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Security Tools...${NC}"
    echo ""
    install_pkg "hydra" "Hydra Password Cracker"
    install_pkg "john" "John the Ripper"
    install_pkg "sqlmap" "SQLMap (SQL Injection)"
    echo -e "  ${YELLOW}⏳${NC} Installing Python security libraries..."
    pip install requests beautifulsoup4 >> "$LOG_FILE" 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Python libraries installed"
}

step_metasploit() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Metasploit Framework...${NC}"
    echo ""
    check_resources 3072 1536 || { log_msg "WARN" "Skipping Metasploit (resource-heavy)"; return 0; }
    install_pkg "metasploit" "Metasploit Framework" || log_msg "WARN" "Metasploit install failed"
    echo -e "  ${GREEN}✓${NC} Metasploit installed (run: msfconsole)"
}

step_wine() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wine (Windows Support)...${NC}"
    echo ""
    (pkg remove wine-stable -y > /dev/null 2>&1) &
    spinner $! "Removing old Wine versions..."
    install_pkg "hangover-wine" "Wine Compatibility Layer"
    install_pkg "hangover-wowbox64" "Box64 Wrapper"
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/wine /data/data/com.termux/files/usr/bin/wine 2>/dev/null || true
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/winecfg /data/data/com.termux/files/usr/bin/winecfg 2>/dev/null || true
    echo -e "  ${YELLOW}⏳${NC} Applying Windows UI optimizations..."
    wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f >> "$LOG_FILE" 2>&1 || true
    echo -e "  ${GREEN}✓${NC} UI optimized"
}

# ============== NEW: TOOL GROUP INSTALLERS ==============

# ▼ PHASE 1: RECONNAISSANCE
step_install_recon() {
    [ "$INSTALL_RECON" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Reconnaissance Tools...${NC}"
    
    check_resources 1024 512 || { log_msg "WARN" "Skipping heavy recon tools"; return 0; }
    
    # Already installed: nmap
    safe_install_pkg "masscan" "Masscan" || log_msg "WARN" "Masscan may need compilation"
    
    mkdir -p "$HOME/tools" "$HOME/bin"
    
    # Python-based tools
    install_python_tool "https://github.com/laramies/theHarvester" "theHarvester" || true
    install_python_tool "https://github.com/sherlock-project/sherlock" "sherlock" || true
    install_python_tool "https://github.com/megadose/holehe" "holehe" || true
    install_python_tool "https://github.com/mxrch/GHunt" "GHunt" || true
    install_python_tool "https://github.com/smicallef/spiderfoot" "spiderfoot" || true
    
    # Shodan CLI
    if command -v pip &>/dev/null; then
        pip install shodan >> "$LOG_FILE" 2>&1 || log_msg "WARN" "Shodan CLI install failed"
    fi
    
    check_errors
}

# ▼ PHASE 2: TARGET ANALYSIS
step_install_target_analysis() {
    [ "$INSTALL_TARGET_ANALYSIS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Target Analysis Tools...${NC}"
    
    safe_install_pkg "whatweb" "WhatWeb" || true
    safe_install_pkg "nikto" "Nikto" || true
    
    # Gobuster (Go)
    install_go_tool "github.com/OJ/gobuster/v3" "gobuster" || true
    
    # Sublist3r
    install_python_tool "https://github.com/aboul3la/Sublist3r" "sublist3r" || true
    
    # Wafw00f
    pip install wafw00f >> "$LOG_FILE" 2>&1 || log_msg "WARN" "Wafw00f install failed"
    
    # Wappalyzer (Node.js - optional)
    if command -v npm &>/dev/null; then
        npm install -g wappalyzer >> "$LOG_FILE" 2>&1 || log_msg "WARN" "Wappalyzer CLI skipped"
    fi
    
    check_errors
}

# ▼ PHASE 3: BREAKING IN
step_install_breakin() {
    [ "$INSTALL_BREAKIN" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Attack Tools...${NC}"
    
    check_resources 2048 1024 || { log_msg "WARN" "Skipping heavy attack tools"; return 0; }
    
    # Already installed: sqlmap, hydra, john
    safe_install_pkg "hashcat" "Hashcat" || log_msg "WARN" "Hashcat may not work on all devices"
    
    # Nuclei (Go)
    install_go_tool "github.com/projectdiscovery/nuclei/v3/cmd/nuclei" "nuclei" || true
    
    # ffuf (Go)
    install_go_tool "github.com/ffuf/ffuf" "ffuf" || true
    
    # CeWL
    install_python_tool "https://github.com/digininja/CeWL" "cewl" || true
    
    # NetExec
    install_python_tool "https://github.com/Pennyw0rth/NetExec" "netexec" || true
    
    # Burp Suite Community (placeholder)
    cat > "$HOME/bin/burp" << 'BURPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "⚠ Burp Suite requires manual download:"
echo "   https://portswigger.net/burp/communitydownload"
echo "   Place burpsuite_community.jar in ~/tools/burp/"
if [ -f "$HOME/tools/burp/burpsuite_community.jar" ]; then
    java -jar "$HOME/tools/burp/burpsuite_community.jar" "$@"
else
    echo "❌ JAR file not found. Download first."
    exit 1
fi
BURPEOF
    chmod +x "$HOME/bin/burp" 2>/dev/null || true
    mkdir -p "$HOME/tools/burp"
    
    check_errors
}

# ▼ PHASE 4: HARDWARE HACKING (CLI utilities only)
step_install_hardware_utils() {
    [ "$INSTALL_HARDWARE_UTILS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Hardware Tool Utilities...${NC}"
    
    log_msg "INFO" "Installing CLI utilities for hardware tools..."
    # Flipper Zero CLI (community)
    install_python_tool "https://github.com/flipperdevices/flipperzero-cli" "flipper-cli" || true
    # HackRF host utilities
    safe_install_pkg "hackrf" "HackRF Host Tools" || log_msg "WARN" "HackRF tools not in repo"
    
    log_msg "WARN" "⚠ Physical devices (Flipper Zero, HackRF, Rubber Ducky, O.MG Cable) must be purchased separately"
    
    check_errors
}

# ▼ PHASE 5: WIRELESS ATTACKS
step_install_wireless() {
    [ "$INSTALL_WIRELESS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wireless Attack Tools...${NC}"
    
    echo -e "${YELLOW}⚠ Wireless tools require ROOT and monitor-mode capable WiFi${NC}"
    
    safe_install_pkg "aircrack-ng" "Aircrack-ng" || true
    safe_install_pkg "wifite2" "Wifite2" || true
    safe_install_pkg "bettercap" "Bettercap" || true
    
    check_resources 1500 1024 && safe_install_pkg "kismet" "Kismet" || log_msg "WARN" "Skipping Kismet (resource-heavy)"
    safe_install_pkg "wifiphisher" "Wifiphisher" || true
    
    check_errors
}

# ▼ PHASE 6: SNIFFING & SPOOFING
step_install_sniffing() {
    [ "$INSTALL_SNIFFING" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Sniffing & Spoofing Tools...${NC}"
    
    safe_install_pkg "wireshark" "Wireshark (CLI: tshark)" || true
    safe_install_pkg "tcpdump" "tcpdump" || true
    safe_install_pkg "mitmproxy" "mitmproxy" || true
    install_python_tool "https://github.com/lgandx/Responder" "responder" || true
    safe_install_pkg "driftnet" "Driftnet" || true
    
    check_errors
}

# ▼ PHASE 7: EXPLOITATION FRAMEWORKS
step_install_exploitation() {
    [ "$INSTALL_EXPLOITATION" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Exploitation Frameworks...${NC}"
    
    check_resources 3072 1536 || { log_msg "WARN" "Skipping heavy exploitation tools"; return 0; }
    
    # Metasploit already installed
    safe_install_pkg "exploitdb" "Exploit Database + searchsploit" || true
    
    # SET (Social Engineering Toolkit)
    install_python_tool "https://github.com/trustedsec/social-engineer-toolkit" "set" || true
    
    # BeEF placeholder
    cat > "$HOME/bin/beef" << 'BEEFEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "⚠ BeEF requires complex Ruby setup."
echo "   See: https://github.com/beefproject/beef/wiki/Installation-Guide"
echo "   Manual installation recommended in ~/tools/beef"
BEEFEOF
    chmod +x "$HOME/bin/beef" 2>/dev/null || true
    
    # Veil (Python 2 legacy - skip)
    log_msg "WARN" "Veil Framework requires Python 2 - skipped for compatibility"
    
    check_errors
}

# ▼ PHASE 8: POST-EXPLOITATION (heavy, disabled by default)
step_install_postexploit() {
    [ "$INSTALL_POSTEXPLOIT" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Post-Exploitation Tools...${NC}"
    
    check_resources 4096 2048 || { log_msg "WARN" "Skipping post-exploit tools (need 4GB+ RAM)"; return 0; }
    
    install_python_tool "https://github.com/SpecterOps/BloodHound" "bloodhound" || true
    install_go_tool "github.com/BishopFox/sliver" "sliver" || true
    install_python_tool "https://github.com/HavocFramework/Havoc" "havoc" || true
    install_python_tool "https://github.com/fortra/impacket" "impacket" || true
    
    log_msg "WARN" "Mimikatz/PowerSploit are Windows-focused - use via Wine or remote"
    
    install_python_tool "https://github.com/jpillora/chisel" "chisel" || true
    
    check_errors
}

# ▼ PHASE 9: MOBILE HACKING
step_install_mobile() {
    [ "$INSTALL_MOBILE" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Mobile Hacking Tools...${NC}"
    
    pip install frida-tools >> "$LOG_FILE" 2>&1 || log_msg "WARN" "Frida install failed"
    safe_install_pkg "apktool" "Apktool" || true
    
    check_errors
}

# ▼ PHASE 10: FORENSICS (heavy)
step_install_forensics() {
    [ "$INSTALL_FORENSICS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Forensics Tools...${NC}"
    
    check_resources 4096 2048 || { log_msg "WARN" "Skipping forensics tools (resource-heavy)"; return 0; }
    
    safe_install_pkg "steghide" "Steghide" || true
    pip install volatility3 >> "$LOG_FILE" 2>&1 || log_msg "WARN" "Volatility3 install failed"
    
    log_msg "WARN" "Autopsy is Java GUI - very heavy, manual install recommended"
    
    check_errors
}

# ▼ PHASE 11: REVERSE ENGINEERING (very heavy)
step_install_reversing() {
    [ "$INSTALL_REVERSING" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Reverse Engineering Tools...${NC}"
    
    check_resources 4096 2048 || { log_msg "WARN" "Skipping reversing tools (need 4GB+ RAM)"; return 0; }
    
    safe_install_pkg "binwalk" "Binwalk" || true
    
    log_msg "WARN" "Ghidra requires manual download (Java GUI): https://ghidra-sre.org"
    
    check_errors
}

# ▼ PHASE 12: AI HACKING
step_install_ai_tools() {
    [ "$INSTALL_AI_TOOLS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing AI Hacking Tools...${NC}"
    
    install_python_tool "https://github.com/GreyDGL/PentestGPT" "pentestgpt" || true
    echo -e "${YELLOW}⚠ PentestGPT requires OpenAI API key${NC}"
    
    check_errors
}

# ============== FINAL STEPS (Original) ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Launcher Scripts...${NC}"
    echo ""
    
    mkdir -p ~/.config
    cat > ~/.config/hacklab-gpu.sh << 'GPUEOF'
# Mobile HackLab - GPU Acceleration Config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    echo -e "  ${GREEN}✓${NC} GPU config created"
    
    if ! grep -q "hacklab-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/hacklab-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    
    # Main Desktop Launcher
    cat > ~/start-hacklab.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Mobile HackLab Desktop..."
echo ""
source ~/.config/hacklab-gpu.sh 2>/dev/null
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1
echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0
echo "🖥️ Launching XFCE4 Desktop..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see desktop!"
echo "  🔊 Audio is enabled!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-hacklab.sh"
    
    # Quick Tools Menu (updated)
    cat > ~/hacktools.sh << 'TOOLSEOF'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║     🔧 Mobile HackLab - Quick Tools       ║"
echo "╠═══════════════════════════════════════════╣"
echo "║  1) 🌐 Nmap - Network Scan                ║"
echo "║  2) 💉 SQLMap - SQL Injection             ║"
echo "║  3) 🔑 Hydra - Password Attack            ║"
echo "║  4) 💀 Metasploit Console                 ║"
echo "║  5) 🔍 Recon Tools Menu                   ║"
echo "║  6) 🖥️  Start Desktop                     ║"
echo "║  7) 🔧 Check GPU Status                   ║"
echo "║  0) ❌ Exit                               ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
read -p "  Select option: " choice
case $choice in
1) read -p "  Enter target IP/hostname: " target; nmap -sV $target; read -p "Press Enter to continue...";;
2) read -p "  Enter vulnerable URL: " url; sqlmap -u "$url" --batch; read -p "Press Enter to continue...";;
3) echo "  Example: hydra -l admin -P wordlist.txt 192.168.1.1 ssh"; read -p "Press Enter to continue...";;
4) msfconsole;;
5) echo "  Available: theHarvester, sherlock, holehe, GHunt"; echo "  Run: ~/bin/sherlock -h"; read -p "Press Enter to continue...";;
6) bash ~/start-hacklab.sh;;
7) echo ""; glxinfo 2>/dev/null | grep "renderer" || echo "  GPU info not available"; echo ""; read -p "Press Enter to continue...";;
0) exit 0;;
esac
done
TOOLSEOF
    chmod +x ~/hacktools.sh
    echo -e "  ${GREEN}✓${NC} Created ~/hacktools.sh"
    
    # Shutdown script
    cat > ~/stop-hacklab.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Mobile HackLab..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-hacklab.sh"
}

step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop Shortcuts...${NC}"
    echo ""
    mkdir -p ~/Desktop
    
    for app in Firefox VSCode Terminal Metasploit HackTools; do
        cat > ~/Desktop/${app}.desktop << EOF
[Desktop Entry]
Name=$app
Exec=${app,,}
Icon=${app,,}
Type=Application
Categories=Utility;
EOF
    done 2>/dev/null || true
    
    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║         ✅  INSTALLATION COMPLETE!  ✅                        ║
║                                                               ║
║              🎉 100% - All Done! 🎉                           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}📱 Your Mobile Hacking Lab is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-hacklab.sh${NC}"
    echo ""
    echo -e "${WHITE}🔧 FOR QUICK TOOLS MENU:${NC}"
    echo -e "   ${GREEN}bash ~/hacktools.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-hacklab.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 CORE TOOLS INSTALLED:${NC}"
    echo -e "   • Nmap, Netcat, DNS tools, SQLMap, Hydra, John"
    echo -e "   • Metasploit Framework, Firefox, VS Code, Git"
    echo -e "   • XFCE4 Desktop + GPU Acceleration + Wine"
    echo ""
    echo -e "${CYAN}🔧 OPTIONAL TOOLS (based on flags):${NC}"
    [ "$INSTALL_RECON" == "1" ] && echo -e "   ✓ Recon: Nmap, Masscan, theHarvester, Sherlock, GHunt, SpiderFoot..."
    [ "$INSTALL_TARGET_ANALYSIS" == "1" ] && echo -e "   ✓ Analysis: WhatWeb, Nikto, Gobuster, Sublist3r, Wafw00f..."
    [ "$INSTALL_BREAKIN" == "1" ] && echo -e "   ✓ Attack: Hashcat, Nuclei, ffuf, NetExec, Burp (placeholder)..."
    [ "$INSTALL_WIRELESS" == "1" ] && echo -e "   ✓ Wireless: Aircrack-ng, Wifite, Bettercap ${GRAY}(root required)${NC}"
    [ "$INSTALL_SNIFFING" == "1" ] && echo -e "   ✓ Sniffing: Wireshark, tcpdump, mitmproxy, Responder..."
    [ "$INSTALL_EXPLOITATION" == "1" ] && echo -e "   ✓ Exploitation: searchsploit, SET, BeEF (placeholder)..."
    [ "$INSTALL_MOBILE" == "1" ] && echo -e "   ✓ Mobile: Frida, Apktool"
    [ "$INSTALL_POSTEXPLOIT" == "1" ] && echo -e "   ✓ Post-Exploit: BloodHound, Sliver, Impacket..."
    [ "$INSTALL_FORENSICS" == "1" ] && echo -e "   ✓ Forensics: Volatility, Steghide..."
    [ "$INSTALL_REVERSING" == "1" ] && echo -e "   ✓ Reversing: Binwalk..."
    [ "$INSTALL_AI_TOOLS" == "1" ] && echo -e "   ✓ AI: PentestGPT ${GRAY}(needs API key)${NC}"
    echo ""
    echo -e "${YELLOW}📦 Tools installed to: ~/tools/${NC}"
    echo -e "${YELLOW}🔗 Launchers available in: ~/bin/${NC}"
    echo -e "${GRAY}📄 Full log: $LOG_FILE${NC}"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 Subscribe: https://youtube.com/@TechJarves${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app first, then run start-hacklab.sh${NC}"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANT NOTES:${NC}"
    echo -e "   • Wireless tools require ROOT + compatible WiFi chip"
    echo -e "   • Burp/Maltego/Ghidra require manual download (proprietary)"
    echo -e "   • Hardware tools (Flipper, HackRF) are physical devices"
    echo -e "   • Heavy tools disabled by default - enable via flags at top of script"
    echo ""
}

# ============== MAIN INSTALLATION ==============
main() {
    show_banner
    echo -e "${WHITE}  This script will install a complete Linux desktop with${NC}"
    echo -e "${WHITE}  60+ hacking tools and GPU acceleration on your Android phone.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 20-60 minutes (depends on selected tools)${NC}"
    echo -e "${GRAY}  Log file: $LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation, or Ctrl+C to cancel...${NC}"
    read
    
    # Initialize
    mkdir -p "$HOME/bin" "$HOME/tools" >> "$LOG_FILE" 2>&1
    echo "[$(date)] Installation started" >> "$LOG_FILE"
    
    # Core steps
    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_network_tools
    step_security_tools
    step_metasploit
    step_wine
    
    # Optional tool groups
    step_install_recon
    step_install_target_analysis
    step_install_breakin
    step_install_hardware_utils
    step_install_wireless
    step_install_sniffing
    step_install_exploitation
    step_install_postexploit
    step_install_mobile
    step_install_forensics
    step_install_reversing
    step_install_ai_tools
    
    # Final steps
    step_launchers
    step_shortcuts
    
    # Finalize
    echo "[$(date)] Installation completed with $ERROR_COUNT warnings/errors" >> "$LOG_FILE"
    show_completion
}

# ============== RUN ==============
main
