#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 MOBILE HACKING LAB - Ultimate Installer v2.2
#
#  Features:
#  - Selective tool installation (flags)
#  - Safe dependency handling (|| true)
#  - No broken functions, Termux-optimized
#  - One-click desktop launch
#
#  Author: Tech Jarves + Fixed
#  YouTube: https://youtube.com/@TechJarves
#######################################################

# ============== CONFIGURATION & FLAGS ==============
TOTAL_STEPS=23
CURRENT_STEP=0

# Set to 1 to install, 0 to skip
INSTALL_RECON=1              # Nmap, Masscan, Shodan, Sherlock, GHunt...
INSTALL_TARGET_ANALYSIS=1    # WhatWeb, Nikto, Gobuster, Sublist3r...
INSTALL_BREAKIN=1            # Hashcat, Nuclei, ffuf, NetExec, Burp...
INSTALL_HARDWARE_UTILS=0     # Flipper/HackRF CLI tools only
INSTALL_WIRELESS=1           # Aircrack-ng, Wifite, Bettercap...
INSTALL_SNIFFING=1           # Wireshark, tcpdump, mitmproxy...
INSTALL_EXPLOITATION=1       # Metasploit, SET, searchsploit...
INSTALL_POSTEXPLOIT=0        # BloodHound, Sliver, Impacket... (heavy)
INSTALL_MOBILE=1             # Frida, Apktool
INSTALL_FORENSICS=0          # Volatility, Steghide... (heavy)
INSTALL_REVERSING=0          # Binwalk, Ghidra placeholder... (very heavy)
INSTALL_AI_TOOLS=0           # PentestGPT (needs API key)

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

# ============== PROGRESS & INSTALL FUNCTIONS ==============
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
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}\n"
    fi
    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (yes | pkg install "$pkg" -y > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
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
    pip install requests beautifulsoup4 > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Python libraries installed"
}

step_metasploit() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Metasploit Framework...${NC}"
    echo ""
    install_pkg "metasploit" "Metasploit Framework" || echo -e "  ${YELLOW}⚠ Metasploit install skipped or failed (check repo)${NC}"
    install_pkg "exploitdb" "Exploit Database + searchsploit" || true
    echo -e "  ${GREEN}✓${NC} Metasploit & searchsploit ready"
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
    wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} UI optimized"
}

