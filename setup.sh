#!/bin/bash
set -e
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
# Variables                                                #
############################################################
WORKDIR=${WORKDIR:="/srv/servarr-dashboard"}
SERVARR_APP_DIR=${SERVARR_APP_DIR:="$WORKDIR/app"}
SERVARR_CONF_DIR=${SERVARR_CONF_DIR:="$WORKDIR/config"}
SERVARR_LOG_DIR=${SERVARR_LOG_DIR:="$WORKDIR/log"}
SERVARR_TMP_DIR=${SERVARR_TMP_DIR:="$WORKDIR/tmp"}
SERVARR_THEME=${SERVARR_THEME:="overseerr"}

TRANSMISSION_COMPLETED_DIR=${TRANSMISSION_COMPLETED_DIR:="/media/downloads/completed"}
TRANSMISSION_INCOMPLETED_DIR=${TRANSMISSION_INCOMPLETED_DIR:="/media/downloads/incompleted"}
RPC_PASSWORD=${RPC_PASSWORD:="transmission"}
RPC_USERNAME=${RPC_USERNAME:="transmission"}
RPC_AUTH_REQUIRED=${RPC_AUTH_REQUIRED:="true"}

packages="git fail2ban nano wget unzip curl apt-transport-https gettext-base nginx nginx-extras sqlite3 mediainfo libchromaprint-tools supervisor procps ca-certificates transmission-daemon"
############################################################
# Main program                                             #
############################################################
function run() {
    echo "--> $1"
    $1
} 
function __get_app() {
    cd "$SERVARR_TMP_DIR"
    app=${1^}
    url=$2
    run "wget -q --no-check-certificate $url -O $app.tar.gz"
    run "tar -xzf $app.tar.gz"
    run "rm $app.tar.gz"
    run "mv $app $SERVARR_APP_DIR/$app"
    cd -
    run "mkdir -p $SERVARR_LOG_DIR/$app"
    run "$SERVARR_APP_DIR/$app/$app -nobrowser -data=$SERVARR_CONF_DIR/$app > /dev/null &" &
    sleep 20s
    run "sed -i s|<UrlBase></UrlBase>|<UrlBase>/$app</UrlBase>|g $SERVARR_CONF_DIR/$app/config.xml"
    run "pkill -f $SERVARR_APP_DIR/$app/$app"
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
    cd "$SERVARR_TMP_DIR"
    run "wget -q --no-check-certificate https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" 
    run "mkdir -p $SERVARR_APP_DIR/Homer"
    run "unzip -qq homer.zip -d $SERVARR_APP_DIR/Homer"
    cd -
    run "cp -R ./assets/** $SERVARR_APP_DIR/Homer/assets" 
    run "cp -R ./assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico"
}

function nginx(){
   run "cp -R ./nginx/ /etc/nginx/" 
   envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < ./nginx/init-nginx.conf > /etc/nginx/nginx.conf
}

function transmission(){
    run "mkdir -p $SERVARR_CONF_DIR/Transmission $TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR"
    run "cp -R ./transmission/ $SERVARR_CONF_DIR/Transmission/"
    envsubst "$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD" < "./transmission/init-settings.json" > "$SERVARR_CONF_DIR/Transmission/settings.json"
}

function supervisord() {
    run "cp ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf"
    cd $SERVARR_LOG_DIR 
    run "mkdir -p $(cat /etc/supervisor/conf.d/supervisord.conf | grep logfile | cut -d "/" -f 2 )"
    cd -
}

function fail2ban() {
    run "cp -R ./fail2ban/ /etc/fail2ban/"
}


function Install_All() {
    prowlarr 
    readarr 
    radarr 
    sonarr 
    lidarr 
    Homer 
    nginx 
    transmission 
    supervisord 
}

run "rm -rf $SERVARR_APP_DIR $SERVARR_CONF_DIR $SERVARR_LOG_DIR $SERVARR_TMP_DIR "
run "mkdir -p $SERVARR_APP_DIR $SERVARR_CONF_DIR $SERVARR_LOG_DIR $SERVARR_TMP_DIR"
run "apt-get -qq update"
run "apt-get -y -qq install ${packages} --no-install-recommends"
run "apt-get -qq autoremove -y"
Install_All 
wait

run "pkill -f $SERVARR_APP_DIR"