#!/bin/bash

while :
do
    curl -u admin:admin -X "GET" "http://grafana:3000/api/datasources" -s
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 5
done

curl -u admin:admin -X "POST" "http://grafana:3000/api/datasources" -H "Content-Type: application/json" --data-binary @/opt/rucio/etc/dashboards/grafana_datasrc.json
curl -u admin:admin -X "POST" "http://grafana:3000/api/dashboards/db" -H "Content-Type: application/json" --data-binary @/opt/rucio/etc/dashboards/grafana_dashb.json

while :
do
    status=$(curl -LI -X "GET" "http://kibana:5601/api/saved_objects" -o /dev/null -w '%{http_code}\n' -s)
    if [ $status -eq '404' ]; then
        break
    fi
    sleep 5
done

curl -X "POST" "http://kibana:5601/api/saved_objects/_import" -H "kbn-xsrf: true" --form file=@/opt/rucio/etc/dashboards/kibana.ndjson
