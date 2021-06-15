#!/bin/bash

echo "Starting sshd service.."
cp /tmp/sshkey.pub /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys && chmod 0600 /root/.ssh/authorized_keys
echo '======== /etc/ssh/sshd_config ========'
cat /etc/ssh/sshd_config
echo '=========================================='
exec /usr/sbin/sshd -D
