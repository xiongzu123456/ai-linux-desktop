#!/data/data/com.termux/files/usr/bin/bash
# Termux: 安装 Alpine + Xfce 桌面 + VNC
set -e

PKGS="xfce4 xfce4-terminal xvfb x11vnc dbus font-noto-cjk ttf-dejavu bash"

echo "[1/4] 更新 Termux 软件源"
pkg update -y
pkg install -y proot-distro

echo "[2/4] 安装 Alpine 容器（首次约 3-10 分钟）"
if proot-distro list | grep -q alpine; then
  echo "  alpine 已存在，跳过"
else
  proot-distro install alpine
fi

echo "[3/4] 在 Alpine 里安装 Xfce 与 VNC（首次约 5-20 分钟）"
proot-distro login alpine -- /bin/sh -c "apk update && apk add --no-cache $PKGS"

echo "[4/4] 生成启动脚本"
cat > "$HOME/start-desktop.sh" <<'START'
#!/data/data/com.termux/files/usr/bin/bash
# 启动 Alpine 桌面：Xvfb + Xfce + x11vnc（监听 127.0.0.1:5901）
echo "正在启动桌面..."
proot-distro login alpine -- /bin/sh -c '
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR
Xvfb :1 -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &
sleep 2
( dbus-launch --sh-syntax >/tmp/dbus.env 2>/dev/null; . /tmp/dbus.env 2>/dev/null; xfce4-session >/tmp/xfce.log 2>&1 & )
sleep 3
x11vnc -display :1 -forever -shared -nopw -rfbport 5901 -localhost -quiet >/tmp/vnc.log 2>&1 &
sleep 1
echo "VNC 就绪：127.0.0.1:5901（用 VNC 客户端连接）"
wait
'
START
chmod +x "$HOME/start-desktop.sh"

echo ""
echo "安装完成。"
echo "启动桌面：bash ~/start-desktop.sh"
echo "然后用 VNC 客户端连接 127.0.0.1:5901"
