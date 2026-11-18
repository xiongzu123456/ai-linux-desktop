# ai-linux-desktop

给「AI视觉点击」App 用的 Linux 桌面环境安装包（Termux + proot-distro + Alpine + Xfce + VNC）。

安卓上跑完整 Linux 桌面，实际做法分两层：

1. **容器层**：Termux 里的 `proot-distro` 装一个 Alpine，里面有完整包管理（`apk add`）。
2. **桌面层**：Alpine 里跑 `Xvfb` 虚拟屏 + `x11vnc`，安卓端用任意 VNC 客户端连 `127.0.0.1:5901` 就能看到 Xfce 桌面。

## 需要先装

- Termux：从 F-Droid 或 GitHub Releases 装（不要用 Play 商店的老版本）
  下载页：https://f-droid.org/packages/com.termux/
- VNC 客户端（任选）：bVNC / RealVNC Viewer / MultiVNC
- 手机剩余空间：建议 3 GB 以上
- 网络：安装过程要下约 200-400 MB 包

## Termux 里必须打开的两个开关

1. 长按 Termux 终端 → `More` → `Settings` → 打开 **Allow external applications**（允许外部调用，App 才能一键触发安装）
2. 执行一次 `termux-setup-storage`（可选，给文件访问权限）

## 一键安装（App 里点按钮即可）

App 的「设置 → Linux 环境 → 一键安装」会通过 Termux 的 RUN_COMMAND 执行 `install-desktop.sh`。
也可以自己在 Termux 里手动跑：

```bash
curl -fsSL https://raw.githubusercontent.com/xiongzu123456/ai-linux-desktop/main/install-desktop.sh -o ~/install-desktop.sh
bash ~/install-desktop.sh
```

安装脚本做的事：

- `pkg update`
- 装 `proot-distro`
- `proot-distro install alpine`
- 在 Alpine 里 `apk add xfce4 xfce4-terminal xvfb x11vnc dbus font-noto-cjk ttf-dejavu`
- 生成 `~/start-desktop.sh`

## 启动桌面

```bash
bash ~/start-desktop.sh
```

然后用 VNC 客户端连 **127.0.0.1:5901**（Alpine 里 VNC 只监听本机，不对外网开放）。

## 已知限制

- 无 GPU 加速，纯 CPU 渲染，界面会偏卡（建议手机 6GB 内存以上）
- 中文需要 `font-noto-cjk`，脚本已装；个别应用仍可能缺字
- VNC 默认无密码、只监听 localhost，不要在公共 Wi-Fi 上改成对外监听
- Xfce 里跑浏览器/IDE 会吃内存，建议先用 `htop`/`free -h` 看一下余量
- 安卓 12 以上的「应用休眠/后台限制」可能杀掉 Termux，需在电池设置里放行

## 许可

脚本自用随意。