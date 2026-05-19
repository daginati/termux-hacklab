# 📱 Mobile HackLab
### Run Linux Desktop with GPU Acceleration on Android (No Root!)
> Turn your Android phone into a powerful hacking machine with one command!
> 
![GPU](https://img.shields.io/badge/GPU-Accelerated-orange?style=for-the-badge)
![Root](https://img.shields.io/badge/Root-Not%20Required-brightgreen?style=for-the-badge)
---
## 🚀 One-Command Installation
Open **Termux** and paste this:
```bash
curl -sL https://raw.githubusercontent.com/daginati/termux-hacklab/main/install.sh | bash
```
**Or using wget:**
```bash
wget -O - https://raw.githubusercontent.com/daginati/termux-hacklab/main/install.sh | bash
```
---
## ✨ Features
| Feature | Description |
|---------|-------------|
| 🖥️ **Full Linux Desktop** | XFCE4 with Termux-X11 |
| 🎮 **GPU Acceleration** | Turnip/Zink drivers for smooth 60fps |
| 🔓 **No Root Required** | Works on ANY Android phone! |
| 🔧 **100+ Hacking Tools** | Nmap, Metasploit, SQLMap, Hydra |
| 🪟 **Windows Support** | Run `.exe` apps with Wine/Hangover |
| ⌨️ **Bluetooth Support** | Keyboard & mouse work perfectly |
| 📊 **Progress Bar** | See installation progress in real-time |
| 🔊 **Audio Support** | PulseAudio for sound |
---
## 🎮 GPU Acceleration - What Makes This Special
Unlike other guides that use **slow software rendering**, this installer sets up **real GPU acceleration**:
| Without GPU Accel | With GPU Accel (This Script) |
|-------------------|------------------------------|
| llvmpipe (CPU) | **Turnip Adreno (GPU)** |
| 15-20 FPS | **60 FPS** |
| Laggy desktop | **Smooth like PC** |
| High battery drain | **Efficient** |
**Supported GPUs:**
- ✅ Qualcomm Adreno (Snapdragon phones)
- ✅ Samsung Exynos (with Mali)
- ✅ MediaTek (software fallback)
---
## 📦 What Gets Installed
### 🖥️ Desktop Environment
- XFCE4 Desktop
- Thunar File Manager
- Firefox Browser
- VS Code Editor
### 🔧 Hacking Tools
| Category | Tools |
|----------|-------|
| **Network** | Nmap, Netcat, Whois, DNS tools |
| **Web** | SQLMap, Nikto |
| **Password** | Hydra, John the Ripper |
| **Exploitation** | Metasploit Framework |
### 🪟 Windows Support
- Wine Compatibility Layer
- Hangover (WowBox64)
- Direct `.exe` execution support
### 🎮 GPU Drivers
- Mesa Zink (OpenGL over Vulkan)
- Turnip (Adreno GPU driver)
- Vulkan Loader
---
## 🎬 Video Tutorial
[![Watch on YouTube](https://img.shields.io/badge/Watch%20Full%20Tutorial-YouTube-red?style=for-the-badge&logo=youtube)](https://youtu.be/4do18nhKc2k)
**Step-by-step guide on my YouTube channel!**
---
## 📸 Installation Preview
```
╔══════════════════════════════════════╗
║                                      ║
║   🚀  MOBILE HACKLAB v2.1  🚀       ║
║                                      ║
║             daginati                 ║
║                                      ║
╚══════════════════════════════════════╝
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 OVERALL PROGRESS: Step 11/13 ██████████████░░░ 84%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Step 11/13] Installing Wine (Windows Support)...
  ✓ Removing old Wine versions...
  ✓ Installing Wine Compatibility Layer...
  ⏳ Installing Box64 Wrapper... ⠹
```
---
## 🛠️ Usage
After installation, use these commands:
| Command | What it does |
|---------|--------------|
| `bash ~/start-hacklab.sh` | 🖥️ Start the desktop |
| `bash ~/hacktools.sh` | 🔧 Quick tools menu |
| `bash ~/stop-hacklab.sh` | 🛑 Stop the desktop |
---
## 📋 Requirements
| Requirement | Details |
|-------------|---------|
| **Android** | 7.0 or higher |
| **Termux** | [Download from GitHub](https://github.com/termux/termux-app/releases) (NOT Play Store!) |
| **Termux-X11** | [Download from GitHub](https://github.com/termux/termux-x11/releases) |
| **Storage** | ~4GB free space |
| **Internet** | Required for installation |
> ⚠️ **Important:** Download Termux from GitHub, NOT Play Store! The Play Store version is outdated.
---
## 💡 Pro Tips
1. **Disable Phantom Process Killer** in Developer Options for stability
2. **Use Bluetooth keyboard/mouse** for better experience
3. **Open Termux-X11 app FIRST** before running `start-hacklab.sh`
4. **Samsung DeX** works great with this setup!
---
## ⚠️ Disclaimer
```
This tool is for EDUCATIONAL PURPOSES ONLY.
Only use on systems you own or have explicit permission to test.
Unauthorized hacking is illegal.
The author is not responsible for any misuse.
```
Пошаговая инструкция

  ▎ Важно: если вы уже установили хак‑lab и он работает нестабильно, лучше полностью удалить старый набор пакетов, чтобы
  ▎  избежать конфликтов.

  ---
  1. Подготовка Termux

  # Обновляем базовые пакеты и ставим git (если его ещё нет)
  pkg update && pkg upgrade -y
  pkg install -y git

  2. Удаляем старую установку (опционально, но рекомендуется)

  # Если вы ранее запускали uninstall‑скрипт – запустите его ещё раз,
  # затем удалите оставшиеся каталоги и настройки.
  bash ~/uninstall-hacklaab.sh   # оригинальный uninstall‑скрипт из репо
  # Очистка остатков
  rm -rf ~/Desktop ~/start-hacklab.sh ~/hacktools.sh ~/stop-hacklab.sh \
         ~/.config/hacklab-gpu.sh \
         ~/.termux/boot/
  pkg remove -y xfce4 xfce4-terminal thunar mousepad \
                 termux-x11-nightly xorg-xrandr \
                 pulseaudio firefox code-oss git wget curl \
                 nmap netcat-openbsd whois dnsutils tracepath \
                 hydra john sqlmap metasploit \
                 hangover-wine hangover-wowbox64 wine \
                 mesa-zink mesa-vulkan-icd-freedreno mesa-vulkan-icd-swrast \
                 vulkan-loader-android
  # Очистка кэша пакетов (необязательно, но ускорит повторную установку)
  pkg clean

  3. Клонируем репозиторий (если ещё не сделали) и копируем исправленный скрипт

  # Переходим в удобную директорию, например в home
  cd ~
  # Если репозиторий уже cloned – просто переходим в него
  if [ ! -d termux-hacklab-main ]; then
      git clone https://github.com/daginati/termux-hacklab.git termux-hacklab-main
  fi
  cd termux-hacklab-main

  # Копируем исправленный скрипт в текущую директорию (он уже лежит рядом,
  # но на всякий случай проверяем)
  cp install_fixed.sh .
  chmod +x install_fixed.sh

  4. Запускаем установку

  ./install_fixed.sh

  Скрипт выведет цветной прогресс‑бар и спросит confirmation – нажмите Enter.

  ▎ Ожидайте 15‑30 минут (зависит от скорости интернета и мощности устройства).
  ▎ На этапах установки пакетов могут появляться сообщения типа “Package … is not available”; скрипт автоматически
  ▎ делает до 3 повторных попытки для таких пакетов (hydra, john, sqlmap, metasploit).

  5. Проверка после установки

  По завершении вы увидите сообщение INSTALLATION COMPLETE! и инструкции:

  - Запуск рабочего стола:
  bash ~/start-hacklab.sh
  - Быстрое меню инструментов:
  bash ~/hacktools.sh
  - Остановка desktop:
  bash ~/stop-hacklab.sh

  6. Первый запуск desktop

  1. Убедитесь, что вы установили Termux:X11 из F‑Droid или Play Market и запустили его (он должен показывать чёрный
  экран с надписью “Waiting for connection…”).
  2. В терминале Termux выполните:
  bash ~/start-hacklab.sh
  3. Переключитесь на приложение Termux:X11 ( свайпом слева или кнопкой “Show”) – вы увидите рабочее окружение XFCE4.
  4. Если вы не видите рабочего стола, попробуйте:
    - Выполнить pulseaudio --start вручную (аудио‑сервер иногда не стартует из‑за прав);
    - Проверить статус GPU:
    glxinfo | grep "renderer"
    - Должно показывать либо Turnip (для Adreno), либо llvmpipe (software). Если видите Software Rasterizer – значит
  GPU‑драйвер не загрузился; в этом случае desktop всё равно будет работать, но без ускорения OpenGL (это не критично
  для большинства инструментов).

  7. Что делать, если某些 пакеты всё‑ещё не установились

  Если после выполнения скрипта вы заметили, что, например, hydra или metasploit отсутствуют, просто установите их
  вручную:

  pkg install -y hydra john sqlmap metasploit

  (при необходимости повторить команду несколько раз – иногда зеркало временно не отвечает).

  8. Готово!

  Теперь у вас есть полностью рабочий Linux‑десктоп с набором инструментов для пентеста, запускаемый прямо в Termux
  через Termux:X11, без необходимости менять прошивку или root‑доступ к устройству.

  Если понадобится добавить дополнительные пакеты или изменить конфигурацию GPU – отредактируйте файл
  ~/.config/hacklab-gpu.sh (переменные MESA_GL_VERSION_OVERRIDE, GALLIUM_DRIVER и т.д.) и перезапустите desktop через
  ~/start-hacklab.sh.

  ---
