FROM debian

ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP_PATH="/srv"
ENV LOGS_PATH="/var/log"
ENV SERVARR_THEME="dark"

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
RUN sed -i "s|_SERVARR_APP_|$SERVARR_APP_PATH/Homer|g" /etc/nginx/nginx.conf
RUN sed -i "s|_SERVARR_THEME_|$SERVARR_THEME|g" /etc/nginx/theme-park.conf

COPY transmission/** /etc/transmission-daemon/
RUN sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_COMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/completed|g" /etc/transmission-daemon/settings.json
RUN sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_INCOMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/incompleted|g" /etc/transmission-daemon/settings.json

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/** $SERVARR_APP/Homer/assets
COPY assets/servarr.png $SERVARR_APP/Homer/assets/icons/favicon.ico
 
VOLUME "/etc/nginx" 
VOLUME "/etc/transmission-daemon"
VOLUME "/config"
VOLUME $SERVARR_APP_PATH
VOLUME $TRANSMISSION_DOWNLOADS_PATH 

EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
