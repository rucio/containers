#! /bin/bash

mkdir -p /opt/rucio/etc/

if [ -f /opt/rucio/etc/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else
    echo "rucio.cfg not found. will generate one."
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

if [ ! -z "$RUCIO_USING_CRON" ]; then
  echo "Setting up and starting cron"
  cp /etc/cron.rucio/probes-crontab /etc/cron.d/
  crond -n -s
else
  cp /etc/jobber-config/dot-jobber.yaml /root/.jobber

  echo "Not using cron. Starting Jobber"
  /usr/local/libexec/jobbermaster &

  sleep 5

  echo
  echo "============= Jobber log file ============="

  tail -f /var/log/jobber-runs
fi
