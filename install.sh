#!/bin/bash

if [ "$EUID" -ne 0 ]; then
      echo "Please run as root."
      exit
fi

function Readar() {
      echo "Download Readarr"
      wget --no-check-certificate --content-disposition 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Readarr"
      tar -xvzf Readarr*.linux*.tar.gz
      echo "Move Readarr to /opt/"
      mv Readarr /opt/
      echo "Autorisation readarr in /opt/Readarr"
      chown readarr:readarr -R /opt/Readarr
      echo "Remove Readarr*.linux*.tar.gz"
      rm Readarr*.linux*.tar.gz
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/readarr</UrlBase>|g' ~/.config/Readar/config.xml
}

function Radarr() {
      echo "Download Radarr"
      wget --no-check-certificate --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Radarr"
      tar -xvzf Radarr*.linux*.tar.gz
      echo "Move Radarr /opt/"
      mv Radarr /opt/
      echo "Autorisation Radarr in /opt/Radarr"
      chown radarr:radarr -R /opt/Radarr
      echo "Remove Radarr*.linux*.tar.gz"
      rm Radarr*.linux*.tar.gz
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/radarr</UrlBase>|g' ~/.config/Radarr/config.xml
}

function Sonarr() {
      echo "Download Sonarr"
      wget --no-check-certificate --content-disposition 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64'
      echo "Extract Sonarr"
      tar -xvzf Sonarr*.linux*.tar.gz
      echo "Move Sonarr /opt/"
      mv Sonarr/ /opt
      echo "Autorisation Sonarr in /opt/Sonarr"
      chown -R root:media /opt/Sonarr
      echo "Remove Sonarr*.linux*.tar.gz"
      rm Sonarr*.linux*.tar.gz
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/sonarr</UrlBase>|g' ~/.config/Sonarr/config.xml
}

function Lidarr() {
      echo "Download Lidarr"
      wget --no-check-certificate --content-disposition 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Lidarr"
      tar -xvzf Lidarr*.linux*.tar.gz
      echo "Move Lidarr /opt/"
      mv Lidarr/ /opt
      echo "Autorisation Lidarr in /opt/Lidarr"
      chown -R root:media /opt/Lidarr
      echo "Remove Lidarr*.linux*.tar.gz"
      rm Lidarr*.linux*.tar.gz
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/lidarr</UrlBase>|g' ~/.config/Lidarr/config.xml
}

function Prowlarr() {
      echo "Download Prowlarr"
      wget --no-check-certificate --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Prowlarr"
      tar -xvzf Prowlarr*.linux*.tar.gz
      echo "Move Prowlarr /opt/"
      mv Prowlarr/ /opt
      echo "Autorisation Prowlarr in /opt/Prowlarr"
      chown prowlarr:prowlarr -R /opt/Prowlarr
      echo "Remove Prowlarr*.linux*.tar.gz"
      rm Prowlarr*.linux*.tar.gz
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/prowlarr</UrlBase>|g' ~/.config/Prowlarr/config.xml
}

Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &

wait
