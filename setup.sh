#!/bin/bash
cat <<EOF
#-------------------------------------------------------------------------------------------------------------------------#
#   _____   ___  ____   __ __   ____  ____   ____          ___     ____   _____ __ __  ____    ___    ____  ____   ___    #
#  / ___/  /  _]|    \ |  |  | /    ||    \ |    \        |   \   /    | / ___/|  |  ||    \  /   \  /    ||    \ |   \   #
# (   \_  /  [_ |  D  )|  |  ||  o  ||  D  )|  D  ) _____ |    \ |  o  |(   \_ |  |  ||  o  )|     ||  o  ||  D  )|    \  #
#  \__  ||    _]|    / |  |  ||     ||    / |    / |     ||  D  ||     | \__  ||  _  ||     ||  O  ||     ||    / |  D  | #
#  /  \ ||   [_ |    \ |  :  ||  _  ||    \ |    \ |_____||     ||  _  | /  \ ||  |  ||  O  ||     ||  _  ||    \ |     | #
#  \    ||     ||  .  \ \   / |  |  ||  .  \|  .  \       |     ||  |  | \    ||  |  ||     ||     ||  |  ||  .  \|     | #
#   \___||_____||__|\_|  \_/  |__|__||__|\_||__|\_|       |_____||__|__|  \___||__|__||_____| \___/ |__|__||__|\_||_____| #
#                                  ____   __ __          __  _   ____  _      ____  ____   ____    ____  ___     ___      #
#                                 |    \ |  |  |        |  |/ ] /    || |    |    ||    \ |    \  /    ||   \   /   \     #
#                                 |  o  )|  |  |        |  ' / |  o  || |     |  | |  o  )|  D  )|  o  ||    \ |     |    #
#                                 |     ||  ~  |        |    \ |     || |___  |  | |     ||    / |     ||  D  ||  O  |    #
#                                 |  O  ||___, |        |     \|  _  ||     | |  | |  O  ||    \ |  _  ||     ||     |    #
#                                 |     ||     |        |  .  ||  |  ||     | |  | |     ||  .  \|  |  ||     ||     |    #
#                                 |_____||____/         |__|\_||__|__||_____||____||_____||__|\_||__|__||_____| \___/     #
#-------------------------------------------------------------------------------------------------------------------------#
EOF
############################################################
# Need root for running this                               #
############################################################
if [ "$EUID" -ne 0 ]; then
    echo "--> Please run as root."
    exit 1
fi
############################################################
# Variables                                                #
############################################################
WORKDIR=${WORKDIR:="/srv/servarr-dashboard"}
SERVARR_APP_DIR=${SERVARR_APP_DIR:="$WORKDIR/app"}
SERVARR_CONF_DIR=${SERVARR_CONF_DIR:="$WORKDIR/config"}
SERVARR_LOG_DIR=${SERVARR_LOG_DIR:="$WORKDIR/log"}
SERVARR_THEME=${SERVARR_THEME:="overseerr"}
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
user_app=${USER:='root'}
packages=(
    git fail2ban nano wget unzip curl apt-transport-https gettext-base
    nginx nginx-extras sqlite3 mediainfo libchromaprint-tools 
    supervisor procps ca-certificates transmission-daemon 
    chromium chromium-common chromium-driver xvfb dumb-init 
)
############################################################
# Main program                                             #
############################################################
function __set_app() {
    app=${1^} # first char uppercase 
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> Create $SERVARR_LOG_DIR/$app_lowe"
    mkdir -p "$SERVARR_LOG_DIR/$app_lower"
    echo "--> Autorisation $app in $SERVARR_APP_DIR/$app_lower"
    chown "$user_app":"$user_app" -R "$SERVARR_APP_DIR/$app_lower"
    "$SERVARR_APP_DIR/$app_lower/$app" -nobrowser -data="$SERVARR_CONF_DIR/$app_lower" >/dev/null &
    sleep 5s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$SERVARR_CONF_DIR/$app_lower/config.xml"
    pkill -f "$SERVARR_APP_DIR/$app_lower/$app"
}
function __get_app() {
    app=$1 # first char uppercase 
    url=$2
    extra=$3
    typefile=$4
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> Donwload $app "
    wget -q --show-progress --no-check-certificate "$extra" "$url"
    if [[ "$typefile" == "zipfile" ]]; then
        echo "--> Extract zip file $app_lower.zip in $SERVARR_APP_DIR/$app_lower"
        unzip -qqo "$app_lower".zip -d "$SERVARR_APP_DIR/$app_lower"
        echo "--> Delete $app_lower.zip"
        rm "$app_lower".zip
    else
        echo "--> Extract $app*.tar.gz"
        tar -xzf "$app"*.tar.gz
        echo "--> Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "--> Move $app $SERVARR_APP_DIR/$app_lower"
        mv "$app" "$SERVARR_APP_DIR/$app_lower"
    fi
}
function flareSolverr() {
    __get_app "flaresolverr" "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FLARESOLVERR_VERSION/flaresolverr_linux_x64.tar.gz"
}
function homer() {
    echo "--> Create $SERVARR_APP_DIR/homer"
    mkdir -p "$SERVARR_APP_DIR/homer"
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
}
function readarr() {
    __get_app "Readarr" 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "readarr"
}
function radarr() {
    __get_app "Radarr" 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "radarr"
}
function sonarr() {
    __get_app "Sonarr" 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "sonarr"
}
function lidarr() {
    __get_app "Lidarr" 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "lidarr"
}
function prowlarr() {
    __get_app "Prowlarr" 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "prowlarr"
}

