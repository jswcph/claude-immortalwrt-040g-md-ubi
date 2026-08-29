#!/bin/sh
# XG-040G-MD first boot setup (fixed version)
#
# lan1 = WAN
# lan2 = LAN
# lan3 = LAN
# lan4 = LAN

root_password="password"     # 建议刷机后立即手动修改，不要长期使用脚本里的明文密码
lan_ip_address="192.168.6.1"
hostname="OpenWrt"

exec >/tmp/setup.log 2>&1
echo "=== XG-040G-MD first boot setup ==="

# 1. 设置 root 密码
if [ -n "$root_password" ]; then
    printf '%s\n%s\n' "$root_password" "$root_password" | passwd root
fi

# 2. 网络配置
#
# 关键修复：默认模板里的 br-lan 通常是匿名 device 段（@device[0]），
# 不是名为 br_lan 的命名段，所以不能直接 `uci delete network.br_lan`，
# 否则旧的 br-lan(含 lan1) 依然存在，lan1(WAN) 会被残留桥接进 LAN。
# 这里按 name=br-lan 精确查找并删除，兼容匿名段和命名段。
for cfg in $(uci show network | grep "=device$" | cut -d'.' -f2 | cut -d'=' -f1); do
    if [ "$(uci -q get network.$cfg.name)" = "br-lan" ]; then
        uci delete network.$cfg
    fi
done

# 明确创建新的 br-lan（仅包含 lan2/3/4，不含 WAN 口 lan1）
uci set network.br_lan='device'
uci set network.br_lan.name='br-lan'
uci set network.br_lan.type='bridge'
uci add_list network.br_lan.ports='lan2'
uci add_list network.br_lan.ports='lan3'
uci add_list network.br_lan.ports='lan4'

# LAN
uci set network.lan='interface'
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$lan_ip_address"
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.ip6assign='60'

# WAN（默认接口名不变，避免影响默认 firewall zone 的 network 绑定）
uci -q delete network.wan
uci set network.wan='interface'
uci set network.wan.device='lan1'
uci set network.wan.proto='dhcp'

# WAN IPv6
uci -q delete network.wan6
uci set network.wan6='interface'
uci set network.wan6.device='lan1'
uci set network.wan6.proto='dhcpv6'

uci commit network

# 3. 系统名称
uci set system.@system[0].hostname="$hostname"
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'
uci commit system

# 4. 防火墙
#
# 不删除 OpenWrt 默认 firewall rules，只追加需要的规则。
# 建议：如果计划使用 Tailscale 做远程管理，
# 可以去掉下面 22/18080/18443 的 WAN 直连规则，改走 Tailscale 内网访问，
# 显著降低被扫描/爆破的风险。这里先保留，供你按需删减。

# IPv6 SSH / Web 管理（公网直连，注意安全加固：建议禁用密码登录改用密钥）
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-WAN-IPv6-Management'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_port='22 18080 18443'
uci set firewall.@rule[-1].target='ACCEPT'

# VPN
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-VPN-IPv6'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_port='52080'
uci set firewall.@rule[-1].target='ACCEPT'

# 内网转发端口
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-LAN-Forward-IPv6'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].dest_port='22 8006 8069 9090 18080 18443'
uci set firewall.@rule[-1].target='ACCEPT'

uci commit firewall

# 5. 应用网络配置
# device/bridge 成员发生变化时，reload 不一定完整生效，改用 restart 更保险
/etc/init.d/network restart

echo "=== Setup complete ==="
exit 0
