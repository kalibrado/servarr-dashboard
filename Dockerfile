FROM debian

ENV TRANSMISSION_DOWNLOADS_PATH="/media/downloads"
ENV SERVARR_APP = "/srv"
ENV LOGS_PATH = "/var/log"

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
      transmission-daemon

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

# Copy the Nginx config
COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh

RUN mkdir -p ${TRANSMISSION_DOWNLOADS_PATH}
RUN mkdir -p ${TRANSMISSION_DOWNLOADS_PATH}/completed
RUN mkdir -p ${TRANSMISSION_DOWNLOADS_PATH}/incompleted

RUN chown -R www-data:www-data /var/www/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/** ${SERVARR_APP}/Homer/assets

COPY transmission/** /etc/transmission-daemon/

VOLUME [ "~/.config/", ${SERVARR_APP}, "/etc/nginx", "/usr/share/nginx/html" ]

# Expose Port for the Application 
EXPOSE 80/tcp
EXPOSE 51413/tcp
# Run the Nginx server
CMD ["/usr/bin/supervisord"]
