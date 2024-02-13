
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
TRANSMISSION_COMPLETED_DIR=${TRANSMISSION_COMPLETED_DIR:="/media/downloads/completed"}
TRANSMISSION_INCOMPLETED_DIR=${TRANSMISSION_INCOMPLETED_DIR:="/media/downloads/incompleted"}
RPC_PASSWORD=${RPC_PASSWORD:="transmission"}
RPC_USERNAME=${RPC_USERNAME:="transmission"}
RPC_AUTH_REQUIRED=${RPC_AUTH_REQUIRED:="true"}
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
user_app=${USER:="root"}
packages=(
    git fail2ban nano wget unzip curl apt-transport-https gettext-base
    nginx nginx-extras sqlite3 mediainfo libchromaprint-tools 
    supervisor procps ca-certificates transmission-daemon
)
############################################################
# Main program                                             #
############################################################

function __get_app() {
    app=${1^}
    url=$2
    echo "--> wget -q --no-check-certificate $url -O $app.tar.gz"
    wget -q --no-check-certificate $url -O $app.tar.gz
    echo "--> tar -xzf $app.tar.gz"
    tar -xzf $app.tar.gz
    echo "--> rm $app.tar.gz"
    rm $app.tar.gz
    echo "--> mv $app $SERVARR_APP_DIR/$app"
    mv $app $SERVARR_APP_DIR/$app
    echo "--> mkdir -p $SERVARR_LOG_DIR/$app"
    mkdir -p "$SERVARR_LOG_DIR/$app"
    "$SERVARR_APP_DIR/$app/$app" -nobrowser -data="$SERVARR_CONF_DIR/$app" >/dev/null &
    sleep 10s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app</UrlBase>|g" "$SERVARR_CONF_DIR/$app/config.xml"
    pkill -f "$SERVARR_APP_DIR/$app/$app"
}
function readarr() {
    __get_app "Readarr" "http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64"
}
function radarr() {
    __get_app "Radarr" "http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"
}
function sonarr() {
    __get_app "Sonarr" "http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64"
}
function lidarr() {
    __get_app "Lidarr" "http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"
}
function prowlarr() {
    __get_app "Prowlarr" "http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"
}
function Homer(){
    echo "--> wget -q --no-check-certificate https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip"
    wget -q --no-check-certificate https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
    echo "--> unzip -qq homer.zip -d  $SERVARR_APP_DIR/Homer"
    unzip -qq homer.zip -d  $SERVARR_APP_DIR/Homer
}
function Install_All() {
    prowlarr &
    readarr &
    radarr &
    sonarr &
    lidarr &
    Homer &
}

echo "--> mkdir -p $SERVARR_APP_DIR"
mkdir -p "$SERVARR_APP_DIR"

echo "--> apt-get -qq update"
apt-get -qq update

echo "--> apt-get -y  -qq install ${packages[@]} --no-install-recommends"
apt-get -y -qq install "${packages[@]}" --no-install-recommends

echo "--> apt-get -qq autoremove -y"
apt-get -qq autoremove -y
Install_All 
wait