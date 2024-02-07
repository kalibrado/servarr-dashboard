FROM debian

MAINTAINER kalibrado

ARG DEBIAN_FRONTEND=noninteractive
ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP="/srv"
ENV LOGS_PATH="/var/log"
ENV SERVARR_THEME="dark"


COPY nginx/** /etc/nginx/
COPY transmission/** /etc/transmission-daemon/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh

VOLUME [ "/.config/", "/etc/nginx" ]
VOLUME $SERVARR_APP
VOLUME $TRANSMISSION_DOWNLOADS_PATH
VOLUME $LOGS_PATH
 
EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
