#!/bin/sh

UUID="$(cat /proc/sys/kernel/random/uuid)"

sed -i "s|uuid|${UUID}|g" /etc/xray/config.json

# Xray latest release version
RELEASE_LATEST=''

# Two very important variables
TMP_DIRECTORY="$(mktemp -d)"
ZIP_FILE="${TMP_DIRECTORY}/web.zip"


get_latest_version() {
    # Get latest release version number
    RELEASE_LATEST="$(curl -IkLs -o ${TMP_DIRECTORY}/NUL -w %{url_effective} https://github.com/XTLS/Xray-core/releases/latest | grep -o "[^/]*$")"
    RELEASE_LATEST="v${RELEASE_LATEST#v}"
    if [[ -z "$RELEASE_LATEST" ]]; then
        echo "error: Failed to get the latest release version, please check your network."
        exit 1
    fi
}

download_xray() {
    DOWNLOAD_LINK="https://github.com/XTLS/Xray-core/releases/download/$RELEASE_LATEST/Xray-linux-64.zip"
    if ! wget -qO "$ZIP_FILE" "$DOWNLOAD_LINK"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    return 0
    if ! wget -qO "$ZIP_FILE.dgst" "$DOWNLOAD_LINK.dgst"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    if [[ "$(cat "$ZIP_FILE".dgst)" == 'Not Found' ]]; then
        echo 'error: This version does not support verification. Please replace with another version.'
        return 1
    fi

    # Verification of Xray archive
    for LISTSUM in 'md5' 'sha1' 'sha256' 'sha512'; do
        SUM="$(${LISTSUM}sum "$ZIP_FILE" | sed 's/ .*//')"
        CHECKSUM="$(grep ${LISTSUM^^} "$ZIP_FILE".dgst | grep "$SUM" -o -a | uniq)"
        if [[ "$SUM" != "$CHECKSUM" ]]; then
            echo 'error: Check failed! Please check your network or try again.'
            return 1
        fi
    done
}

decompression() {
    unzip -q "$1" -d "$TMP_DIRECTORY"
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -ne 0 ]; then
        "rm" -r "$TMP_DIRECTORY"
        echo "removed: $TMP_DIRECTORY"
        exit 1
    fi
}

install_xray() {
    install -m 755 ${TMP_DIRECTORY}/xray /usr/local/xray/web
}

get_latest_version
download_xray
decompression "$ZIP_FILE"
install_xray

exec "$@"
