#!/bin/bash -e

j2 /tmp/00-mpm.conf.j2 > /etc/httpd/conf.modules.d/00-mpm.conf

echo "=================== /etc/httpd/conf.modules.d/00-mpm.conf ========================"
cat /etc/httpd/conf.modules.d/00-mpm.conf
echo ""

j2 /tmp/httpd.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf/httpd.conf

echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    python3 /usr/local/rucio/tools/merge_rucio_configs.py \
        -s /tmp/rucio.config.default.cfg $RUCIO_OVERRIDE_CONFIGS \
        --use-env \
        -d /opt/rucio/etc/rucio.cfg
fi

echo "=================== /opt/rucio/etc/rucio.cfg ============================"
cat /opt/rucio/etc/rucio.cfg
echo ""

j2 /tmp/rucio.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf.d/rucio.conf

echo "=================== /etc/httpd/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""

exec httpd -D FOREGROUND
