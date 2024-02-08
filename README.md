# Servarr-Dashboard

Here is a docker image that contains the following apps:

- [Nginx (reverse proxy)](https://www.nginx.com/)
- [Homer (Dashboard)](https://github.com/bastienwirtz/homer)
- [Prowlarr (Indexer)](https://wiki.servarr.com/en/prowlarr)
- [Sonarr (TV Series)](https://wiki.servarr.com/en/sonarr)
- [Radarr (Movies)](https://wiki.servarr.com/en/radarr)
- [Lidarr (Music)](https://wiki.servarr.com/en/lidarr)
- [Readarr (Books)](https://wiki.servarr.com/en/readarr)
- [Transmission](https://transmissionbt.com/)
- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
- [Jellyfin](https://jellyfin.org/)

⚡soon the addition of openvpn

FlareSolverr is a proxy server to bypass Cloudflare and DDoS-GUARD protection.

This images is configured so that each service is accessible from an integrated proxy reverse to simplify the connection between applications

the nginx configuration sends each app to http://your_ip/lapp_name

ex: <http://127.0.0.1/Prowlarr> to access the Prowlarr page

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
    ports:
      - 80:80 # web ui port
```

## Screenshots

![Annotation 2024-02-07 183408](https://github.com/kalibrado/servarr-dashboard/assets/51781584/7143a8bd-6a82-48b9-9022-261e03062d11)

![Annotation 2024-02-07 183356](https://github.com/kalibrado/servarr-dashboard/assets/51781584/33a80a00-442c-435b-9124-5b6ef2989408)
