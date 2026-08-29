# XG-040G-MD ImmortalWrt 云编译

本仓库用于 GitHub Actions 云编译 XG-040G-MD（Airoha EN7581）固件，
包含 LuCI + 中文语言包、Argon 主题、iStore、PassWall（xray-core/sing-box）、
OpenClash、Tailscale、Lucky、文件管理、终端(ttyd)，以及首次启动网络/防火墙配置脚本。

## 目录结构

```
.
├── .github/workflows/build-openwrt.yml   # Actions 工作流
├── diy-part1.sh                           # feeds update 之前：追加第三方 feed
├── diy-part2.sh                           # feeds install 之后：追加要勾选的包
├── .config                                # 你自己的基础配置（见下方说明，需自行补充）
└── files/etc/uci-defaults/
    └── 99-custom-firstboot.sh             # 首次启动网络/防火墙初始化脚本
```

## 使用步骤

### 1. 创建仓库
在 GitHub 新建一个空仓库（public 或 private 均可），把本文件夹里的内容原样上传/push 上去。

### 2. 补充 `.config`
仓库里**没有**包含完整 `.config`，因为它依赖你 XG-040G-MD 的具体
`CONFIG_TARGET_BOARD` / `CONFIG_TARGET_SUBTARGET` / `CONFIG_TARGET_PROFILE`
（这些你现有的编译环境里应该已经有）。做法：

1. 在你本地或已有的编译环境里，找到你现在能正常编译出 XG-040G-MD 固件的那份 `.config`，直接复制到本仓库根目录。
2. 不需要在这份 `.config` 里手动勾选本次要加的插件——`diy-part2.sh` 会在编译流程里自动追加，最后 `make defconfig` 会补全依赖。
3. 如果你本来就是用 `make menuconfig` 手工维护 `.config` 的，直接导出那份文件即可，不用改动。

### 3. 检查 `diy-part1.sh` / `diy-part2.sh` / `build-openwrt.yml`
- `build-openwrt.yml` 里的 `REPO_URL` / `REPO_BRANCH` 改成你实际使用的源码分支
  （比如你之前是基于某个特定 fork 或分支编译出默认那份精简包列表的，这里要保持一致，
  否则 `airoha-en7581-npu-firmware` 等目标专属包可能找不到）。
- `diy-part1.sh` 里的 PassWall / OpenClash / iStore / Lucky / 文件管理 feed 地址如果之后失效，
  去对应项目的 GitHub 页面确认最新地址后替换。

### 4. 首次启动脚本
`files/etc/uci-defaults/99-custom-firstboot.sh` 会在固件**首次开机**时自动执行一次
（执行成功后系统会自动删除该脚本，不会每次开机重复跑），内容就是我们前面修正过的版本：
- 正确清理默认 br-lan（避免 WAN 口 lan1 残留桥接进 LAN）
- 分离 WAN(lan1) / LAN(lan2-4)
- 设置 root 密码、时区、主机名
- 追加防火墙规则（IPv6 管理/VPN/转发）

如果要改 root 密码、LAN IP、放行端口，直接改这个文件里最上面的变量或防火墙规则部分即可。

### 5. 触发编译
- 手动触发：GitHub 仓库页面 → Actions → 选择 workflow → **Run workflow**。
- 也可以设置 push 触发（已在 workflow 里配置：改动 `.config` / `diy-part*.sh` / `files/**` 会自动触发一次）。

### 6. 下载固件
编译完成后，在对应的 Actions 运行记录页面下方 **Artifacts** 里下载
`XG-040G-MD-firmware.zip`，里面就是 `bin/targets/.../*` 下的 UBI 固件文件
（sysupgrade / factory 等，具体文件名取决于你的 DEVICE 定义）。

如果想让编译产物自动发布成 Release（方便长期保存、带版本号），
把 workflow 文件末尾 `发布到 Releases` 那一段取消注释，并在仓库
**Settings → Actions → General → Workflow permissions** 里勾选
"Read and write permissions"。

## 常见坑

- **编译超时**：GitHub Actions 免费额度单次 job 最长 6 小时，正常插件量级够用；如果加的插件非常多，建议开启 ccache 或拆分成多个 workflow。
- **磁盘空间不足**：workflow 里已经加了 `free-disk-space` 步骤清理 Android/.NET/Haskell 等预装工具，一般够用；如果还报 "No space left on device"，可以再加 `docker system prune` 之类的步骤。
- **feed 冲突**：如果 `./scripts/feeds install -a` 报某个包名冲突（比如 PassWall 和 PassWall2 都想装同名依赖），保留报错信息里提示的那个版本即可，不影响整体编译。
- **首次启动脚本没生效**：确认文件路径必须是 `files/etc/uci-defaults/99-xxx.sh` 且有可执行权限（`chmod +x`），并且文件名建议以两位数字开头（保证执行顺序）。
