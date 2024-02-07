FROM debian

ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP="/srv"
ENV LOGS_PATH="/var/log"
ENV SERVARR_THEME="dark"

ARG DEBIAN_FRONTEND=noninteractive

COPY nginx/** /etc/nginx/
COPY transmission/** /etc/transmission-daemon/
COPY install.sh /install.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/** $SERVARR_APP/Homer/assets
COPY assets/servarr.png $SERVARR_APP/Homer/assets/icons/favicon.ico


RUN chmod +x /install.sh
RUN bash /install.sh


VOLUME [ "/.config/", "/etc/nginx" ]
VOLUME $SERVARR_APP
VOLUME $TRANSMISSION_DOWNLOADS_PATH
VOLUME $LOGS_PATH
 
EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
