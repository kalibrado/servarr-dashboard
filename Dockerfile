FROM debian

ENV WORKDIR="/servarr-dashboard"
ENV SERVARR_APP_DIR="$WORKDIR/app"
ENV SERVARR_CONF_DIR="$WORKDIR/config"
ENV SERVARR_LOG_DIR="$WORKDIR/log"
ENV SERVARR_THEME="overseerr"
ENV TRANSMISSION_COMPLETED_DIR="/media/downloads/completed"
ENV TRANSMISSION_INCOMPLETED_DIR="/media/downloads/incompleted"
ENV RPC_PASSWORD="transmission"
ENV RPC_USERNAME='transmission'
ENV RPC_AUTH_REQUIRED="true"

ARG DEBIAN_FRONTEND=noninteractive

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh
VOLUME "/media/downloads"
VOLUME $WORKDIR  

EXPOSE 80/tcp
EXPOSE 51413/tcp
RUN bash /setup.sh

ENTRYPOINT [ "bash", "/start.sh"]