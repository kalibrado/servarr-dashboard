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

RUN mkdir -p /etc/nginx/

COPY nginx/** /etc/nginx/
COPY transmission/** /etc/transmission-daemon/
COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh dockerfile

COPY assets/** $SERVARR_APP_PATH/Homer/assets
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME "$HOME/.config/"
VOLUME "/etc/nginx" 
VOLUME "/etc/transmission-daemon"
VOLUME $SERVARR_APP_PATH
VOLUME $TRANSMISSION_DOWNLOADS_PATH 
 
EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
