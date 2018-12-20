#!/bin/bash -e

j2 /renew_fts_proxy.sh.j2 > /renew_fts_proxy.sh
chmod +x /renew_fts_proxy.sh

echo "=================== /renew_fts_proxy.sh ========================"
cat /renew_fts_proxy.sh
echo ""

/renew_fts_proxy.sh
