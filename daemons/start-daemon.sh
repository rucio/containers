#!/bin/sh

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

RUCIO_PYTHON_PATH=$(python3 -c "import os; import rucio; print(os.path.dirname(rucio.__file__))")

/usr/bin/memcached -u memcached -p 11211 -m 64 -c 1024 &

if [ "$RUCIO_DAEMON" == "hermes" ]
then
  echo "starting sendmail for $RUCIO_DAEMON"
  sendmail -bd
fi

if [ -d "/patch" ]
then
    echo "Patches found. Trying to apply them"

    TMP_PATCH_DIR="$(mktemp -d)"
    trap 'rm -rf -- "$TMP_PATCH_DIR"' EXIT # Deletes temp dir when script exits

    for patchfile in /patch/*.patch
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
            if patch -p3 -d "$RUCIO_PYTHON_PATH" < ${tmp_lib_file}
            then
                echo "Patch ${patchfile}/lib applied."
            else
                echo "Patch ${patchfile}/lib could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi
        fi
    done
fi

if [ -d /etc/grid-security/certificates ]; then
    echo 'Adding Grid CAs to the system trust.'
    cp -v /etc/grid-security/certificates/*.pem /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract
fi

echo "starting daemon with: $RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
echo ""

if [ -z "$RUCIO_ENABLE_LOGS" ]; then
    eval "exec /usr/bin/python3 /usr/local/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS"
else
    eval "exec /usr/bin/python3 /usr/local/bin/rucio-$RUCIO_DAEMON $RUCIO_DAEMON_ARGS >> /var/log/rucio/daemon.log 2>> /var/log/rucio/error.log"
fi
