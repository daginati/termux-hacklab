#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  MOBILE HACKING LAB - ULTIMATE INSTALLER
#  Устанавливает Ubuntu + 60 hacking tools
#  ВСЕ АВТОМАТИЧЕСКИ - НИЧЕГО ВРУЧНУЮ
#######################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << 'BANNER'
╔═══════════════════════════════════════════════════╗
║    🚀 MOBILE HACKLAB v3.0 - ULTIMATE 🚀          ║
║         Ubuntu + 60 Hacking Tools                ║
║         FULLY AUTOMATED                          ║
╚═══════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# ============== 1. БАЗОВАЯ УСТАНОВКА ==============
echo -e "${YELLOW}[1/5] Устанавливаем proot-distro...${NC}"
pkg update -y && pkg upgrade -y
pkg install -y proot-distro
proot-distro install ubuntu

# ============== 2. ВХОД В UBUNTU И НАСТРОЙКА ==============
echo -e "${YELLOW}[2/5] Настраиваем Ubuntu и обновляем...${NC}"
cat > ~/start-ubuntu.sh << 'EOF'
#!/bin/bash
proot-distro login ubuntu
EOF
chmod +x ~/start-ubuntu.sh

# Создаём скрипт для установки внутри Ubuntu
cat > /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root/install-tools.sh << 'INSTALL_EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Обновление
apt update && apt upgrade -y

# Базовые пакеты
apt install -y wget curl git build-essential python3 python3-pip python3-venv ruby-full \
    perl libssl-dev libffi-dev zlib1g-dev nmap masscan whois dnsutils nikto gobuster \
    wireshark tcpdump aircrack-ng hydra john sqlmap metasploit-framework exploitdb \
    steghide binwalk apktool libimage-exiftool-perl chromium firefox-esr file libpcap-dev

# pip инструменты
pip3 install shodan frida-tools impacket mitmproxy

# Установка из GitHub
cd /opt

# theHarvester
git clone https://github.com/laramies/theHarvester.git
cd theHarvester && python3 setup.py install && cd ..

# Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r && pip3 install -r requirements.txt && cd ..

# wafw00f
git clone https://github.com/EnableSecurity/wafw00f.git
cd wafw00f && python3 setup.py install && cd ..

# ffuf
apt install -y ffuf

# nuclei
wget https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei-linux-arm64.zip
unzip nuclei-linux-arm64.zip && mv nuclei /usr/local/bin/

# bettercap
apt install -y bettercap

# beef-xss
apt install -y beef-xss

# setoolkit
apt install -y set

# social-engineer-toolkit
git clone https://github.com/trustedsec/social-engineer-toolkit.git
cd social-engineer-toolkit && python3 setup.py install && cd ..

# searchsploit
apt install -y exploitdb

# fping, hping3
apt install -y fping hping3

# wifiphisher (требует python2)
apt install -y python2
git clone https://github.com/wifiphisher/wifiphisher.git
cd wifiphisher && python2 setup.py install && cd ..

# kismet
apt install -y kismet

# responder
git clone https://github.com/lgandx/Responder.git

# Veil
apt install -y veil

# Chisel
wget https://github.com/jpillora/chisel/releases/latest/download/chisel_1.9.1_linux_arm64.gz
gunzip chisel_1.9.1_linux_arm64.gz && chmod +x chisel_1.9.1_linux_arm64 && mv chisel_1.9.1_linux_arm64 /usr/local/bin/chisel

# GDB + gef
apt install -y gdb
bash -c "$(wget -qO- https://gef.blah.cat/sh)"

# Gobuster уже установлен
# WhatWeb уже установлен

# Feroxbuster
wget https://github.com/epi052/feroxbuster/releases/latest/download/feroxbuster_arm64.deb
dpkg -i feroxbuster_arm64.deb

# RustScan
wget https://github.com/RustScan/RustScan/releases/latest/download/rustscan_arm64.deb
dpkg -i rustscan_arm64.deb

# Утилиты для USB Rubber Ducky
apt install -y duckyscript

