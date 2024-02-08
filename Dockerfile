FROM debian

ENV SERVARR_CONFIG_PATH="/config"
ENV SERVARR_APP_PATH="/srv"
ENV SERVARR_LOGS_PATH="/config/logs"
ENV SERVARR_THEME="overseerr"

ENV JELLYFIN_DATA_DIR="$SERVARR_CONFIG_PATH/Jellyfin/data"
ENV JELLYFIN_CONFIG_DIR="$SERVARR_CONFIG_PATH/Jellyfin/config"
ENV JELLYFIN_CACHE_DIR="$SERVARR_APP_PATH/Jellyfin/Cache"
ENV JELLYFIN_LOG_DIR="$SERVARR_CONFIG_PATH/Jellyfin"

ENV TRANSMISSION_AUTH="true"
ENV TRANSMISSION_USER="transmission"
ENV TRANSMISSION_PASS="transmission"
ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"

ENV FLARESOLVERR_VERSION="v3.3.13"
ENV FLARESOLVERR_LOG_LEVEL="info"
ENV FLARESOLVERR_LOG_HTML="false"
ENV FLARESOLVERR_CAPTCHA_SOLVER="none"
ENV FLARESOLVERR_TZ="UTC"
ENV FLARESOLVERR_LANG="none"
ENV FLARESOLVERR_HEADLESS="true" 
ENV FLARESOLVERR_BROWSER_TIMEOUT="40000" 
ENV FLARESOLVERR_TEST_URL="https://www.google.com"
ENV FLARESOLVERR_PORT="8191"
ENV FLARESOLVERR_HOST="0.0.0.0"
ENV FLARESOLVERR_PROMETHEUS_ENABLED="false"
ENV FLARESOLVERR_PROMETHEUS_PORT="8192"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update 
RUN apt-get install -qq -y \
curl gnupg software-properties-common \
nano wget nginx sqlite3 mediainfo libchromaprint-tools \
nginx-extras supervisor procps ca-certificates transmission-daemon \
unzip gettext-base chromium chromium-common chromium-driver  xvfb dumb-init
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -qq clean
RUN apt-get -qq autoremove -y

RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
RUN mkdir -p "$SERVARR_APP_PATH/Homer"
RUN mkdir -p "$SERVARR_LOGS_PATH"


COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh dockerfile

COPY nginx/** /etc/nginx/
COPY transmission/** $SERVARR_CONFIG_PATH/Transmission/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/** $SERVARR_APP_PATH/Homer/assets
COPY assets/servarr.png $SERVARR_APP_PATH/Homer/assets/icons/favicon.ico
 
VOLUME "/etc/nginx" 
VOLUME $SERVARR_CONFIG_PATH
VOLUME $SERVARR_APP_PATH
VOLUME $TRANSMISSION_DOWNLOADS_PATH 

EXPOSE 80/tcp
EXPOSE 51413/tcp

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/usr/bin/supervisord"]
