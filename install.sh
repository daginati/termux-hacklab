#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 MOBILE HACKING LAB - ULTIMATE v3.0
#  FULLY AUTOMATED - NO MANUAL INTERVENTION NEEDED
#######################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Функция для повторной установки с несколькими попытками
install_with_retry() {
    local pkg=$1
    local name=$2
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -e "${YELLOW}[Attempt $attempt/$max_attempts] Installing $name...${NC}"
        
        if yes | pkg install $pkg -y 2>&1 | tee -a /tmp/install.log; then
            # Проверяем, что пакет действительно установлен
            if pkg list-installed | grep -q "^$pkg\$"; then
                echo -e "${GREEN}✓ $name installed successfully${NC}"
                return 0
            fi
        fi
        
        echo -e "${RED}✗ Attempt $attempt failed for $name${NC}"
        attempt=$((attempt + 1))
        
        if [ $attempt -le $max_attempts ]; then
            echo -e "${YELLOW}Retrying in 3 seconds...${NC}"
            sleep 3
            # Очищаем кэш перед повторной попыткой
            pkg clean 2>/dev/null
        fi
    done
    
    echo -e "${RED}✗ FAILED to install $name after $max_attempts attempts${NC}"
    return 1
}

# Функция для установки из GitHub
install_github_with_retry() {
    local repo=$1
    local dir=$2
    local name=$3
    local max_attempts=2
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -e "${YELLOW}[Attempt $attempt/$max_attempts] Installing $name from GitHub...${NC}"
        
        (
            cd /tmp
            rm -rf $dir 2>/dev/null
            git clone --depth 1 https://github.com/$repo $dir 2>/dev/null
            if [ -d "$dir" ]; then
                cd $dir
                if [ -f "setup.py" ]; then
                    python setup.py install > /dev/null 2>&1
                elif [ -f "requirements.txt" ]; then
                    pip install -r requirements.txt > /dev/null 2>&1
                fi
                touch /tmp/${dir}_done
            fi
        )
        
        if [ -f "/tmp/${dir}_done" ]; then
            rm -f /tmp/${dir}_done
            echo -e "${GREEN}✓ $name installed${NC}"
            return 0
        fi
        
        echo -e "${RED}✗ Attempt $attempt failed for $name${NC}"
        attempt=$((attempt + 1))
        sleep 2
    done
    
    echo -e "${RED}✗ FAILED to install $name${NC}"
    return 1
}

