FROM debian

ENV SERVARR_APP_DIR='/servarr'
ENV SERVARR_CONF_DIR="/config"
ENV SERVARR_LOG_DIR="/var/log"
ENV SERVARR_THEME="overseerr"

ENV JELLYFIN_DATA_DIR="$SERVARR_CONF_DIR/Jellyfin/data"
ENV JELLYFIN_CONFIG_DIR="$SERVARR_CONF_DIR/Jellyfin/config"
ENV JELLYFIN_LOG_DIR="$SERVARR_LOG_DIR/Jellyfin"

ENV TRANSMISSION_COMPLETED_DIR="/media/downloads/completed"
ENV TRANSMISSION_INCOMPLETED_DIR="/media/downloads/incompleted"
ENV RPC_PASSWORD="transmission"
ENV RPC_USERNAME='transmission'
ENV RPC_AUTH_REQUIRED=true

ARG DEBIAN_FRONTEND=noninteractive

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN bash /setup.sh -t docker

COPY nginx/ /etc/nginx/
COPY transmission/ $SERVARR_CONF_DIR/Transmission/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/ $SERVARR_APP_DIR/Homer/assets/
COPY assets/servarr.png $SERVARR_APP_DIR/Homer/assets/icons/favicon.ico
 
VOLUME "/etc/nginx/" 
VOLUME $SERVARR_CONF_DIR
VOLUME $SERVARR_APP_DIR
VOLUME $TRANSMISSION_COMPLETED_DIR 

EXPOSE 80/tcp
EXPOSE 51413/tcp

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/usr/bin/supervisord"]
