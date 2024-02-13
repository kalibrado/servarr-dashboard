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

############################################################
# Main program                                             #
############################################################
function run() {
    echo "--> $1"
    $1
}

run "mkdir -p $SERVARR_APP_DIR $SERVARR_CONF_DIR $SERVARR_LOG_DIR $SERVARR_TMP_DIR"


run "git clone --depth=1 https://github.com/kalibrado/servarr-dashboard $SERVARR_TMP_DIR/repo"

function nginx() {
    run "cp -R $SERVARR_TMP_DIR/repo/nginx/ /etc/nginx/"
    envsubst "$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR" < $SERVARR_TMP_DIR/repo/nginx/init-nginx.conf > /etc/nginx/nginx.conf
}

function transmission() {
    run "mkdir -p $SERVARR_CONF_DIR/Transmission $TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR"
    run "cp -R $SERVARR_TMP_DIR/repo/transmission/ $SERVARR_CONF_DIR/Transmission/"
    envsubst "$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD" < "$SERVARR_TMP_DIR/repo/transmission/init-settings.json" > "$SERVARR_CONF_DIR/Transmission/settings.json"
}

function fail2ban() {
    run "cp -R $SERVARR_TMP_DIR/repo/fail2ban/ /etc/fail2ban/"
}

function Homer() {
    run "cp -R $SERVARR_TMP_DIR/repo/assets/** $SERVARR_APP_DIR/Homer/assets"
    run "cp -R $SERVARR_TMP_DIR/repo/assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico"
}

Homer &
nginx &
transmission &
wait

run "cp $SERVARR_TMP_DIR/repo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf"
cd $SERVARR_LOG_DIR
run "mkdir -p $(cat /etc/supervisor/conf.d/supervisord.conf | grep logfile | cut -d "/" -f 2)"
cd -

run "/usr/bin/supervisord"
# sleep 30s
#tail -f $SERVARR_LOG_DIR/**/*.log || echo "tail -f $SERVARR_LOG_DIR/**/*.log  did not complete successfully"
