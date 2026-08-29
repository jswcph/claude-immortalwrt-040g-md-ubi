#!/bin/bash
# 添加 Passwall 及其依赖源
echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' >> feeds.conf.default

# 添加 Argon 主题及配置插件源
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/downloads/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/downloads/luci-app-argon-config
