#!/bin/bash
# DIY-P2：在 ./scripts/feeds install 之后、make defconfig 之前执行
# 作用：在已有 .config（保留你原来的 TARGET/SUBTARGET/DEVICE 选择）基础上，
# 追加本次要新增的 LuCI / 插件包。追加后 make defconfig 会自动补全依赖。
# 当前工作目录：openwrt 源码根目录

cat >> .config <<-EOF
# --- LuCI 主界面 + 汉化 ---
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-opkg-zh-cn=y

# --- Argon 主题 ---
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-i18n-argon-config-zh-cn=y

# --- iStore 商店 ---
CONFIG_PACKAGE_luci-app-store=y

# --- PassWall + 内核 ---
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_xray-plugin=y
CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_chinadns-ng=y
CONFIG_PACKAGE_ipt2socks=y
CONFIG_PACKAGE_tcping=y
CONFIG_PACKAGE_geoview=y
CONFIG_PACKAGE_v2ray-geoip=y
CONFIG_PACKAGE_v2ray-geosite=y

# --- OpenClash 及其依赖 ---
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_coreutils-nohup=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_unzip=y

# --- Tailscale ---
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-app-tailscale=y
CONFIG_PACKAGE_luci-i18n-tailscale-zh-cn=y

# --- Lucky ---
CONFIG_PACKAGE_luci-app-lucky=y
CONFIG_PACKAGE_luci-i18n-lucky-zh-cn=y

# --- 文件管理 + 终端 ---
CONFIG_PACKAGE_luci-app-filemanager=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y
EOF

echo "=== .config 包选择追加完成，等待 make defconfig 补全依赖 ==="
