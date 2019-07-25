#!/bin/bash -e

if [[ $RUCIO_VO == 'atlas' ]]
then
    j2 /renew_fts_proxy_atlas.sh.j2 > /renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'dteam' ]]
then
    j2 /renew_fts_proxy_dteam.sh.j2 > /renew_fts_proxy.sh
else
    j2 /renew_fts_proxy.sh.j2 > /renew_fts_proxy.sh
fi

chmod +x /renew_fts_proxy.sh

echo "=================== /renew_fts_proxy.sh ========================"
cat /renew_fts_proxy.sh
echo ""

/renew_fts_proxy.sh
