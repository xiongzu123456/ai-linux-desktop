#!/data/data/com.termux/files/usr/bin/bash
# 启动 Xfce 桌面 + VNC（127.0.0.1:5901，无密码）
bash "$HOME/linux/enter.sh" -c '
  pkill Xvfb 2>/dev/null; pkill x11vnc 2>/dev/null
  Xvfb :1 -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &
  sleep 2
  DISPLAY=:1 xfce4-session >/tmp/xfce.log 2>&1 &
  sleep 2
  x11vnc -display :1 -forever -shared -nopw -listen 127.0.0.1 -rfbport 5901 >/tmp/vnc.log 2>&1 &
  echo "VNC 已启动 127.0.0.1:5901"
'