# ============== NEW: OPTIONAL TOOL GROUPS ==============
step_install_recon() {
    [ "$INSTALL_RECON" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Reconnaissance Tools...${NC}"
    install_pkg "masscan" "Masscan" || true
    pip install shodan > /dev/null 2>&1 || true
    mkdir -p ~/tools && cd ~/tools
    [ -d theHarvester ] || git clone --depth 1 https://github.com/laramies/theHarvester.git && cd theHarvester && pip install -r requirements.txt > /dev/null 2>&1 || true
    cd ~/tools && [ -d sherlock ] || git clone --depth 1 https://github.com/sherlock-project/sherlock.git && cd sherlock && pip install -r requirements.txt > /dev/null 2>&1 || true
    cd ~/tools && [ -d holehe ] || git clone --depth 1 https://github.com/megadose/holehe.git && cd holehe && pip install . > /dev/null 2>&1 || true
    cd ~/tools && [ -d GHunt ] || git clone --depth 1 https://github.com/mxrch/GHunt.git && cd GHunt && pip install -r requirements.txt > /dev/null 2>&1 || true
    cd ~/tools && [ -d spiderfoot ] || git clone --depth 1 https://github.com/smicallef/spiderfoot.git && cd spiderfoot && pip install -r requirements.txt > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Recon tools installed"
}

step_install_target_analysis() {
    [ "$INSTALL_TARGET_ANALYSIS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Target Analysis Tools...${NC}"
    install_pkg "whatweb" "WhatWeb" || true
    install_pkg "nikto" "Nikto" || true
    install_pkg "gobuster" "Gobuster" || true
    pip install wafw00f > /dev/null 2>&1 || true
    cd ~/tools && [ -d Sublist3r ] || git clone --depth 1 https://github.com/aboul3la/Sublist3r.git && cd Sublist3r && pip install -r requirements.txt > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Analysis tools installed"
}

step_install_breakin() {
    [ "$INSTALL_BREAKIN" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Attack Tools...${NC}"
    install_pkg "hashcat" "Hashcat" || true
    install_pkg "nuclei" "Nuclei" || true
    install_pkg "ffuf" "ffuf" || true
    cd ~/tools && [ -d CeWL ] || git clone --depth 1 https://github.com/digininja/CeWL.git && cd CeWL && pip install -r Gemfile.lock 2>/dev/null || true
    cd ~/tools && [ -d NetExec ] || git clone --depth 1 https://github.com/Pennyw0rth/NetExec.git && cd NetExec && pip install . > /dev/null 2>&1 || true
    mkdir -p ~/tools/burp
    echo -e "  ${GREEN}✓${NC} Attack tools installed (Burp requires manual JAR download)"
}

step_install_hardware_utils() {
    [ "$INSTALL_HARDWARE_UTILS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Hardware CLI Utilities...${NC}"
    install_pkg "hackrf" "HackRF Host Tools" || true
    echo -e "  ${YELLOW}⚠ Physical devices (Flipper, Ducky, O.MG) are not software${NC}"
    echo -e "  ${GREEN}✓${NC} CLI utilities ready"
}

step_install_wireless() {
    [ "$INSTALL_WIRELESS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wireless Attack Tools...${NC}"
    echo -e "  ${YELLOW}⚠ Requires ROOT + monitor-mode WiFi chip${NC}"
    install_pkg "aircrack-ng" "Aircrack-ng" || true
    install_pkg "wifite2" "Wifite2" || true
    install_pkg "bettercap" "Bettercap" || true
    install_pkg "kismet" "Kismet" || true
    install_pkg "wifiphisher" "Wifiphisher" || true
    echo -e "  ${GREEN}✓${NC} Wireless tools installed"
}

step_install_sniffing() {
    [ "$INSTALL_SNIFFING" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Sniffing & Spoofing Tools...${NC}"
    install_pkg "wireshark" "Wireshark (tshark)" || true
    install_pkg "tcpdump" "tcpdump" || true
    install_pkg "mitmproxy" "mitmproxy" || true
    cd ~/tools && [ -d Responder ] || git clone --depth 1 https://github.com/lgandx/Responder.git
    echo -e "  ${GREEN}✓${NC} Sniffing tools installed"
}

step_install_exploitation() {
    [ "$INSTALL_EXPLOITATION" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Exploitation Frameworks...${NC}"
    cd ~/tools && [ -d social-engineer-toolkit ] || git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git
    cd ~/tools/social-engineer-toolkit && pip install -r requirements.txt > /dev/null 2>&1 || true
    echo -e "  ${YELLOW}⚠ Veil & BeEF skipped (legacy/complex)${NC}"
    echo -e "  ${GREEN}✓${NC} Exploitation tools installed"
}

step_install_postexploit() {
    [ "$INSTALL_POSTEXPLOIT" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Post-Exploitation Tools...${NC}"
    pip install impacket bloodhound-py > /dev/null 2>&1 || true
    install_pkg "chisel" "Chisel" || true
    echo -e "  ${YELLOW}⚠ Mimikatz/PowerSploit are Windows-focused${NC}"
    echo -e "  ${GREEN}✓${NC} Post-exploit tools installed"
}

step_install_mobile() {
    [ "$INSTALL_MOBILE" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Mobile Hacking Tools...${NC}"
    pip install frida-tools > /dev/null 2>&1 || true
    install_pkg "apktool" "Apktool" || true
    echo -e "  ${GREEN}✓${NC} Mobile tools installed"
}

step_install_forensics() {
    [ "$INSTALL_FORENSICS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Forensics Tools...${NC}"
    install_pkg "steghide" "Steghide" || true
    pip install volatility3 > /dev/null 2>&1 || true
    echo -e "  ${YELLOW}⚠ Autopsy requires Java GUI (skip)${NC}"
    echo -e "  ${GREEN}✓${NC} Forensics tools installed"
}

step_install_reversing() {
    [ "$INSTALL_REVERSING" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Reverse Engineering Tools...${NC}"
    install_pkg "binwalk" "Binwalk" || true
    echo -e "  ${YELLOW}⚠ Ghidra requires manual download (ghidra-sre.org)${NC}"
    echo -e "  ${GREEN}✓${NC} Reversing tools installed"
}

step_install_ai_tools() {
    [ "$INSTALL_AI_TOOLS" != "1" ] && return 0
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing AI Hacking Tools...${NC}"
    cd ~/tools && [ -d PentestGPT ] || git clone --depth 1 https://github.com/GreyDGL/PentestGPT.git
    cd ~/tools/PentestGPT && pip install -r requirements.txt > /dev/null 2>&1 || true
    echo -e "  ${YELLOW}⚠ Requires OpenAI API key${NC}"
    echo -e "  ${GREEN}✓${NC} AI tools installed"
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
    grep -q "hacklab-gpu.sh" ~/.bashrc 2>/dev/null || echo 'source ~/.config/hacklab-gpu.sh 2>/dev/null' >> ~/.bashrc

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
echo "║  5) 🔍 Recon Tools                        ║"
echo "║  6) 🖥️  Start Desktop                     ║"
echo "║  7) 🔧 Check GPU Status                   ║"
echo "║  0) ❌ Exit                               ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
read -p "  Select option: " choice
case $choice in
1) read -p "  Target: " target; nmap -sV "$target"; read -p "Enter...";;
2) read -p "  URL: " url; sqlmap -u "$url" --batch; read -p "Enter...";;
3) echo "  hydra -l user -P pass.txt target ssh"; read -p "Enter...";;
4) msfconsole;;
5) echo "  ~/tools/sherlock/sherlock.py, ~/tools/Ghunt, etc."; read -p "Enter...";;
6) bash ~/start-hacklab.sh;;
7) glxinfo 2>/dev/null | grep "renderer" || echo "  GPU info N/A"; read -p "Enter...";;
0) exit 0;;
esac
done
TOOLSEOF
    chmod +x ~/hacktools.sh

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
    echo -e "  ${GREEN}✓${NC} Launchers created"
}

step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop Shortcuts...${NC}"
    echo ""
    mkdir -p ~/Desktop
    for name in Firefox VSCode Terminal Metasploit HackTools; do
        cat > ~/Desktop/${name}.desktop << EOF
[Desktop Entry]
Name=$name
Exec=${name,,}
Icon=${name,,}
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
    echo -e "${WHITE}🔧 FOR QUICK TOOLS MENU:${NC}"
    echo -e "   ${GREEN}bash ~/hacktools.sh${NC}"
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-hacklab.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED TOOLS:${NC}"
    echo -e "   • Core: Nmap, SQLMap, Hydra, John, Metasploit, Wine"
    [ "$INSTALL_RECON" == "1" ] && echo -e "   ✓ Recon: Masscan, Shodan, Sherlock, GHunt, SpiderFoot..."
    [ "$INSTALL_TARGET_ANALYSIS" == "1" ] && echo -e "   ✓ Analysis: WhatWeb, Nikto, Gobuster, Sublist3r..."
    [ "$INSTALL_BREAKIN" == "1" ] && echo -e "   ✓ Attack: Hashcat, Nuclei, ffuf, NetExec..."
    [ "$INSTALL_WIRELESS" == "1" ] && echo -e "   ✓ Wireless: Aircrack-ng, Wifite, Bettercap ${GRAY}(root)${NC}"
    [ "$INSTALL_SNIFFING" == "1" ] && echo -e "   ✓ Sniffing: Wireshark, tcpdump, mitmproxy, Responder..."
    [ "$INSTALL_EXPLOITATION" == "1" ] && echo -e "   ✓ Exploitation: SET, searchsploit..."
    [ "$INSTALL_MOBILE" == "1" ] && echo -e "   ✓ Mobile: Frida, Apktool"
    echo ""
    echo -e "${YELLOW}📦 Tools directory: ~/tools/${NC}"
    echo -e "${GRAY}📄 Run failed packages manually: pkg install <name>${NC}"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 Subscribe: https://youtube.com/@TechJarves${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app first, then run start-hacklab.sh${NC}"
    echo ""
}

# ============== MAIN INSTALLATION ==============
main() {
    show_banner
    echo -e "${WHITE}  This script will install a complete Linux desktop with${NC}"
    echo -e "${WHITE}  hacking tools and GPU acceleration on your Android phone.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 20-60 minutes (depends on selected tools)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation, or Ctrl+C to cancel...${NC}"
    read
    
    # Run core steps
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
    
    # Show completion
    show_completion
}

# ============== RUN ==============
main
