#!/bin/bash

# Script for install all apps

set -e

if [ "$EUID" -ne 0 ]; then
    echo "--> Please run as root."
    exit 1
fi

SERVARR_APP_DIR=${SERVARR_APP_DIR:='/opt'}
SERVARR_CONF_DIR=${SERVARR_CONF_DIR:="/config"}
SERVARR_LOG_DIR=${SERVARR_LOG_DIR:="/var/log"}
 
TRANSMISSION_COMPLETED_DIR=${TRANSMISSION_COMPLETED_DIR:="/media/downloads/completed"}
TRANSMISSION_INCOMPLETED_DIR=${TRANSMISSION_INCOMPLETED_DIR:="/media/downloads/incompleted"}
 
RPC_PASSWORD=${RPC_PASSWORD:='transmission'}
RPC_USERNAME=${RPC_USERNAME:='transmission'}
RPC_AUTH_REQUIRED=${RPC_AUTH_REQUIRED:=true}

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
FLARESOLVERR_HOST=${FLARESOLVERR_HOST:="0.0.0.0"}
FLARESOLVERR_PROMETHEUS_ENABLED=${FLARESOLVERR_PROMETHEUS_ENABLED:="false"}
FLARESOLVERR_PROMETHEUS_PORT=${FLARESOLVERR_PROMETHEUS_PORT:="8192"}

JELLYFIN_DATA_DIR=${JELLYFIN_DATA_DIR:="$SERVARR_CONF_DIR/Jellyfin/data"}
JELLYFIN_CONFIG_DIR=${JELLYFIN_CONFIG_DIR:="$SERVARR_CONF_DIR/Jellyfin/config"}
JELLYFIN_CACHE_DIR=${JELLYFIN_CACHE_DIR:="$SERVARR_APP_DIR/Jellyfin/Cache"}
JELLYFIN_LOG_DIR=${JELLYFIN_LOG_DIR:="$SERVARR_CONF_DIR/Jellyfin"}

PACKAGES=(curl software-properties-common apt-transport-https gnupg nano wget nginx sqlite3 mediainfo libchromaprint-tools nginx-extras supervisor procps ca-certificates transmission-daemon unzip gettext-base chromium chromium-common chromium-driver xvfb dumb-init)

if [[ "$EXEC_TYPE" == "full" ]]; then
    echo "--> Update systeme..."
    apt-get -qq update
    for i in "${PACKAGES[@]}"; do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "--> installing $i"
            apt-get -y -qq install "$i"
        else
            echo "-->  $i already installed"
        fi
    done
    echo "--> Clean apt/lists..."
    rm -rf /var/lib/apt/lists/*
    apt-get -qq clean
    apt-get -qq autoremove -y
    echo "--> Create workspace $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "--> Create Workspace $SERVARR_APP_DIR"
    mkdir -p "$SERVARR_APP_DIR"
fi

function __set_app() {
    app=$1
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> Create log dir for $app_lower"
    mkdir -p "$SERVARR_LOG_DIR/$app_lower"
    echo "--> Autorisation $app in $SERVARR_APP_DIR/$app"
    chown "$USER_APP":"$USER_APP" -R "$SERVARR_APP_DIR/$app"
    "$SERVARR_APP_DIR/$app/$app" -nobrowser -data="$SERVARR_CONF_DIR/$app" &
    sleep 5s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$SERVARR_CONF_DIR/$app/config.xml"
    pkill -f "$SERVARR_APP_DIR/$app/$app"
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
        echo "--> Extract zip file $app_lower.zip in $SERVARR_APP_DIR/$app"
        unzip -qqo "$app_lower".zip -d "$SERVARR_APP_DIR/$app"
        echo "--> Delete $app_lower.zip"
        rm "$app_lower".zip
    else
        echo "--> Extract $app*.tar.gz"
        tar -xzf "$app"*.tar.gz
        echo "--> Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "--> Move $app $SERVARR_APP_DIR/"
        mv "$app" "$SERVARR_APP_DIR/"
    fi
    return
}

function Homer() {
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    if [[ "$EXEC_TYPE" == "full" ]]; then
        echo "--> Copie assets Homer"
        cp ./assets/** "$SERVARR_APP_DIR/Homer/assets"
        echo "--> Edit favicon Homer"
        cp ./assets/logo.png "$SERVARR_APP_DIR/Homer/assets/icons/favicon.ico"
    fi
    return
}

function FlareSolverr() {
    __get_app "flaresolverr" "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FLARESOLVERR_VERSION/flaresolverr_linux_x64.tar.gz" --content-disposition
    echo "--> Create log dir for flaresolverr"
    mkdir -p "$SERVARR_LOG_DIR/flaresolverr"
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
    echo "--> Import Jellyfin Media Server APT Repositories"
    curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg > /dev/null
    echo "--> Stable Jellyfin Version"
    echo "deb [arch=$( dpkg --print-architecture ) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/jellyfin.list
    echo "--> Updating APT repositories."
    apt update
    echo "--> Installing Jellyfin."
    apt install -qy jellyfin
    ln -s /usr/share/jellyfin/web/ /usr/lib/jellyfin/bin/jellyfin-web
}

# Performance optimization by parallelizing installations
Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &
Homer &
FlareSolverr &
Jellyfin &
wait

echo "--> Create Transmission log dir "
mkdir -p "$SERVARR_LOG_DIR/transmission"

echo "--> Script Ended"
exit 0