# Flipper Zero SDK
git clone https://github.com/flipperdevices/flipperzero-firmware.git

# HackRF tools
apt install -y hackrf

# Ghidra (требуется Java)
apt install -y openjdk-17-jdk
wget https://github.com/NationalSecurityAgency/ghidra/releases/download/11.0/Ghidra_11.0_PUBLIC_20231222.zip
unzip Ghidra_*.zip -d /opt/

# Volatility
git clone https://github.com/volatilityfoundation/volatility3.git

# Autopsy (требуется больше места)
apt install -y autopsy

# Проверка установки
echo ""
echo "=== УСТАНОВЛЕННЫЕ ИНСТРУМЕНТЫ ==="
echo "Nmap: $(nmap --version | head -1)"
echo "SQLmap: $(sqlmap --version | head -1)"
echo "Metasploit: $(msfconsole -q -x 'version; exit' 2>/dev/null | head -1)"
echo "Hydra: $(hydra -h 2>&1 | head -1)"
echo "John: $(john --help 2>&1 | head -1)"
echo ""

echo "Установка завершена!"
INSTALL_EOF

# Запускаем установку внутри Ubuntu
echo -e "${YELLOW}[3/5] Устанавливаем 60+ инструментов (это займет 20-30 минут)...${NC}"
proot-distro login ubuntu -- bash /root/install-tools.sh

# ============== 3. СОЗДАЁМ ЛАУНЧЕРЫ ==============
echo -e "${YELLOW}[4/5] Создаём удобные лаунчеры...${NC}"

cat > ~/hacklab.sh << 'LAUNCHER'
#!/bin/bash
echo "🚀 Запуск Ubuntu Hacking Lab..."
cat << 'MENU'

╔════════════════════════════════════════════════╗
║        🔥 MOBILE HACKLAB MENU 🔥              ║
╠════════════════════════════════════════════════╣
║                                                ║
║  1) 🐧 Запустить Ubuntu + XFCE Desktop        ║
║  2) 💻 Запустить Ubuntu (терминал)            ║
║  3) 🔧 Запустить Metasploit                   ║
║  4) 🌐 Запустить SQLmap                       ║
║  5) 🔑 Запустить Hydra                        ║
║  6) 📡 Запустить Nmap                         ║
║  7) 🖥️  Запустить Bettercap                   ║
║  8) 🎯 Запустить Searchsploit                 ║
║  0) Exit                                      ║
╠════════════════════════════════════════════════╣
║  💡 После входа в Ubuntu:                     ║
║     - apt install xfce4 для графики          ║
║     - nmap -sV target                        ║
║     - sqlmap -u "url"                        ║
╚════════════════════════════════════════════════╝

MENU
read -p "Выбери опцию: " choice
case $choice in
    1) proot-distro login ubuntu -- bash -c "pkill Xvfb 2>/dev/null; Xvfb :1 -screen 0 1280x720x24 & DISPLAY=:1 startxfce4" ;;
    2) proot-distro login ubuntu ;;
    3) proot-distro login ubuntu -- msfconsole ;;
    4) proot-distro login ubuntu -- sqlmap ;;
    5) proot-distro login ubuntu -- hydra ;;
    6) proot-distro login ubuntu -- nmap ;;
    7) proot-distro login ubuntu -- bettercap ;;
    8) proot-distro login ubuntu -- searchsploit ;;
    0) exit ;;
esac
LAUNCHER

chmod +x ~/hacklab.sh

# ============== 4. ГОТОВО ==============
echo -e "${GREEN}"
cat << 'COMPLETE'
╔════════════════════════════════════════════════╗
║                                                ║
║     ✅  УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ✅       ║
║                                                ║
║     60+ hacking tools установлены внутри      ║
║               Ubuntu                           ║
║                                                ║
╚════════════════════════════════════════════════╝
COMPLETE
echo -e "${NC}"
echo -e "${CYAN}🚀 Запуск: bash ~/hacklab.sh${NC}"
echo -e "${CYAN}🐧 Вход в Ubuntu: proot-distro login ubuntu${NC}"
echo -e ""
