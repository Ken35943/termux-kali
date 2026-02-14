#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "🐲 Starting Kali NetHunter Desktop (Direct Mode)..."
echo ""

# 1. Check for NetHunter
if ! command -v nh &> /dev/null; then
    echo "❌ NetHunter (nh) not found!"
    echo "Please install it first: pkg install nethunter-termux"
    exit 1
fi

# 2. Check for XFCE inside NetHunter
echo "🔍 Checking for XFCE in NetHunter..."
# We try to run a simple check inside NH
if ! nh -r which xfce4-session &> /dev/null; then
    echo "⚠️  XFCE4 not found inside NetHunter!"
    echo "Installing XFCE4 in NetHunter now... (This might take a while)"
    echo "You might be asked for a password."
    nh -r -c "sudo apt update && sudo apt install -y xfce4 xfce4-goodies"
fi

# 3. Kill any existing sessions
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

# 4. === AUDIO SETUP (Same as HackLab) ===
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# 5. Start Termux-X11 server
echo "📺 Starting high-performance X11 display..."
termux-x11 :0 -ac &
sleep 3

# 6. Launch NetHunter Desktop
echo "🚀 Launching Kali XFCE..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see Kali!"
echo "  🐲 You are running a full Kali Linux Desktop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Pass environment variables to NetHunter
# We launch dbus-launch to ensure session bus is active
# Use explicit bash to avoid argument parsing issues
nh -r bash -c "export DISPLAY=:0 && export PULSE_SERVER=127.0.0.1 && dbus-launch --exit-with-session xfce4-session"

echo "🛑 Desktop stopped."
pkill -9 -f "termux.x11" 2>/dev/null
