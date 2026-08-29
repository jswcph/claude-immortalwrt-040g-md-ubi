#!/bin/bash

set -e

echo "=========================================="
echo "添加第三方 feeds"
echo "=========================================="

# ============================================================
# PassWall packages
# ============================================================

echo "添加 PassWall packages..."

cat >> feeds.conf.default <<'EOF'
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main
EOF

# ============================================================
# PassWall
# ============================================================

echo "添加 PassWall..."

cat >> feeds.conf.default <<'EOF'
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
EOF

# ============================================================
# OpenClash
# ============================================================

echo "添加 OpenClash..."

cat >> feeds.conf.default <<'EOF'
src-git openclash https://github.com/vernesong/OpenClash.git;dev
EOF

# ============================================================
# Lucky
# ============================================================

echo "添加 Lucky..."

cat >> feeds.conf.default <<'EOF'
src-git lucky https://github.com/sirpdboy/luci-app-lucky.git
EOF

# ============================================================
# File Manager
# ============================================================

echo "添加 File Manager..."

cat >> feeds.conf.default <<'EOF'
src-git filemanager https://github.com/lisaac/luci-app-filemanager.git
EOF

echo
echo "=========================================="
echo "当前 feeds.conf.default"
echo "=========================================="

tail -n 20 feeds.conf.default
