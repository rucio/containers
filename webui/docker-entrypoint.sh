#!/bin/bash -e

log() {
    echo -e "\e[32m$(date -u) [rucio-webui] - $@\e[0m"
}

generate_env_file() {
    cd tools/env-generator && \

    npm install liquidjs && \
    npm run build && \
    chmod +x ./dist/generate-env.js && \
    ./dist/generate-env.js make prod ../../.env --write

    echo "Return code: $?"
    cd ../..
}

echo "=================== /opt/rucio/webui/.env ==================="
if [ -f /opt/rucio/webui/.env ]; then
    log "/opt/rucio/webui/.env already mounted."
else
    log "/opt/rucio/webui/.env not found. Will generate one now."
    generate_env_file
fi
cat /opt/rucio/webui/.env
echo ""

log "Building Apache configuration files."
j2 /tmp/httpd.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf/httpd.conf
echo "=================== /etc/httpd/conf/httpd.conf ========================"
cat /etc/httpd/conf/httpd.conf
echo ""

j2 /tmp/rucio.conf.j2 | sed '/^\s*$/d' > /etc/httpd/conf.d/rucio.conf
echo "=================== /etc/httpd/conf/conf.d/rucio.conf ========================"
cat /etc/httpd/conf.d/rucio.conf
echo ""

log "removing httpd example ssl config"
rm -rf /etc/httpd/conf.d/ssl.conf

if [ -d "/patch" ]
then
    echo "=================== Apply Patches ==================="
    log "Patches found. Trying to apply them"
    for patchfile in /patch/*
    do
        echo "Applying patch ${patchfile}"
        
        tmp_bin_file="${TMP_PATCH_DIR}/tmp_bin"

        if ! filterdiff -i '*/bin/*' "${patchfile}" > ${tmp_bin_file}; then
            echo "Error while filtering patch ${patchfile}/bin. Exiting setup."
            exit 1
        fi

        if [ -s ${tmp_bin_file} ]
        then
            if patch -p2 -d "/usr/local/bin/" < ${tmp_bin_file}
            then
                echo "Patch ${patchfile}/bin applied."
            else
                echo "Patch ${patchfile}/bin could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi
        fi

        tmp_lib_file="${TMP_PATCH_DIR}/tmp_lib"

        if ! filterdiff -i '*/lib/*' "${patchfile}" > ${tmp_lib_file}; then
            echo "Error while filtering patch ${patchfile}/lib. Exiting setup."
            exit 1
        fi

        if [ -s ${tmp_lib_file} ]
        then
            if patch -p3 -d "$RUCIO_WEBUI_PATH" < ${tmp_lib_file}
            then
                echo "Patch ${patchfile}/lib applied."
            else
                echo "Patch ${patchfile}/lib could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi
        fi
    done
fi

log "Building Rucio WebUI"
npm run build

log "Starting Rucio WebUI"
pm2 start
sleep 2
exec httpd -D FOREGROUND
echo "=================== RUCIO WEBUI started ==================="
