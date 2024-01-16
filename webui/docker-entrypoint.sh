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
    for patchfile in /patch/*
    do
        echo "Applying patch ${patchfile}"
        
        bin_patch=$(filterdiff -i '*/bin/*' ${patchfile})

        if [ -n "$bin_patch" ]
        then
            if patch -p3 -d "$RUCIO_WEBUI_PATH" < $bin_patch
            then
                echo "Patch ${bin_patch} applied."
            else
                echo "Patch ${bin_patch} could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi            

        lib_patch=$(filterdiff -i '*/lib/*' ${patchfile})

        if [ -n "$lib_patch" ]
        then
            if patch -p3 -d "$RUCIO_WEBUI_PATH" < $lib_patch
            then
                echo "Patch ${lib_patch} applied."
            else
                echo "Patch ${lib_patch} could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi            
    done
fi


echo "=================== Starting RUCIO WEBUI ========================"
npm run start