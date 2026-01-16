#!/bin/bash -e

log() {
    echo -e "\e[32m$(date -u) [rucio-webui] - $*\e[0m"
}

generate_env_file() {
    cd tools/env-generator
    npm install

    log "Building env-generator (skipping lib checks to avoid parent node_modules conflicts)..."
    npx tsc --skipLibCheck && cp -rf src/templates dist/
    local build_exit=$?

    if [ $build_exit -ne 0 ]; then
        log "WARNING: Build had errors but checking if output exists..."
    fi

    if [ ! -f ./dist/generate-env.js ]; then
        log "ERROR: ./dist/generate-env.js was not created by build"
        cd ../..
        return 1
    fi

    chmod +x ./dist/generate-env.js
    log "Running env-generator..."
    node ./dist/generate-env.js make prod ../../.env --write
    local exit_code=$?
    echo "Return code: $exit_code"
    cd ../..
    return $exit_code
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

if [ -z "${RUCIO_WEBUI_COMMUNITY_LOGO_URL}" ]; then
    log "Environment variable RUCIO_WEBUI_COMMUNITY_LOGO_URL is not set. The default experiment-icon will be used."
else
    log "Downloading community logo from ${RUCIO_WEBUI_COMMUNITY_LOGO_URL}"
    wget -O /opt/rucio/webui/public/experiment-logo.png ${RUCIO_WEBUI_COMMUNITY_LOGO_URL}
fi

if [ -d "/patch" ]
then
    echo "=================== Apply Patches ==================="
    log "Patches found. Trying to apply them"

    TMP_PATCH_DIR="$(mktemp -d)"
    trap 'rm -rf -- "$TMP_PATCH_DIR"' EXIT # Deletes temp dir when script exits
    
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
            if patch -p2 -d "/opt/rucio/bin/" < ${tmp_bin_file}
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
