#!/bin/bash

# Script for install all apps

set -e

if [ "$EUID" -ne 0 ]; then
    echo "--> Please run as root."
    exit 1
fi

SERVARR_APP_PATH=${SERVARR_APP_PATH:='/opt'}
SERVARR_CONFIG_PATH=${SERVARR_CONFIG_PATH:="/config"}
TRANSMISSION_DOWNLOADS_PATH=${TRANSMISSION_DOWNLOADS_PATH:="/media/downloads"}
USER_APP=${USER:='root'}
EXEC_TYPE=${1:="full"}

FLARESOLVERR_VERSION=${FLARESOLVERR_VERSION:="v3.3.13"}
FLARESOLVERR_LOG_LEVEL=${FLARESOLVERR_LOG_LEVEL:="info"}
FLARESOLVERR_LOG_HTML=${FLARESOLVERR_LOG_HTML:="false"}
FLARESOLVERR_CAPTCHA_SOLVER=${FLARESOLVERR_CAPTCHA_SOLVER:="none"}
FLARESOLVERR_TZ=${FLARESOLVERR_TZ:="UTC"}
FLARESOLVERR_LANG=${FLARESOLVERR_LANG:="none"}
FLARESOLVERR_HEADLESS=${FLARESOLVERR_HEADLESS:="true" }
FLARESOLVERR_BROWSER_TIMEOUT=${FLARESOLVERR_BROWSER_TIMEOUT:="40000" }
FLARESOLVERR_TEST_URL=${FLARESOLVERR_TEST_URL:="https://www.google.com"}
FLARESOLVERR_PORT=${FLARESOLVERR_PORT:="8191"}
FLARESOLVERR_HOST=$"FLARESOLVERR_HOST0.0.0{:=.0"}
FLARESOLVERR_PROMETHEUS_ENABLED=${FLARESOLVERR_PROMETHEUS_ENABLED:="false"}
FLARESOLVERR_PROMETHEUS_PORT=${FLARESOLVERR_PROMETHEUS_PORT:="8192"}

JELLYFIN_DATA_DIR=${JELLYFIN_DATA_DIR:="$SERVARR_CONFIG_PATH/Jellyfin"}
JELLYFIN_WEB_DIR=${JELLYFIN_WEB_DIR:="$SERVARR_APP_PATH/Jellyfin/Web"}
JELLYFIN_CACHE_DIR=${JELLYFIN_CACHE_DIR:="$SERVARR_APP_PATH/Jellyfin/Cache"}
JELLYFIN_LOG_DIR=${JELLYFIN_LOG_DIR:="$SERVARR_LOGS_PATH/Jellyfin"}
JELLYFIN_CONFIG_DIR=${JELLYFIN_CONFIG_DIR:="$SERVARR_CONFIG_PATH/Jellyfin"}

PACKAGES=(curl software-properties-common gnupg nano wget nginx sqlite3 mediainfo libchromaprint-tools nginx-extras supervisor procps ca-certificates transmission-daemon unzip gettext-base chromium  chromium-common chromium-driver xvfb dumb-init)

if [[ "$EXEC_TYPE" == "full" ]]; then
    echo "--> Update systeme..."
    apt-get -qq update
    for i in "${PACKAGES[@]}"; do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "--> installing $i ---"
            apt-get -y -qq install "$i"
        else
            echo "-->  $i already installed --- "
        fi
    done
    echo "--> Clean apt/lists..."
    rm -rf /var/lib/apt/lists/*
    apt-get -qq clean
    apt-get -qq autoremove -y
    echo "--> Create workspace $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "--> Create Workspace $SERVARR_APP_PATH"
    mkdir -p "$SERVARR_APP_PATH"
fi

function __set_app() {
    app=$1
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> Autorisation $app in $SERVARR_APP_PATH/$app"
    chown "$USER_APP":"$USER_APP" -R "$SERVARR_APP_PATH/$app"
    "$SERVARR_APP_PATH/$app/$app" -nobrowser -data="$SERVARR_CONFIG_PATH/$app" &
    sleep 5s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    sed -i "s|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    sed -i "s|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    pkill -f "$SERVARR_APP_PATH/$app/$app"
    return
}

function __get_app() {
    app=$1
    url=$2
    extra=$3
    typefile=$4
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> GET: $app "
    wget -q --show-progress --no-check-certificate "$extra" "$url"
    if [[ "$typefile" == "zipfile" ]]; then
        echo "--> Extract zip file $app_lower.zip in $SERVARR_APP_PATH/$app"
        unzip -qqo "$app_lower".zip -d "$SERVARR_APP_PATH/$app"
        echo "--> Delete $app_lower.zip"
        rm "$app_lower".zip
    else
        echo "--> Extract $app*.tar.gz"
        tar -xzf "$app"*.tar.gz
        echo "--> Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "--> Move $app $SERVARR_APP_PATH/"
        mv "$app" "$SERVARR_APP_PATH/"
    fi
    return
}

function Homer() {
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    if [[ "$EXEC_TYPE" == "full" ]]; then
        echo "--> Copie assets Homer"
        cp ./assets/** "$SERVARR_APP_PATH/Homer/assets"
        echo "--> Edit favicon Homer"
        cp ./assets/logo.png "$SERVARR_APP_PATH/Homer/assets/icons/favicon.ico"
    fi
    return
}

function FlareSolverr() {
    __get_app "flaresolverr" "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FLARESOLVERR_VERSION/flaresolverr_linux_x64.tar.gz" --content-disposition
    return 
}

function Readar() {
    __get_app "Readarr" 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Readarr"
    return
}

function Radarr() {
    __get_app "Radarr" 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Radarr"
    return
}

function Sonarr() {
    __get_app "Sonarr" 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Sonarr"
    return
}

function Lidarr() {
    __get_app "Lidarr" 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Lidarr"
    return
}

function Prowlarr() {
    __get_app "Prowlarr" 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Prowlarr"
    return
}

function Jellyfin() {
    echo "--> Add universe repository"
    add-apt-repository universe
    echo "--> Creating APT keyring directory."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg
    echo "--> Found old-style '/etc/apt/sources.list.d/jellyfin.list' configuration; removing it."
    rm -f /etc/apt/sources.list.d/jellyfin.list
    export VERSION_OS="$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release )"
    export VERSION_CODENAME="$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release )"
    export DPKG_ARCHITECTURE="$( dpkg --print-architecture )"
cat <<EOF | sudo tee /etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/${VERSION_OS}
Suites: ${VERSION_CODENAME}
Components: main
Architectures: ${DPKG_ARCHITECTURE}
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF
    echo "--> Updating APT repositories."
    apt update
    echo "--> Installing Jellyfin."
    apt install --yes jellyfin
    pkill -f jellyfin
}

Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &
Homer &
FlareSolverr &
Jellyfin &
wait

echo "--> Script Ended"
exit 0
