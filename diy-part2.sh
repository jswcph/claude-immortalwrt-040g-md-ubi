#!/bin/bash

set -e

echo "=========================================="
echo "DIY Part 2"
echo "=========================================="

echo "检查设备配置..."

if grep -q \
  '^CONFIG_TARGET_airoha_an7581_DEVICE_nokia_xg-040g-md-ubi=y$' \
  .config
then
    echo "XG-040G-MD-UBI 配置正确"
else
    echo "ERROR: XG-040G-MD-UBI 配置不存在"
    exit 1
fi

echo
echo "DIY Part 2 完成"
