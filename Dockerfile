FROM debian

ENV SERVARR_CONFIG_PATH="/config"
ENV SERVARR_APP_PATH="/srv"
ENV SERVARR_LOGS_PATH="/var/log"
ENV SERVARR_THEME="overseerr"
ENV TRANSMISSION_AUTH="true"
ENV TRANSMISSION_USER="transmission"
ENV TRANSMISSION_PASS="transmission"
ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update 
RUN apt-get install -qq -y nano wget nginx sqlite3 mediainfo libchromaprint-tools nginx-extras supervisor procps ca-certificates transmission-daemon unzip
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -qq clean
RUN apt-get -qq autoremove -y

RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
RUN mkdir -p "$SERVARR_APP_PATH/Homer"


COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh dockerfile

COPY nginx/** /etc/nginx/
COPY transmission/** $SERVARR_CONFIG_PATH/Transmission
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
