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
