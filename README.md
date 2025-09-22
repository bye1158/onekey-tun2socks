# 给免费机一键添加Socks5 IPv4出口

## 更新日志
v1.1.1 更新Alice出口提示

v1.1.0 添加自定义出口节点配置功能

v1.0.9 过滤本地路由，防止回环

v1.0.8 无聊的重构

v1.0.7 下载tun2socks时使用自建DNS64/NAT64服务器，确保服务可控（仅Alice机型可用）

v1.0.6 无聊的更新（重构了一些函数）

v1.0.5 新增备用DNS64服务器组（@baipiaoking88）

v1.0.4 修复原先systemd中的错误，并在启用tun设备后增加1秒延时（@baipiaoking88）

v1.0.3 解决无IPv4的机子'RTNETLINK answers: Network is unreachable'报错（其实报错也无影响）

v1.0.2 更新Alice出口（移除香港机房IP）

## 快速开始

### 自定义sock5模式
```bash
curl -L https://raw.githubusercontent.com/hkfires/onekey-tun2socks/main/onekey-tun2socks.sh -o onekey-tun2socks.sh && chmod +x onekey-tun2socks.sh && sudo ./onekey-tun2socks.sh -i custom
```

### 以下命令适用于Alice的纯IPv6免费机
```bash
curl -L https://raw.githubusercontent.com/hkfires/onekey-tun2socks/main/onekey-tun2socks.sh -o onekey-tun2socks.sh && chmod +x onekey-tun2socks.sh && sudo ./onekey-tun2socks.sh -i alice
```

> 注意事项：有IPv4的Alice机型使用Alice家宽Socks5出口时，需手动修改DNS（建议使用Alice V6的解锁DNS），由于家宽IP不在Alice V4 DNS的白名单内，会导致解析失败；机房Socks5出口不受此影响。

### 以下命令适用于LegendVPS的纯IPv6免费机（出口可能已失效）
```bash
curl -L https://raw.githubusercontent.com/hkfires/onekey-tun2socks/main/onekey-tun2socks.sh -o onekey-tun2socks.sh && chmod +x onekey-tun2socks.sh && sudo ./onekey-tun2socks.sh -i legend
```

### 卸载
```bash
curl -L https://raw.githubusercontent.com/hkfires/onekey-tun2socks/main/onekey-tun2socks.sh -o onekey-tun2socks.sh && chmod +x onekey-tun2socks.sh && sudo ./onekey-tun2socks.sh -r
```

## 手动下载运行

1. 下载脚本：
```bash
curl -L https://raw.githubusercontent.com/hkfires/onekey-tun2socks/main/onekey-tun2socks.sh -o onekey-tun2socks.sh
```

2. 添加执行权限：
```bash
chmod +x onekey-tun2socks.sh
```

3. 查看帮助信息：
```bash
./onekey-tun2socks.sh -h
```

4. 运行脚本：
```bash
# 安装 Alice 版本
sudo ./onekey-tun2socks.sh -i alice

# 安装 Legend 版本（出口可能已失效）
sudo ./onekey-tun2socks.sh -i legend

# 变更 Alice 出口
sudo ./onekey-tun2socks.sh -s

# 检查更新
sudo ./onekey-tun2socks.sh -u

# 卸载
sudo ./onekey-tun2socks.sh -r
```

## 服务管理

安装完成后，可以使用以下命令管理服务：

```bash
# 查看服务状态
systemctl status tun2socks.service

# 启动服务
systemctl start tun2socks.service

# 停止服务
systemctl stop tun2socks.service

# 重启服务
systemctl restart tun2socks.service

# 查看日志
journalctl -u tun2socks.service
```
## alpine
使用方法

下载脚本：

curl -L -o onekey-tun2socks.sh <脚本URL>
chmod +x onekey-tun2socks.sh


安装 tun2socks 并配置 custom 节点：

```bash
curl -L https://raw.githubusercontent.com/bye1158/onekey-tun2socks/main/alpine-tun2socks.sh -o alpine-tun2socks.sh && chmod +x alpine-tun2socks.sh && sudo ./alpine-tun2socks.sh -i custom
```


安装时会提示输入 Socks5 地址/端口/用户名/密码

会生成 /etc/tun2socks/config.yaml 和 OpenRC 服务 /etc/init.d/tun2socks

OpenRC 会自动加入默认 runlevel，开机自动启动

启动 / 停止服务：

sudo ./onekey-tun2socks.sh -s  # 启动
sudo ./onekey-tun2socks.sh -k  # 停止


卸载：

sudo ./onekey-tun2socks.sh -r


