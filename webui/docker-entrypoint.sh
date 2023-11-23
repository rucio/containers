#!/bin/bash -e

if [ -f /opt/rucio/webui/.env ]; then
    echo "/opt/rucio/webui/.env already mounted."
else
        echo "/opt/rucio/webui/.env not found. will generate one."
    /opt/rucio/webui/tools/env-generator/dist/generate-env.js make prod /opt/rucio/webui/./.env --write
fi

echo "=================== /opt/rucio/webui/.env ========================"
cat /opt/rucio/webui/.env
echo ""

if [ -d "/patch" ]
then
    echo "Patches found. Trying to apply them"
    for patchfile in /patch/*
    do
        echo "Apply patch ${patchfile}"
        patch -p3 -d "$RUCIO_WEBUI_PATH" < $patchfile
    done
fi

echo "=================== Starting RUCIO WEBUI ========================"
npm run start