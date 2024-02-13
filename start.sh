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

echo "--> mkdir -p $SERVARR_APP_DIR"
mkdir -p $SERVARR_APP_DIR

echo "--> mkdir -p $SERVARR_CONF_DIR"
mkdir -p $SERVARR_CONF_DIR

echo "--> git clone --depth=1 https://github.com/kalibrado/servarr-dashboard /repo >/dev/null"
git clone --depth=1 https://github.com/kalibrado/servarr-dashboard /repo >/dev/null

echo "--> cp -R /repo/nginx/** /etc/nginx/"
cp -R /repo/nginx/** /etc/nginx/

echo "--> cp -R /repo/fail2ban/ /etc/fail2ban/"
cp -R /repo/fail2ban/ /etc/fail2ban/

echo "--> cp /repo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf"
cp /repo/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

echo "--> mkdir -p $SERVARR_LOG_DIR/$(cat /etc/supervisor/conf.d/supervisord.conf | grep logfile | cut -d "/" -f 2 )"
mkdir -p $SERVARR_LOG_DIR/$(cat /etc/supervisor/conf.d/supervisord.conf | grep logfile | cut -d "/" -f 2 )

echo "--> Setup /etc/nginx/nginx.conf"
envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

echo "--> mkdir -p $SERVARR_CONF_DIR/Transmission $TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR"
mkdir -p $SERVARR_CONF_DIR/Transmission "$TRANSMISSION_COMPLETED_DIR"  "$TRANSMISSION_INCOMPLETED_DIR"

echo "--> cp -R /repo/transmission/ $SERVARR_CONF_DIR/Transmission/"
cp -R /repo/transmission/ $SERVARR_CONF_DIR/Transmission/

echo "--> Setup Transmission/settings.json"
envsubst "$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD" < "/repo/transmission/init-settings.json" > "$SERVARR_CONF_DIR/Transmission/settings.json"

echo "--> cp -R /repo/assets/** $SERVARR_APP_DIR/Homer/assets"
cp -R /repo/assets/** $SERVARR_APP_DIR/Homer/assets/
echo "--> cp -R /repo/assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico"
cp -R /repo/assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico

/usr/bin/supervisord &
echo "--> sleep 30s"
sleep 30s
tail -f $SERVARR_LOG_DIR/**/*.log || echo "tail -f $SERVARR_LOG_DIR/**/*.log  did not complete successfully"