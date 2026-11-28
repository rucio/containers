#!/bin/bash -e

log() {
    echo -e "\e[32m$(date -u) [rucio-webui] - $*\e[0m"
}

export_webui_env() {
    # The WebUI reads plain variable names (RUCIO_HOST, OIDC_PROVIDERS, ...). Deployments
    # (docker run -e, the helm chart) pass them prefixed with RUCIO_WEBUI_, so strip the
    # prefix. Names of the container itself are skipped: RUCIO_WEBUI_PATH is the install
    # directory and RUCIO_WEBUI_HOSTNAME is only used below to derive the public URL.
    local name key
    for name in $(compgen -e | grep '^RUCIO_WEBUI_'); do
        key="${name#RUCIO_WEBUI_}"
        key="${key^^}"
        case "${key}" in
            PATH | HOSTNAME | HOME | PWD | SHELL | USER) continue ;;
        esac
        export "${key}=${!name}"
    done
}

derive_webui_env() {
    # Values the WebUI needs that are derived from the container configuration.
    if [ -z "${NEXT_PUBLIC_WEBUI_HOST}" ] && [ -n "${RUCIO_WEBUI_HOSTNAME}" ]; then
        if [ "${RUCIO_WEBUI_ENABLE_SSL,,}" = "true" ]; then
            export NEXT_PUBLIC_WEBUI_HOST="https://${RUCIO_WEBUI_HOSTNAME}"
        else
            export NEXT_PUBLIC_WEBUI_HOST="http://${RUCIO_WEBUI_HOSTNAME}"
        fi
    fi
    if [ -z "${NEXTAUTH_URL}" ] && [ -n "${NEXT_PUBLIC_WEBUI_HOST}" ]; then
        export NEXTAUTH_URL="${NEXT_PUBLIC_WEBUI_HOST}"
    fi
    export AUTH_TRUST_HOST="${AUTH_TRUST_HOST:-true}"
    export NODE_TLS_REJECT_UNAUTHORIZED="${NODE_TLS_REJECT_UNAUTHORIZED:-1}"
    # node only reads NODE_EXTRA_CA_CERTS when the process starts, so it has to be in the environment
    if [ -z "${NODE_EXTRA_CA_CERTS}" ] && [ -n "${SERVER_CA_BUNDLE}" ]; then
        export NODE_EXTRA_CA_CERTS="${SERVER_CA_BUNDLE}"
    fi
    if [ -z "${NEXTAUTH_SECRET}" ] && [ -z "${AUTH_SECRET}" ]; then
        log "WARNING: RUCIO_WEBUI_NEXTAUTH_SECRET is not set. Generating a random secret: sessions will not survive a restart and cannot be shared between replicas."
        export NEXTAUTH_SECRET="$(head -c 32 /dev/urandom | base64)"
    fi
}

wait_for_webui() {
    # The WebUI validates its configuration when it starts and exits when it is invalid.
    # pm2 would keep restarting it behind a running httpd, so stop the container instead.
    local i
    for i in $(seq 1 120); do
        if curl -s -o /dev/null http://localhost:3000/api/ping; then
            log "Rucio WebUI is up"
            return 0
        fi
        if pm2 jlist | grep -q '"status":"errored"'; then
            break
        fi
        sleep 1
    done
    log "ERROR: Rucio WebUI did not start. Its last log lines:"
    pm2 logs rucio-webui --nostream --lines 20 --err
    return 1
}

download_oidc_icons() {
    # OIDC provider icons are served locally so the WebUI can render them with
    # next/image. The WebUI derives the served path from the provider name
    # (public/oidc-icons/<NAME>.png, upper-cased) and only shows the icon when the
    # file exists, so here we just place the file. A failed download is non-fatal:
    # the WebUI falls back to its default icon.
    if [ -z "${RUCIO_WEBUI_OIDC_PROVIDERS}" ]; then
        return 0
    fi

    local icon_dir="/opt/rucio/webui/public/oidc-icons"
    mkdir -p "${icon_dir}"

    local name upper url_var url dest
    for name in $(echo "${RUCIO_WEBUI_OIDC_PROVIDERS}" | tr ',' ' '); do
        upper="$(echo "${name}" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
        [ -z "${upper}" ] && continue
        url_var="RUCIO_WEBUI_OIDC_PROVIDER_${upper}_ICON_URL"
        url="${!url_var}"
        [ -z "${url}" ] && continue

        dest="${icon_dir}/${upper}.png"
        log "Downloading OIDC icon for '${name}' from ${url}"
        # This is a low-priority, best-effort download, so cap every phase with
        # short timeouts and a single retry rather than relying on wget's
        # 900s default that would stall container startup on a bad URL.
        if ! wget -q --tries=2 --dns-timeout=5 --connect-timeout=5 --read-timeout=15 -O "${dest}" "${url}"; then
            log "WARNING: could not download OIDC icon for '${name}'; the WebUI will use the default icon"
            rm -f "${dest}"
        fi
    done
}

echo "=================== WebUI configuration ==================="
export_webui_env
if [ -f /opt/rucio/webui/.env ]; then
    # Exported variables take precedence over the .env file, so derive nothing on top of it
    log "/opt/rucio/webui/.env is mounted, it is read by the WebUI when it starts."
else
    derive_webui_env
fi
log "The configuration is validated when the WebUI starts; it refuses to start if it is invalid."
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

download_oidc_icons

if [ -z "${RUCIO_WEBUI_COMMUNITY_LOGO_URL}" ]; then
    log "Environment variable RUCIO_WEBUI_COMMUNITY_LOGO_URL is not set. The default experiment-icon will be used."
else
    log "Downloading community logo from ${RUCIO_WEBUI_COMMUNITY_LOGO_URL}"
    curl -fsSL -o /opt/rucio/webui/public/experiment-logo.png ${RUCIO_WEBUI_COMMUNITY_LOGO_URL}
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
                WEBUI_PATCHED=true
                echo "Patch ${patchfile}/lib applied."
            else
                echo "Patch ${patchfile}/lib could not be applied successfully (exit code $?). Exiting setup."
                exit 1
            fi
        fi
    done
fi

# The image ships a production build that reads its configuration at startup.
# Only patches to the WebUI source require building it again.
if [ "${WEBUI_PATCHED}" = "true" ]; then
    log "WebUI source was patched, rebuilding Rucio WebUI"
    npm install --include=dev
    npm run build
fi

log "Starting Rucio WebUI"
pm2 start
wait_for_webui
exec httpd -D FOREGROUND
echo "=================== RUCIO WEBUI started ==================="
