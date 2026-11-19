# AI视觉点击 · Linux 桌面（Termux 版）

在安卓手机上跑一个真 Alpine Linux：Xfce 桌面 + VNC 查看，含完整 apk 包管理。

## 先说 Termux 为什么打不开

Termux **要求 Android 7.0 及以上**。Android 5/6 装上去点开就闪退，不是你操作的问题。
另外 **Google Play 上的 Termux 已停更且损坏**（装完直接闪退/解析失败），必须用 F-Droid 版。

- F-Droid 版直链（手机浏览器打开，允许“安装未知应用”）：
  `https://f-droid.org/repo/com.termux_118.apk`
- 装完先跑一次 `pkg update`，等它把基础包装好再动别的。

## 两种装法（第 2 种最省事）

### 1. 一键联网装

```bash
pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/xiongzu123456/ai-linux-desktop/main/install-desktop.sh -o ~/install-desktop.sh
bash ~/install-desktop.sh
```

### 2. 先下 rootfs，再本地导入（断点续传友好、不怕 Termux 网络抽风）

用手机浏览器/迅雷/任意下载器下对应架构的包（约 4MB），存到 **Download** 目录：

| 手机 CPU | 文件 | 直链 |
|---|---|---|
| arm64（近几年绝大多数） | alpine-minirootfs-3.21.3-aarch64.tar.gz | https://mirrors.aliyun.com/alpine/v3.21/releases/aarch64/alpine-minirootfs-3.21.3-aarch64.tar.gz |
| armeabi-v7a（老机） | alpine-minirootfs-3.21.3-armv7.tar.gz | https://mirrors.aliyun.com/alpine/v3.21/releases/armv7/alpine-minirootfs-3.21.3-armv7.tar.gz |
| x86_64（模拟器/平板） | alpine-minirootfs-3.21.3-x86_64.tar.gz | https://mirrors.aliyun.com/alpine/v3.21/releases/x86_64/alpine-minirootfs-3.21.3-x86_64.tar.gz |

官方源（镜像慢就换这个）：
`https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/<arch>/alpine-minirootfs-3.21.3-<arch>.tar.gz`

然后在 Termux：

```bash
pkg install -y proot tar
curl -fsSL https://raw.githubusercontent.com/xiongzu123456/ai-linux-desktop/main/install-from-file.sh -o ~/install-from-file.sh
bash ~/install-from-file.sh            # 自动在 Download 里找 alpine-minirootfs-*.tar.gz
# 或指定路径：bash ~/install-from-file.sh /sdcard/Download/alpine-minirootfs-3.21.3-aarch64.tar.gz
```

> 读 `/sdcard` 前先执行 `termux-setup-storage` 并在弹窗里允许存储权限。

### 3. 装完之后

```bash
bash ~/linux/enter.sh                        # 进 Linux 终端
bash ~/linux/enter.sh -c "apk add python3"   # 直接在里面跑一条命令
bash ~/start-desktop.sh                      # 起 Xfce 桌面 + VNC
```

VNC 客户端（bVNC / VNC Viewer）连 `127.0.0.1:5901`，无密码。

## 常见报错

| 现象 | 原因/处理 |
|---|---|
| Termux 点开闪退 | Android < 7，或装了 Play 版，换 F-Droid 版 |
| `proot: command not found` | `pkg install -y proot` |
| `apk: network error` / DNS 失败 | 进 Linux 后 `echo nameserver 223.5.5.5 > /etc/resolv.conf` 再 `apk update` |
| `tar: invalid tar magic` | rootfs 没下完（应 3-4MB），删掉重下 |
| 读 /sdcard 报 Permission denied | `termux-setup-storage` |
| 桌面卡 | 软渲染，6GB 内存以下別期待流畅 |

## 文件

- `install-desktop.sh` 一键联网装（下 rootfs + 解压 + 装 Xfce/VNC）
- `install-from-file.sh` 本地 rootfs 安装（离线可用，自动搜 Download）
- `start-desktop.sh` 启动 Xfce + x11vnc
- `manifest.json` 给 AI视觉点击 App 的元信息
