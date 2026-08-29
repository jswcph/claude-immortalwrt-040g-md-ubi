#!/bin/bash
# DIY-P1：在 ./scripts/feeds update 之前执行
# 作用：向 feeds.conf.default 追加官方源里没有的第三方插件源
# 当前工作目录：openwrt 源码根目录

# PassWall（含依赖包）
sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
sed -i '$a src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main' feeds.conf.default

# OpenClash
sed -i '$a src-git openclash https://github.com/vernesong/OpenClash.git;dev' feeds.conf.default

# iStore 商店
sed -i '$a src-git istore https://github.com/linkease/istore.git;main' feeds.conf.default
sed -i '$a src-git istore_lucky https://github.com/linkease/istore-lucky.git' feeds.conf.default

# Lucky
sed -i '$a src-git lucky https://github.com/sirpdboy/luci-app-lucky.git' feeds.conf.default

# 文件管理器
sed -i '$a src-git filemanager https://github.com/lisaac/luci-app-filemanager.git' feeds.conf.default

echo "=== feeds.conf.default 追加完成 ==="
tail -n 10 feeds.conf.default
