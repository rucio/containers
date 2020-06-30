#!/bin/bash -e

if [[ $RUCIO_VO == 'atlas' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_atlas.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'dteam' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_dteam.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'tutorial' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_tutorial.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
else
    j2 /opt/rucio/fts-delegate/renew_fts_proxy.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
fi

chmod +x /opt/rucio/fts-delegate/renew_fts_proxy.sh

echo "=================== /renew_fts_proxy.sh ========================"
cat /opt/rucio/fts-delegate/renew_fts_proxy.sh
echo ""

/opt/rucio/fts-delegate/renew_fts_proxy.sh
