#!/bin/bash
WORKDIR=${WORKDIR:="/srv/servarr-dashboard"}
SERVARR_APP_DIR=${SERVARR_APP_DIR:="$WORKDIR/app"}
SERVARR_CONF_DIR=${SERVARR_CONF_DIR:="$WORKDIR/config"}
SERVARR_LOG_DIR=${SERVARR_LOG_DIR:="$WORKDIR/log"}
cat << EOF
#-------------------------------------------------------------------------------------------------------------------------#
#   _____   ___  ____   __ __   ____  ____   ____          ___     ____   _____ __ __  ____    ___    ____  ____   ___    #
#  / ___/  /  _]|    \ |  |  | /    ||    \ |    \        |   \   /    | / ___/|  |  ||    \  /   \  /    ||    \ |   \   #
# (   \_  /  [_ |  D  )|  |  ||  o  ||  D  )|  D  ) _____ |    \ |  o  |(   \_ |  |  ||  o  )|     ||  o  ||  D  )|    \  #
#  \__  ||    _]|    / |  |  ||     ||    / |    / |     ||  D  ||     | \__  ||  _  ||     ||  O  ||     ||    / |  D  | #
#  /  \ ||   [_ |    \ |  :  ||  _  ||    \ |    \ |_____||     ||  _  | /  \ ||  |  ||  O  ||     ||  _  ||    \ |     | #
#  \    ||     ||  .  \ \   / |  |  ||  .  \|  .  \       |     ||  |  | \    ||  |  ||     ||     ||  |  ||  .  \|     | #
#   \___||_____||__|\_|  \_/  |__|__||__|\_||__|\_|       |_____||__|__|  \___||__|__||_____| \___/ |__|__||__|\_||_____| #
#                                                                                                                         #
#                                  ____   __ __          __  _   ____  _      ____  ____   ____    ____  ___     ___      #
#                                 |    \ |  |  |        |  |/ ] /    || |    |    ||    \ |    \  /    ||   \   /   \     #
#                                 |  o  )|  |  |        |  ' / |  o  || |     |  | |  o  )|  D  )|  o  ||    \ |     |    #
#                                 |     ||  ~  |        |    \ |     || |___  |  | |     ||    / |     ||  D  ||  O  |    #
#                                 |  O  ||___, |        |     \|  _  ||     | |  | |  O  ||    \ |  _  ||     ||     |    #
#                                 |     ||     |        |  .  ||  |  ||     | |  | |     ||  .  \|  |  ||     ||     |    #
#                                 |_____||____/         |__|\_||__|__||_____||____||_____||__|\_||__|__||_____| \___/     #
#-------------------------------------------------------------------------------------------------------------------------#
EOF

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

echo "--> Update Nginx conf"
wget -q https://raw.githubusercontent.com/kalibrado/servarr-dashboard/main/nginx/init-nginx.conf --no-check-certificate --content-disposition
envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

echo "--> Create $SERVARR_CONF_DIR/transmission"
mkdir -p $SERVARR_CONF_DIR/transmission

echo "--> Setup settings transmission"
path_file="$SERVARR_CONF_DIR/transmission"
wget -q https://raw.githubusercontent.com/kalibrado/servarr-dashboard/main/transmission/init-settings.json --no-check-certificate --content-disposition
envsubst '$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD' < "init-settings.json" > "$path_file/settings.json"

# Create log dirs and files
mkdir -p $( dirname $(cat /etc/supervisor/conf.d/supervisor.conf  | grep logfile= | grep "\.log" | sed s/.*logfile=// ) )
touch $( cat  /etc/supervisor/conf.d/supervisor.conf   | grep logfile= | grep "\.log" | sed s/.*logfile=// )

# Then run supervisord
/usr/bin/supervisord