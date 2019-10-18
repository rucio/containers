#!/bin/bash

/opt/rucio/etc/dashboards/import_dashboards.sh &

httpd -D FOREGROUND
