FROM debian

ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP="/srv"
ENV LOGS_PATH="/var/log"
ENV SERVARR_THEME="dark"

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
RUN mkdir -p "$SERVARR_APP/Homer"
RUN mkdir p /etc/nginx/

COPY nginx/** /etc/nginx/
COPY transmission/** /etc/transmission-daemon/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY install.sh /install.sh

RUN chmod +x /install.sh
RUN bash /install.sh

COPY assets/** $SERVARR_APP/Homer/assets
COPY assets/servarr.png $SERVARR_APP/Homer/assets/icons/favicon.ico

VOLUME "$HOME/.config/"
VOLUME "/etc/nginx" 
VOLUME $SERVARR_APP
VOLUME $TRANSMISSION_DOWNLOADS_PATH
VOLUME $LOGS_PATH
 
EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
