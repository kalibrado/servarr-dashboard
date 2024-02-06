FROM debian

ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP="/srv"
ENV LOGS_PATH="/var/log"
ENV SERVARR_THEME="dark"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get install  --no-install-recommends -y \
curl \
nano \
wget \
nginx \
sqlite3 \
mediainfo \
libchromaprint-tools \
nginx-extras \
supervisor \ 
procps \
ca-certificates \
transmission-daemon \
unzip

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean
RUN apt autoremove -y

RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
RUN mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
RUN mkdir -p "$SERVARR_APP/Homer"

COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh

RUN chown -R www-data:www-data /var/www/html

COPY nginx/** /etc/nginx/
RUN sed -i "s|_SERVARR_APP_|$SERVARR_APP/Homer|g" /etc/nginx/nginx.conf
RUN sed -i "s|_SERVARR_THEME_|$SERVARR_THEME|g" /etc/nginx/theme-park.conf

COPY transmission/** /etc/transmission-daemon/
RUN sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_COMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/completed|g" /etc/transmission-daemon/settings.json
RUN sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_INCOMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/incompleted|g" /etc/transmission-daemon/settings.json

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/** $SERVARR_APP/Homer/assets
COPY assets/servarr.png $SERVARR_APP/Homer/assets/icons/favicon.ico

VOLUME [ "/.config/", $SERVARR_APP, $TRANSMISSION_DOWNLOADS_PATH, "/etc/nginx"]
 
EXPOSE 80/tcp
EXPOSE 51413/tcp
 
CMD ["/usr/bin/supervisord"]
