#!/bin/bash -e

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    python3 /usr/local/rucio/tools/merge_rucio_configs.py \
        -s /tmp/rucio.config.default.cfg $RUCIO_OVERRIDE_CONFIGS \
        --use-env \
        -d /opt/rucio/etc/rucio.cfg
fi

if [ ! -z "$RUCIO_PRINT_CFG" ]; then
    echo "=================== /opt/rucio/etc/rucio.cfg ============================"
    cat /opt/rucio/etc/rucio.cfg
    echo ""
fi

j2 /tmp/alembic.ini.j2 | sed '/^\s*$/d' > /opt/rucio/etc/alembic.ini

alembic init /opt/rucio/lib/rucio/db/sqla/migrate_repo/

alembic -c /opt/rucio/etc/alembic.ini upgrade head

python3 /tmp/bootstrap.py
