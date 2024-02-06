FROM debian

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
      ca-certificates

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

# Copy the Nginx config
COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN bash /install.sh

RUN chown -R www-data:www-data /var/www/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx
VOLUME /opt/
VOLUME ~/.config

# Expose Port for the Application 
EXPOSE 80/tcp

# Run the Nginx server
CMD ["/usr/bin/supervisord"]
