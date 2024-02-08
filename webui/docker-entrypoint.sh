#!/bin/bash -e

if [ -f /opt/rucio/webui/.env ]; then
    echo "/opt/rucio/webui/.env already mounted."
else
        echo "/opt/rucio/webui/.env not found. will generate one."
    j2 /tmp/.env.default.j2 | sed '/^\s*$/d' > /opt/rucio/webui/.env
fi

echo "=================== /opt/rucio/webui/.env ========================"
cat /opt/rucio/webui/.env
echo ""

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

echo "=================== Starting RUCIO WEBUI ========================"
npm run start