# ФИКС 1: Очистка и настройка репозиториев
setup_repositories() {
    echo -e "${CYAN}[1/4] Fixing repositories...${NC}"
    
    # Очищаем всё
    pkg clean 2>/dev/null
    rm -rf $PREFIX/var/lib/dpkg/updates/* 2>/dev/null
    
    # Устанавливаем правильные репозитории
    yes | pkg update -y 2>/dev/null
    
    # Меняем репозитории на рабочие
    termux-change-repo << EOF
Y
1
2
EOF
    sleep 2
    
    # Обновляем с новыми репозиториями
    yes | pkg update -y 2>/dev/null
}

# ФИКС 2: Установка базовых зависимостей
install_base_deps() {
    echo -e "${CYAN}[2/4] Installing base dependencies...${NC}"
    
    local base_pkgs="python python-pip git wget curl openssl clang binutils"
    local success=true
    
    for pkg in $base_pkgs; do
        if ! install_with_retry $pkg $pkg; then
            success=false
        fi
    done
    
    # Обновляем pip
    python -m pip install --upgrade pip setuptools wheel 2>/dev/null
    
    if [ "$success" = "true" ]; then
        echo -e "${GREEN}✓ Base dependencies installed${NC}"
    else
        echo -e "${YELLOW}⚠ Some base packages had issues, continuing...${NC}"
    fi
}

# ФИКС 3: Установка GPU (MESA/ZINK/VULKAN) - ОСНОВНОЙ ФИКС
install_gpu() {
    echo -e "${CYAN}[3/4] Installing GPU acceleration (Mesa/Zink/Vulkan)...${NC}"
    
    # КРИТИЧЕСКИ ВАЖНО: правильный порядок установки
    local gpu_pkgs="vulkan-loader-android vulkan-headers mesa-zink virglrenderer-mesa-zink virglrenderer-android"
    
    for pkg in $gpu_pkgs; do
        install_with_retry $pkg $pkg
        sleep 1
    done
    
    # Проверка установки
    echo -e "${YELLOW}Verifying GPU installation...${NC}"
    pkg list-installed | grep -E "mesa|vulkan|virgl" || echo -e "${YELLOW}⚠ GPU packages status unknown${NC}"
}

# ФИКС 4: Установка hacking tools с повторными попытками
install_hacking_tools() {
    echo -e "${CYAN}[4/4] Installing hacking tools...${NC}"
    
    # 1. SQLmap - через pip (более стабильно)
    echo -e "${YELLOW}Installing SQLmap...${NC}"
    pip install sqlmap 2>/dev/null || {
        cd /tmp
        rm -rf sqlmap 2>/dev/null
        git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
        cd sqlmap
        python setup.py install 2>/dev/null
    }
    
    # 2. Hydra
    install_with_retry hydra "Hydra"
    
    # 3. John the Ripper
    install_with_retry john "John the Ripper"
    
    # 4. METASPLOIT - ОСНОВНОЙ ФИКС
    echo -e "${YELLOW}Installing Metasploit Framework...${NC}"
    
    # Метод 1: через тур-репо
    if pkg install metasploit -y 2>/dev/null; then
        echo -e "${GREEN}✓ Metasploit installed via pkg${NC}"
    else
        # Метод 2: через официальный скрипт
        echo -e "${YELLOW}Trying alternative Metasploit installation...${NC}"
        cd /tmp
        rm -rf metasploit-termux 2>/dev/null
        git clone https://github.com/gushmazuko/metasploit_in_termux.git
        cd metasploit_in_termux
        bash metasploit.sh 2>/dev/null
    fi
    
    # Дополнительные инструменты
    install_with_retry nmap "Nmap"
    install_with_retry wireshark "Wireshark"
    install_with_retry aircrack-ng "Aircrack-ng"
    install_with_retry gobuster "Gobuster"
    install_with_retry nikto "Nikto"
    install_with_retry exploitdb "Searchsploit"
}

# ФИКС 5: Настройка окружения
setup_environment() {
    echo -e "${CYAN}Setting up environment...${NC}"
    
    # Создаём GPU конфиг
    mkdir -p $HOME/.config
    cat > $HOME/.config/hacklab-gpu.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# GPU acceleration settings
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export ZINK_DESCRIPTORS=lazy
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
EOF
    chmod +x $HOME/.config/hacklab-gpu.sh
    
    # Добавляем в .bashrc
    if ! grep -q "hacklab-gpu.sh" $HOME/.bashrc 2>/dev/null; then
        echo "source \$HOME/.config/hacklab-gpu.sh" >> $HOME/.bashrc
    fi
    
    # Добавляем PATH для Python инструментов
    if ! grep -q "\.local/bin" $HOME/.bashrc 2>/dev/null; then
        echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc
    fi
}

# ФИКС 6: Проверка установки
verify_installation() {
    echo -e "${CYAN}Verifying installation...${NC}"
    
    local tools="sqlmap hydra john nmap"
    local all_ok=true
    
    for tool in $tools; do
        if command -v $tool >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $tool found${NC}"
        else
            echo -e "${RED}✗ $tool not found${NC}"
            all_ok=false
        fi
    done
    
    # Проверка Metasploit
    if [ -f "$PREFIX/bin/msfconsole" ] || [ -f "$PREFIX/bin/msfvenom" ]; then
        echo -e "${GREEN}✓ Metasploit found${NC}"
    else
        echo -e "${RED}✗ Metasploit not found${NC}"
        all_ok=false
    fi
    
    if [ "$all_ok" = "false" ]; then
        echo -e "${YELLOW}Some tools may need manual fix. Run: source ~/.bashrc${NC}"
    fi
}

# ОСНОВНОЙ ЗАПУСК
main() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════╗
    ║   🚀 MOBILE HACKLAB v3.0 - ULTIMATE 🚀  ║
    ║        FULLY AUTOMATED INSTALLER         ║
    ╚══════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    
    echo -e "${YELLOW}This script will install:${NC}"
    echo -e "  • GPU: Mesa, Zink, Vulkan Loader"
    echo -e "  • Tools: SQLmap, Hydra, John the Ripper, Metasploit"
    echo -e ""
    echo -e "${RED}No manual intervention needed!${NC}"
    echo -e "Press Enter to start..."
    read
    
    setup_repositories
    install_base_deps
    install_gpu
    install_hacking_tools
    setup_environment
    verify_installation
    
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔══════════════════════════════════════════╗
    ║         ✅ INSTALLATION DONE! ✅        ║
    ║                                          ║
    ║  Run: source ~/.bashrc                   ║
    ║  Then: sqlmap -h, hydra, msfconsole      ║
    ╚══════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
}

main
