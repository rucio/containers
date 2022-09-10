#!/bin/bash -e

j2 /tmp/httpd.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf/httpd.conf

echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""


j2 /tmp/rucio.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf.d/rucio.conf

echo "=================== /etc/httpd/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""


if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
    python3 /usr/bin/tools/merge_rucio_configs.py \
        --use-env \
        -d /var/www/html/etc/rucio.cfg
fi

# echo "=================== /opt/rucio/etc/rucio.cfg ============================"
# cat /opt/rucio/etc/rucio.cfg
# echo ""

sleep infinity
exec httpd -D FOREGROUND