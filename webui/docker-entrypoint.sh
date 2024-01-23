#!/bin/bash -e

log() {
    echo "$(date -u) [rucio-webui] - $@"
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

if [ -d "/patch" ]
then
    echo "=================== Apply Patches ==================="
    log "Patches found. Trying to apply them"
    for patchfile in /patch/*
    do
        echo "Applying patch ${patchfile}"
        
        tmp_bin_file="${TMP_PATCH_DIR}/tmp_bin"
        filterdiff -i '*/bin/*' "${patchfile}" > ${tmp_bin_file}

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
        filterdiff -i '*/lib/*' "${patchfile}" > ${tmp_lib_file}

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
    log "Rebuilding the Rucio WebUI after applying patches!"
    npm run build
fi

echo "=================== Starting RUCIO WEBUI ==================="
npm run start