#!/bin/bash
set -e

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'

require_root() {
    [ "$(id -u)" != "0" ] && { echo -e "${RED}请使用 root 权限运行${NC}"; exit 1; }
}

show_usage() {
    echo -e "${BLUE}用法:${NC} $0 [选项]"
    echo -e "  -i custom    安装 tun2socks（手动输入Socks5节点）"
    echo -e "  -r          卸载 tun2socks"
    echo -e "  -s          启动 tun2socks 后台运行"
    echo -e "  -k          停止后台运行的 tun2socks"
    echo -e "  -h          帮助"
}

cleanup_ip_rules() {
    echo -e "${BLUE}清理旧 IP 规则和 tun0 接口...${NC}"
    ip rule del fwmark 438 lookup main pref 10 2>/dev/null || true
    ip -6 rule del fwmark 438 lookup main pref 10 2>/dev/null || true
    ip route del default dev tun0 table 20 2>/dev/null || true
    ip rule del lookup 20 pref 20 2>/dev/null || true

    # 删除旧的 tun0 接口
    if ip link show tun0 >/dev/null 2>&1; then
        ip link set tun0 down
        ip link delete tun0
        echo -e "${GREEN}已删除旧的 tun0 接口${NC}"
    fi
}

uninstall_tun2socks() {
    cleanup_ip_rules
    pkill -f "/usr/local/bin/tun2socks" 2>/dev/null || true
    rm -rf /etc/tun2socks /usr/local/bin/tun2socks
    rm -f /etc/init.d/tun2socks
    rc-update del tun2socks default 2>/dev/null || true
    echo -e "${GREEN}卸载完成${NC}"
}

get_custom_server_config() {
    read -rp "Socks5 地址: " ADDR
    read -rp "Socks5 端口: " PORT
    read -rp "用户名(可空): " USER
    [ -n "$USER" ] && read -rp "密码(可空): " PASS
}

install_tun2socks() {
    cleanup_ip_rules
    mkdir -p /etc/tun2socks /usr/local/bin

    echo -e "${BLUE}请输入自定义Socks5节点信息${NC}"
    get_custom_server_config

    # 下载二进制
    curl -L -o /usr/local/bin/tun2socks \
        https://github.com/heiher/hev-socks5-tunnel/releases/latest/download/hev-socks5-tunnel-linux-x86_64
    chmod +x /usr/local/bin/tun2socks

    # 生成配置
    cat >/etc/tun2socks/config.yaml <<EOF
tunnel:
  name: tun0
  mtu: 8500
  multi-queue: true
  ipv4: 198.18.0.1

socks5:
  port: $PORT
  address: '$ADDR'
  udp: 'udp'
$( [ -n "$USER" ] && echo "  username: '$USER'" )
$( [ -n "$PASS" ] && echo "  password: '$PASS'" )
  mark: 438
EOF

    # 创建 OpenRC 服务脚本
    cat >/etc/init.d/tun2socks <<'EOF'
#!/sbin/openrc-run
name="tun2socks"
description="Tun2Socks Tunnel Service"
command="/usr/local/bin/tun2socks"
command_args="/etc/tun2socks/config.yaml"
pidfile="/run/tun2socks.pid"

depend() {
    need net
}

start_pre() {
    # 清理旧 IP 规则和 tun0
    ip rule del fwmark 438 lookup main pref 10 2>/dev/null || true
    ip -6 rule del fwmark 438 lookup main pref 10 2>/dev/null || true
    ip route del default dev tun0 table 20 2>/dev/null || true
    ip rule del lookup 20 pref 20 2>/dev/null || true
    if ip link show tun0 >/dev/null 2>&1; then
        ip link set tun0 down
        ip link delete tun0
    fi
}
EOF

    chmod +x /etc/init.d/tun2socks
    rc-update add tun2socks default

    echo -e "${GREEN}安装完成！使用 -s 启动 tun2socks 或开机自动启动${NC}"
}

start_tun2socks() {
    cleanup_ip_rules
    pkill -f "/usr/local/bin/tun2socks" 2>/dev/null || true
    /usr/local/bin/tun2socks /etc/tun2socks/config.yaml &
    echo $! > /var/run/tun2socks.pid
    echo -e "${GREEN}tun2socks 已后台启动，PID=$(cat /var/run/tun2socks.pid)${NC}"
}

stop_tun2socks() {
    if [ -f /var/run/tun2socks.pid ]; then
        kill "$(cat /var/run/tun2socks.pid)" 2>/dev/null || true
        rm -f /var/run/tun2socks.pid
        cleanup_ip_rules
        echo -e "${GREEN}tun2socks 已停止${NC}"
    else
        echo -e "${RED}未检测到 tun2socks 正在运行${NC}"
    fi
}

main() {
    require_root
    case "$1" in
        -i)
            if [ "$2" != "custom" ]; then
                echo -e "${RED}安装模式必须为 custom${NC}"
                exit 1
            fi
            install_tun2socks
            ;;
        -r) uninstall_tun2socks ;;
        -s) start_tun2socks ;;
        -k) stop_tun2socks ;;
        -h|"") show_usage ;;
        *) show_usage; exit 1 ;;
    esac
}

main "$@"
