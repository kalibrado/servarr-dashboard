#!/bin/bash
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
RPC_USERNAME=${RPC_USERNAME:='transmission'}
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


echo "--> Clone repo for last update"
git clone --depth=1 https://github.com/kalibrado/servarr-dashboard /repo >/dev/null

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
echo "--> Create $SERVARR_LOG_DIR/Prowlarr"
mkdir -p $SERVARR_LOG_DIR/Prowlarr 
echo "--> Create $SERVARR_LOG_DIR/Radarr"
mkdir -p $SERVARR_LOG_DIR/Radarr 
echo "--> Create $SERVARR_LOG_DIR/Sonarr"
mkdir -p $SERVARR_LOG_DIR/Sonarr
echo "--> Create $SERVARR_LOG_DIR/Lidarr"
mkdir -p $SERVARR_LOG_DIR/Lidarr
echo "--> Create $SERVARR_LOG_DIR/Readarr"
mkdir -p $SERVARR_LOG_DIR/Readarr
echo "--> Create $SERVARR_LOG_DIR/Transmission"
mkdir -p $SERVARR_LOG_DIR/Transmission
echo "--> Create $SERVARR_LOG_DIR/nginx"
mkdir -p $SERVARR_LOG_DIR/nginx
echo "--> Create $SERVARR_LOG_DIR/flaresolverr"
mkdir -p $SERVARR_LOG_DIR/flaresolverr

echo "--> Copie nginx conf.d  /etc/nginx/"
cp -R /repo/nginx/** /etc/nginx/
echo "--> Update Nginx conf"
envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

echo "--> Setup settings transmission"
echo "--> Create $SERVARR_CONF_DIR/Transmission"
mkdir -p $SERVARR_CONF_DIR/Transmission
echo "--> Create $TRANSMISSION_COMPLETED_DIR "
mkdir -p "$TRANSMISSION_COMPLETED_DIR"
echo "--> Create $TRANSMISSION_INCOMPLETED_DIR"
mkdir -p "$TRANSMISSION_INCOMPLETED_DIR"
echo "--> Copie transmission config"
cp -R /repo/transmission/ $SERVARR_CONF_DIR/Transmission/
envsubst '$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD' < "/repo/transmission/init-settings.json" > "$SERVARR_CONF_DIR/Transmission/settings.json"

echo "--> Create $SERVARR_APP_DIR/Homer"
mkdir -p "$SERVARR_APP_DIR/Homer"
echo "--> Copie assets  $SERVARR_APP_DIR/Homer/assets/"
cp -R /repo/assets/** $SERVARR_APP_DIR/Homer/assets/
cp -R /repo/assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico

/usr/bin/supervisord >/dev/null &

tail -f $SERVARR_LOG_DIR/**/*.log