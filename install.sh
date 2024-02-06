#!/bin/bash

if [ "$EUID" -ne 0 ]; then
      echo "Please run as root."
      exit
fi

function Homer() {
      wget --no-check-certificate "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" -O Homer.zip
      unzip Homer.zip -d $SERVARR_APP/Homer
      rm Homer.zip
}

function Readar() {
      echo "Download Readarr"
      wget --no-check-certificate --content-disposition 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Readarr"
      tar -xvzf Readarr*.linux*.tar.gz
      echo "Move Readarr to $SERVARR_APP/"
      mv Readarr $SERVARR_APP/
      echo "Autorisation readarr in $SERVARR_APP/Readarr"
      chown readarr:readarr -R $SERVARR_APP/Readarr
      echo "Remove Readarr*.linux*.tar.gz"
      rm Readarr*.linux*.tar.gz
      $SERVARR_APP/Readarr/Readarr -nobrowser &
      sleep 20s
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/readarr</UrlBase>|g' ~/.config/Readar/config.xml
      pkill -f $SERVARR_APP/Readarr
}

function Radarr() {
      echo "Download Radarr"
      wget --no-check-certificate --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Radarr"
      tar -xvzf Radarr*.linux*.tar.gz
      echo "Move Radarr $SERVARR_APP/"
      mv Radarr $SERVARR_APP/
      echo "Autorisation Radarr in $SERVARR_APP/Radarr"
      chown radarr:radarr -R $SERVARR_APP/Radarr
      echo "Remove Radarr*.linux*.tar.gz"
      rm Radarr*.linux*.tar.gz
      $SERVARR_APP/Radarr/Radarr -nobrowser &
      sleep 20s
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/radarr</UrlBase>|g' ~/.config/Radarr/config.xml
      pkill -f $SERVARR_APP/Radarr
      wait
}

function Sonarr() {
      echo "Download Sonarr"
      wget --no-check-certificate --content-disposition 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64'
      echo "Extract Sonarr"
      tar -xvzf Sonarr*.linux*.tar.gz
      echo "Move Sonarr $SERVARR_APP/"
      mv Sonarr/ $SERVARR_APP
      echo "Autorisation Sonarr in $SERVARR_APP/Sonarr"
      chown -R root:media $SERVARR_APP/Sonarr
      echo "Remove Sonarr*.linux*.tar.gz"
      rm Sonarr*.linux*.tar.gz
      $SERVARR_APP/Sonarr/Sonarr -nobrowser &
      sleep 20s
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/sonarr</UrlBase>|g' ~/.config/Sonarr/config.xml
      pkill -f $SERVARR_APP/Sonarr
}

function Lidarr() {
      echo "Download Lidarr"
      wget --no-check-certificate --content-disposition 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Lidarr"
      tar -xvzf Lidarr*.linux*.tar.gz
      echo "Move Lidarr $SERVARR_APP/"
      mv Lidarr/ $SERVARR_APP
      echo "Autorisation Lidarr in $SERVARR_APP/Lidarr"
      chown -R root:media $SERVARR_APP/Lidarr
      echo "Remove Lidarr*.linux*.tar.gz"
      rm Lidarr*.linux*.tar.gz
      $SERVARR_APP/Lidarr/Lidarr -nobrowser &
      sleep 20s
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/lidarr</UrlBase>|g' ~/.config/Lidarr/config.xml
      pkill -f $SERVARR_APP/Lidarr
}

function Prowlarr() {
      echo "Download Prowlarr"
      wget --no-check-certificate --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
      echo "Extract Prowlarr"
      tar -xvzf Prowlarr*.linux*.tar.gz
      echo "Move Prowlarr $SERVARR_APP/"
      mv Prowlarr/ $SERVARR_APP
      echo "Autorisation Prowlarr in $SERVARR_APP/Prowlarr"
      chown prowlarr:prowlarr -R $SERVARR_APP/Prowlarr
      echo "Remove Prowlarr*.linux*.tar.gz"
      rm Prowlarr*.linux*.tar.gz
      $SERVARR_APP/Prowlarr/Prowlarr -nobrowser &
      sleep 20s
      sed -i 's|<UrlBase></UrlBase>|<UrlBase>/prowlarr</UrlBase>|g' ~/.config/Prowlarr/config.xml
      pkill -f $SERVARR_APP/Prowlarr

}

Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &
Homer &

wait
