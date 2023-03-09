#!/bin/bash -e

echo "=================== Preparing renew_fts_proxy.sh ========================"

if [[ $RUCIO_VO == 'atlas' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_atlas.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'dteam' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_dteam.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'multi_vo' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_multi_vo.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'tutorial' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_tutorial.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
elif [[ $RUCIO_VO == 'escape' ]]
then
    j2 /opt/rucio/fts-delegate/renew_fts_proxy_escape.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
else
    j2 /opt/rucio/fts-delegate/renew_fts_proxy.sh.j2 > /opt/rucio/fts-delegate/renew_fts_proxy.sh
fi

chmod +x /opt/rucio/fts-delegate/renew_fts_proxy.sh

echo "=================== /renew_fts_proxy.sh ========================"
cat /opt/rucio/fts-delegate/renew_fts_proxy.sh
echo ""


if [ -z "$FETCH_CRL" -o "$FETCH_CRL" = "True" ]; then
    echo "=================== Updating certificate environment ========================"

    /usr/sbin/fetch-crl -v --define httptimeout=3 || true
fi

echo "=================== Delegating ========================"

/opt/rucio/fts-delegate/renew_fts_proxy.sh
