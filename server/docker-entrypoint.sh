#!/bin/bash -e

j2 --customize=/tmp/j2cfg.py /tmp/00-mpm.conf.j2 > /etc/httpd/conf.modules.d/00-mpm.conf

echo "=================== /etc/httpd/conf.modules.d/00-mpm.conf ========================"
cat /etc/httpd/conf.modules.d/00-mpm.conf
echo ""

j2 --customize=/tmp/j2cfg.py /tmp/httpd.conf.j2 > /etc/httpd/conf/httpd.conf

echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    j2 --customize=/tmp/j2cfg.py /tmp/rucio.cfg.j2 > /opt/rucio/etc/rucio.cfg
fi

if [ ! -z "$RUCIO_PRINT_CFG" ]; then
    echo "=================== /opt/rucio/etc/rucio.cfg ============================"
    cat /opt/rucio/etc/rucio.cfg
    echo ""
fi

j2 --customize=/tmp/j2cfg.py /tmp/rucio.conf.j2 > /etc/httpd/conf.d/rucio.conf

echo "=================== /etc/httpd/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""

pkill httpd || :
sleep 2
httpd -D FOREGROUND
