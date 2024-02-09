# Servarr-Dashboard

## Here are the services that are currently operational

- [X] [Nginx (reverse proxy)](https://www.nginx.com/)
- [ ] [Jellyfin](https://jellyfin.org/)
- [X] [Homer](https://github.com/bastienwirtz/homer)
- [X] [Prowlarr](https://wiki.servarr.com/en/prowlarr)
- [X] [Sonarr](https://wiki.servarr.com/en/sonarr)
- [X] [Radarr](https://wiki.servarr.com/en/radarr)
- [X] [Lidarr](https://wiki.servarr.com/en/lidarr)
- [X] [Readarr](https://wiki.servarr.com/en/readarr)
- [X] [Transmission](https://transmissionbt.com/)
- [ ] [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
- [ ] OpenVpn
- [ ] Fail2Ban


## Here is the full list of paths for each service

Change the 'localhost' based on your IP address or domain name

- Homer => <http://localhost>
- Prowlarr => <http://localhost/prowlarr>
- Sonarr => <http://localhost/sonarr>
- Radarr => <http://localhost/radarr>
- Lidarr => <http://localhost/lidarr>
- Readarr => <http://localhost/readarr>
- Transmission => <http://localhost/transmission>
- FlareSolverr => <http://localhost/flaresolverr>


## Use with Docker
  
- without VPN

```yml
version: '4'

services:
  servarr-dashboard:
    container_name: servarr-dashboard
    image: ldfe/servarr-dashboard
    restart: always
    environment:
      - SERVARR_THEME="overseerr" # set this to change theme in app *arrs look -> https://docs.theme-park.dev/themes/sonarr/
      - TRANSMISSION_AUTH="true" # enable or not auth methode in tranmission
      - TRANSMISSION_USER="transmission" # user tranmission
      - TRANSMISSION_PASS="transmission" # pass tranmission
    volumes:
      - /opt/servarr/config:/config # optional
      - /opt/servarr/nginx:/etc/nginx # optional
      - /opt/servarr/app:/srv # optional
      - /opt/servarr/logs:/var/log  # optional
      - /opt/servarr/downloads:/media/downloads # optional
    ports:
      - 80:80 # Servarr Dashboard Port
      - 33242:33242/tcp  # Transmission Torrent Port TCP
      - 33242:33242/udp  # Transmission Torrent Port UDP 
```

- with VPN

```yml
version: '4'

services:
  servarr-dashboard:
    container_name: servarr-dashboard
    image: ldfe/servarr-dashboard
    restart: always
    environment:
      - SERVARR_THEME="overseerr" # set this to change theme in app *arrs look -> https://docs.theme-park.dev/themes/sonarr/
      - TRANSMISSION_AUTH="true" # enable or not auth methode on in tranmission
      - TRANSMISSION_USER="transmission" # default user tranmission
      - TRANSMISSION_PASS="transmission" # default pass tranmission
    volumes:
      - /opt/servarr/config:/config
      - /opt/servarr/nginx:/etc/nginx
      - /opt/servarr/app:/srv
      - /opt/servarr/logs:/var/log 
      - /opt/servarr/downloads:/media/downloads
    network_mode: "service:gluetun"
    depends_on:
      gluetun:
        condition: service_started
        restart: true
        required: true
  
  gluetun:
    image: qmcgaw/gluetun:v3
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ./gluetun:/gluetun # optional
    restart: unless-stopped
    environment:
      - OPENVPN_PASSWORD=${OPENVPN_PASSWORD}
      - OPENVPN_USER=${OPENVPN_USER}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES}
      - TZ=${TZ}
      - UPDATER_PERIOD=24h
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER}
    ports:
      - 51413:51413 # Gluetun port
      - 80:80 # Servarr Dashboard Port
      - 33242:33242/tcp  # Transmission Torrent Port TCP
      - 33242:33242/udp  # Transmission Torrent Port UDP 
```