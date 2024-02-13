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
TRANSMISSION_COMPLETED_DIR=${TRANSMISSION_COMPLETED_DIR:="/media/downloads/completed"}
TRANSMISSION_INCOMPLETED_DIR=${TRANSMISSION_INCOMPLETED_DIR:="/media/downloads/incompleted"}
RPC_PASSWORD=${RPC_PASSWORD:='transmission'}
RPC_USERNAME=${RPC_USERNAME:='transmission'}
RPC_AUTH_REQUIRED=${RPC_AUTH_REQUIRED:=true}
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
exec_type="full"
Apps="all"
packages=(
    git fail2ban curl software-properties-common apt-transport-https
    nano wget nginx sqlite3 mediainfo libchromaprint-tools gettext-base
    nginx-extras supervisor procps ca-certificates transmission-daemon 
    chromium chromium-common chromium-driver xvfb dumb-init unzip
)
############################################################
# Help                                                    #
############################################################
Help() {
    echo "--------------------------------------------------------------"
    echo "Using the installation script to automate Servarr-Dashboard"
    echo "Syntax: setup.sh [-t|a|h]"
    echo "options:"
    echo "-t     The -t argument is the execution type: docker or full by default it is full "
    echo "-a     The -a argument supports a string of application to install separated by semicolons if it is not specified by default all"
    echo "-h     Print this Help."
    echo "Here is an example of using the script to install full and only the radarr and sonarr applications"
    echo "bash setup.sh -t full -a 'radarr;sonarr'"
}
############################################################
# Main program                                             #
############################################################
function __install_packages() {
    echo "--------------------------------------------------------------"
    arr=("$@")
    for i in "${arr[@]}"; do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "--> installing $i"
            apt-get -y -qq install "$i" >/dev/null
        else
            echo "  👌 $i already installed"
        fi
    done
}
function __set_app() {
    echo "--------------------------------------------------------------"
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
    echo "--------------------------------------------------------------"
    app=${1^} # first char uppercase 
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
function homer() {
    echo "--------------------------------------------------------------"
    echo "--> Create $SERVARR_APP_DIR/homer"
    mkdir -p "$SERVARR_APP_DIR/homer"
    __get_app "homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    echo "--> Copie assets  $SERVARR_APP_DIR/homer/assets/"
    cp /repo/assets/ $SERVARR_APP_DIR/homer/assets/
    cp /repo/assets/servarr.png $SERVARR_APP_DIR/homer/assets/icons/favicon.ico

}
function flareSolverr() {
    echo "--------------------------------------------------------------"
    __get_app "flaresolverr" "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FLARESOLVERR_VERSION/flaresolverr_linux_x64.tar.gz" --content-disposition
}
function readarr() {
    echo "--------------------------------------------------------------"
    __get_app "readarr" 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "readarr"
}
function radarr() {
    echo "--------------------------------------------------------------"
    __get_app "radarr" 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "radarr"
}
function sonarr() {
    echo "--------------------------------------------------------------"
    __get_app "sonarr" 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "sonarr"
}
function lidarr() {
    echo "--------------------------------------------------------------"
    __get_app "lidarr" 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "lidarr"
}
function prowlarr() {
    echo "--------------------------------------------------------------"
    __get_app "prowlarr" 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "prowlarr"
}
function transmission() {
    echo "--------------------------------------------------------------"
    echo "--> Create $TRANSMISSION_COMPLETED_DIR "
    mkdir -p "$TRANSMISSION_COMPLETED_DIR"
    echo "--> Create $TRANSMISSION_INCOMPLETED_DIR"
    mkdir -p "$TRANSMISSION_INCOMPLETED_DIR"
    echo "--> Create $SERVARR_LOG_DIR/transmission"
    mkdir -p "$SERVARR_LOG_DIR/transmission"
    echo "--> Copie transmission config"
    cp /repo/transmission/ $SERVARR_CONF_DIR/transmission/
}
function Install_All() {
    echo "--------------------------------------------------------------"
    echo "--> Install all apps"
    prowlarr &
    readarr &
    radarr &
    sonarr &
    lidarr &
    homer &
    flareSolverr &
    transmission &
    wait
}
function start() {
    echo "--------------------------------------------------------------"
    echo "--> Create $SERVARR_APP_DIR"
    mkdir -p "$SERVARR_APP_DIR"
    echo "--> Update systeme"
    apt-get -qq update
    echo "--> Install packages"
    __install_packages "${packages[@]}"
    echo "--> rm apt/lists/*"
    rm -rf /var/lib/apt/lists/*
    echo "--> Clean apt/lists"
    apt-get -qq clean
    echo "--> Autoremove"
    apt-get -qq autoremove -y
    echo "--> Clone repo for last update"
    git clone --depth=1 https://github.com/kalibrado/servarr-dashboard /repo
    echo "--> Copie config Nginx"
    cp -R /repo/nginx/ /etc/nginx/
    echo "--> Copie config fail2ban"
    cp -R /repo/fail2ban/ /etc/fail2ban/
    echo "--> Copie supervisord.conf"
    cp /repo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
    if [[ $Apps == "all" ]]; then
        Install_All
    else
        apps=$(echo "$Apps" | tr '[:upper:]' '[:lower:]')
        export IFS=";"
        for app in $apps; do
            $app
        done
    fi
    echo "--> Remove repo"
    rm -rf /repo
}
############################################################
# Process the input options.                               #
############################################################
while getopts ":h:t:a:" option; do
    case $option in
        h) # display Help
            Help
            exit
        ;;
        t)
            if [[ ("$OPTARG" == "docker" || "$OPTARG" == "full") ]]; then
                exec_type=$OPTARG
            else
                echo "😢 Error: Invalid exec_type value"
                exit 1
            fi
        ;;
        a)
            Apps=$OPTARG
        ;;
        \?)
            echo "😢 Error: Invalid option"
            exit
        ;;
    esac
done
############################################################
# Start script                                             #
############################################################
if [[ $Apps && $exec_type ]]; then
    start
else
    help
fi