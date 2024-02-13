#!/bin/bash
WORKDIR=${WORKDIR:="/srv/servarr-dashboard"}
SERVARR_APP_DIR=${SERVARR_APP_DIR:="$WORKDIR/app"}
SERVARR_CONF_DIR=${SERVARR_CONF_DIR:="$WORKDIR/config"}
SERVARR_LOG_DIR=${SERVARR_LOG_DIR:="$WORKDIR/log"}
TRANSMISSION_COMPLETED_DIR=${TRANSMISSION_COMPLETED_DIR:="/media/downloads/completed"}
TRANSMISSION_INCOMPLETED_DIR=${TRANSMISSION_INCOMPLETED_DIR:="/media/downloads/incompleted"}
RPC_PASSWORD=${RPC_PASSWORD:='transmission'}
RPC_USERNAME=${RPC_USERNAME:='transmission'}
RPC_AUTH_REQUIRED=${RPC_AUTH_REQUIRED:=true}

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
path_file="$SERVARR_CONF_DIR/transmission"
envsubst '$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD' < "/repo/transmission/init-settings.json" > "$path_file/settings.json"

echo "--> Create $SERVARR_APP_DIR/homer"
mkdir -p "$SERVARR_APP_DIR/homer"
echo "--> Copie assets  $SERVARR_APP_DIR/homer/assets/"
cp -R /repo/assets/** $SERVARR_APP_DIR/homer/assets/
cp -R /repo/assets/servarr.png $SERVARR_APP_DIR/homer/assets/icons/favicon.ico

# Then run supervisord
/usr/bin/supervisord