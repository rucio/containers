#!/bin/bash -e

j2 /tmp/httpd.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf/httpd.conf

echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""


j2 /tmp/rucio.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf.d/rucio.conf

echo "=================== /etc/httpd/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""

j2 /tmp/.env.default.j2 | sed '/^\s*$/d' > /opt/rucio/webui/.env.default

if [ -f /opt/rucio/webui/.env ]; then
    echo "/opt/rucio/webui/.env already mounted."
else
    echo "/opt/rucio/webui/.env not found. will generate one."
    python3 /opt/rucio/merge_rucio_configs.py \
        -s /opt/rucio/webui/.env.default $RUCIO_OVERRIDE_CONFIGS \
        --use-env \
        -d /opt/rucio/webui/.env
fi

echo "=================== /opt/rucio/webui/.env ========================"
cat /opt/rucio/webui/.env
echo ""

npm run build
cp -rfn /opt/rucio/webui/build/* /var/www/html/
exec httpd -D FOREGROUND