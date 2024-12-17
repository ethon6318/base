#!/bin/bash

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
   echo "该脚本必须以root权限运行" 1>&2
   exit 1
fi

# 设置root密码
echo "设置root密码"
passwd root

# 清空/root/.ssh/authorized_keys文件，以禁用SSH密钥认证
echo "清空/root/.ssh/authorized_keys文件"
> /root/.ssh/authorized_keys

# 确保/root/.ssh目录和文件的权限设置正确
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# 修改SSH配置文件，允许root登录和密码认证
echo "修改SSH配置"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 如果存在云服务商特定的配置文件，则修改或注释掉
if [ -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf ]; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
else
    # 如果没有云服务商特定的配置文件，则注释掉Include指令
    sed -i 's/^Include /etc/ssh/sshd_config.d\/\*.conf/#Include /etc/ssh/sshd_config.d\/\*.conf/' /etc/ssh/sshd_config
fi

# 重启SSH服务以应用更改
echo "重启SSH服务"
systemctl restart sshd

# 重启实例
echo "重启实例"
reboot
