# Servarr-Dashboard
Here is a docker image that contains the following apps:
- Prowlarr (Indexer)
- Sonarr (TV Series)
- Radarr (Movies)
- Lidarr (Music)
- Readarr (Books)
- Transmission (Torrent downloader)

This images is configured so that each service is accessible from an integrated proxy reverse to simplify the connection between applications
the dashboard is Homer

the nginx configuration sends each app to http://your_ip/lapp_name

ex: http://127.0.0.1/Prowlarr to access the Prowlarr page

```yml
version: '4'

services:
  servarr-dashboard:
    container_name: servarr-dashboard
    image: ldfe/servarr-dashboard
    environment:
      - SERVARR_THEME="dark" # set this value to change theme look:  https://docs.theme-park.dev/themes/requestrr/
    ports:
      - 80:80 # web ui port
      - 51413:51413 # tranmission port
```
## Screenshots
![Annotation 2024-02-07 183408](https://github.com/kalibrado/servarr-dashboard/assets/51781584/7143a8bd-6a82-48b9-9022-261e03062d11)


![Annotation 2024-02-07 183356](https://github.com/kalibrado/servarr-dashboard/assets/51781584/33a80a00-442c-435b-9124-5b6ef2989408)