function Install_All() {
    echo "--> Install all apps"
    prowlarr &
    readarr &
    radarr &
    sonarr &
    lidarr &
    homer &
    flareSolverr &
    wait
}
function start() {
    echo "--> Create $SERVARR_APP_DIR"
    mkdir -p "$SERVARR_APP_DIR"

    echo "--> Update systeme"
    apt-get -qq update

    echo "--> Install packages ${packages[@]}"
    apt-get -y -qq install "${packages[@]}" --no-install-recommends

    echo "--> Autoremove"
    apt-get -qq autoremove -y

    Install_All 

    echo "--> Clone repo for last update"
    git clone --depth=1 https://github.com/kalibrado/servarr-dashboard /repo

    echo "--> Copie config Nginx"
    cp -R /repo/nginx/ /etc/nginx/

    echo "--> Copie config fail2ban"
    cp -R /repo/fail2ban/ /etc/fail2ban/

    echo "--> Copie supervisord.conf"
    cp /repo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

    echo "--> Create $SERVARR_APP_DIR"
    mkdir -p $SERVARR_APP_DIR
    echo "--> Create $SERVARR_CONF_DIR"
    mkdir -p $SERVARR_CONF_DIR

    echo "--> Create $SERVARR_LOG_DIR"
    mkdir -p $SERVARR_LOG_DIR
    echo "--> Create $SERVARR_LOG_DIR/prowlarr"
    mkdir -p $SERVARR_LOG_DIR/prowlarr 
    echo "--> Create $SERVARR_LOG_DIR/radarr"
    mkdir -p $SERVARR_LOG_DIR/radarr 
    echo "--> Create $SERVARR_LOG_DIR/sonarr"
    mkdir -p $SERVARR_LOG_DIR/sonarr
    echo "--> Create $SERVARR_LOG_DIR/lidarr"
    mkdir -p $SERVARR_LOG_DIR/lidarr
    echo "--> Create $SERVARR_LOG_DIR/readarr"
    mkdir -p $SERVARR_LOG_DIR/readarr
    echo "--> Create $SERVARR_LOG_DIR/transmission"
    mkdir -p $SERVARR_LOG_DIR/transmission
    echo "--> Create $SERVARR_LOG_DIR/nginx"
    mkdir -p $SERVARR_LOG_DIR/nginx
    echo "--> Create $SERVARR_LOG_DIR/flaresolverr"
    mkdir -p $SERVARR_LOG_DIR/flaresolverr

    echo "--> Copie nginx conf.d  /etc/nginx/"
    cp -R /repo/nginx/** /etc/nginx/
    echo "--> Update Nginx conf"
    envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

    echo "--> Setup settings transmission"
    echo "--> Create $SERVARR_CONF_DIR/transmission"
    mkdir -p $SERVARR_CONF_DIR/transmission
    echo "--> Create $TRANSMISSION_COMPLETED_DIR "
    mkdir -p "$TRANSMISSION_COMPLETED_DIR"
    echo "--> Create $TRANSMISSION_INCOMPLETED_DIR"
    mkdir -p "$TRANSMISSION_INCOMPLETED_DIR"
    echo "--> Create $SERVARR_LOG_DIR/transmission"
    mkdir -p "$SERVARR_LOG_DIR/transmission"
    echo "--> Copie transmission config"
    cp -R /repo/transmission/ $SERVARR_CONF_DIR/transmission/
    envsubst '$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD' < "/repo/transmission/init-settings.json" > "$SERVARR_CONF_DIR/transmission/settings.json"

    echo "--> Create $SERVARR_APP_DIR/homer"
    mkdir -p "$SERVARR_APP_DIR/homer"
    echo "--> Copie assets  $SERVARR_APP_DIR/homer/assets/"
    cp -R /repo/assets/** $SERVARR_APP_DIR/homer/assets/
    cp -R /repo/assets/servarr.png $SERVARR_APP_DIR/homer/assets/icons/favicon.ico

    /usr/bin/supervisord

}

############################################################
# Start script                                             #
############################################################
start
