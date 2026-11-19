#!/data/data/com.termux/files/usr/bin/bash
# 一键装桌面：下载 Alpine rootfs -> 解压 -> 装 Xfce + VNC。
# 已有 rootfs 想离线装：bash install-from-file.sh /sdcard/Download/alpine-minirootfs-xxx.tar.gz
set -u
VER_SHORT="${ALPINE_BRANCH:-v3.21}"
VER_FULL="${ALPINE_VER:-3.21.3}"
MIRROR="${ALPINE_MIRROR:-https://mirrors.aliyun.com/alpine}"
HERE="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

say() { printf '\n\033[1;36m%s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31m%s\033[0m\n' "$*"; exit 1; }

case "$(uname -m)" in
  aarch64|arm64) ARCH=aarch64 ;;
  armv7l|armv8l|arm) ARCH=armv7 ;;
  x86_64|amd64) ARCH=x86_64 ;;
  *) die "不支持的架构: $(uname -m)" ;;
esac
URL="$MIRROR/$VER_SHORT/releases/$ARCH/alpine-minirootfs-$VER_FULL-$ARCH.tar.gz"
say "架构 $ARCH"; say "rootfs: $URL"

command -v curl >/dev/null 2>&1 || pkg install -y curl || die "装 curl 失败"
command -v proot >/dev/null 2>&1 || pkg install -y proot || die "装 proot 失败"

mkdir -p "$HOME/linux"
TAR="$HOME/linux/.rootfs.tar.gz"
if [ -x "$HOME/linux/alpine/bin/sh" ]; then
  say "检测到已装好的 rootfs，跳过下载"
elif [ -f "$TAR" ] && [ "$(wc -c < "$TAR")" -gt 1000000 ]; then
  say "复用已下载的 $TAR"
else
  say "下载 rootfs（约 4MB）"
  curl -fL --progress-bar "$URL" -o "$TAR" || die "下载失败。换镜像：ALPINE_MIRROR=https://dl-cdn.alpinelinux.org/alpine bash $0"
fi

if [ ! -x "$HOME/linux/alpine/bin/sh" ]; then
  say "解压 rootfs"
  mkdir -p "$HOME/linux/alpine"
  proot --link2symlink tar -xzf "$TAR" -C "$HOME/linux/alpine" --no-same-owner >/dev/null 2>&1 \
    || tar -xzf "$TAR" -C "$HOME/linux/alpine" --no-same-owner >/dev/null 2>&1 \
    || die "解压失败，删掉 $TAR 重下"
  [ -x "$HOME/linux/alpine/bin/sh" ] || die "rootfs 不完整"
fi

cat > "$HOME/linux/enter.sh" <<EOS
#!/data/data/com.termux/files/usr/bin/bash
proot -0 --link2symlink -r "\$HOME/linux/alpine" -b /dev -b /proc -b /sys -b "\$HOME:/home/termux" -w /root \\
  /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=xterm-256color /bin/sh -l "\$@"
EOS
chmod +x "$HOME/linux/enter.sh"

say "安装桌面组件（首次 5-15 分钟）"
bash "$HOME/linux/enter.sh" -c "printf 'nameserver 223.5.5.5\nnameserver 8.8.8.8\n' > /etc/resolv.conf; apk update && apk add xorg-server xfce4 xfce4-terminal x11vnc xvfb dbus ttf-dejavu" \
  || say "apk 安装失败（多半 DNS/网络）：进 Linux 后手动 apk add xfce4 x11vnc xvfb"

cp -f "$HERE/start-desktop.sh" "$HOME/start-desktop.sh" 2>/dev/null || true
[ -x "$HOME/start-desktop.sh" ] || die "缺 start-desktop.sh，从仓库再下一次"

printf '\n\033[1;32m完成。\033[0m 桌面: bash ~/start-desktop.sh（VNC 连 127.0.0.1:5901）  终端: bash ~/linux/enter.sh\n'
