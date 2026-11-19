#!/data/data/com.termux/files/usr/bin/bash
# 用本地已下载的 Alpine rootfs 安装，完全不走网络。
# 用法: bash install-from-file.sh [rootfs.tar.gz 路径]
set -u

ROOT="$HOME/linux/alpine"
HIDE="$HOME/linux/.rootfs.tar.gz"
FILE=""

say() { printf '\n\033[1;36m%s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31m%s\033[0m\n' "$*"; exit 1; }

say "1/4 找 rootfs 压缩包"
if [ "${1:-}" != "" ] && [ -f "$1" ]; then
  FILE="$1"
else
  for d in "$HOME" "$HOME/storage/downloads" "/sdcard/Download" "/storage/emulated/0/Download"; do
    [ -d "$d" ] || continue
    for f in "$d"/alpine-minirootfs-*.tar.gz; do
      [ -f "$f" ] && FILE="$f" && break 2
    done
  done
fi
[ -n "$FILE" ] || die "没找到 alpine-minirootfs-*.tar.gz。先用浏览器把 rootfs 下到 Download 目录，或把路径作为参数传进来。"

SIZE=$(wc -c < "$FILE" | tr -d ' ')
[ "$SIZE" -gt 1000000 ] || die "文件太小（$SIZE 字节），可能没下完，重新下载一次。"
say "用: $FILE ($((SIZE/1024/1024)) MB)"

say "2/4 检查 proot / tar"
command -v proot >/dev/null 2>&1 || { pkg install -y proot || die "装 proot 失败"; }
command -v tar   >/dev/null 2>&1 || { pkg install -y tar   || die "装 tar 失败"; }

say "3/4 解压到 $ROOT"
mkdir -p "$ROOT" "$HOME/linux"
proot --link2symlink tar -xzf "$FILE" -C "$ROOT" --no-same-owner >/dev/null 2>&1 \
  || tar -xzf "$FILE" -C "$ROOT" --no-same-owner >/dev/null 2>&1 \
  || die "解压失败：文件可能损坏，重新下载。"
mv "$FILE" "$HIDE" 2>/dev/null || true
[ -x "$ROOT/bin/sh" ] || die "解压后没有 /bin/sh，rootfs 不完整。"

say "4/4 写启动脚本"
cat > "$HOME/linux/enter.sh" <<EOS
#!/data/data/com.termux/files/usr/bin/bash
proot -0 --link2symlink -r "$ROOT" -b /dev -b /proc -b /sys -b "\$HOME:/home/termux" -w /root \\
  /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \\
  TERM=xterm-256color LANG=C.UTF-8 /bin/sh -l "\$@"
EOS
chmod +x "$HOME/linux/enter.sh"

printf '\n\033[1;32m完成。\033[0m 进入 Linux:  bash ~/linux/enter.sh\n'
printf '装桌面（联网执行一次）: bash ~/linux/enter.sh -c "apk update && apk add xorg-server xfce4 xfce4-terminal x11vnc xvfb dbus ttf-dejavu"\n'
