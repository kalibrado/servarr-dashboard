#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

function Config() {
    echo "Update syteme ..."
    apt-get -qq update 
    echo "Install tools ..."
    apt-get install --no-install-recommends -y -qq curl nano wget nginx sqlite3 mediainfo libchromaprint-tools \
    nginx-extras supervisor procps ca-certificates transmission-daemon unzip

    echo "Clean apt/lists ..."
    rm -rf /var/lib/apt/lists/*
    apt-get -qq clean
    apt-get -qq autoremove -y

    echo "Create workspace $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "Create Workspace $SERVARR_APP"
    mkdir -p "$SERVARR_APP"
    return 
}

function Homer() {
    echo "Download Homer ..."
    wget -q --show-progress --no-check-certificate "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" -O Homer.zip
    echo "Unzip Homer.zip in $SERVARR_APP/Homer"
    unzip -qq Homer.zip -d $SERVARR_APP/Homer
    echo "Delete homer.zip"
    rm Homer.zip
    echo "Copie assets Homer"
    cp ./assets/** $SERVARR_APP/Homer/assets
    echo "Edit favicon Homer"
    cp ./assets/logo.png $SERVARR_APP/Homer/assets/icons/favicon.ico
    return 
}

function Readar() {
    echo "Download Readarr..."
    wget -q --show-progress --no-check-certificate --content-disposition 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64'
    echo "Extract Readarr"
    tar -xvzf Readarr*.linux*.tar.gz >/dev/null 2>&1
    echo "Move Readarr to $SERVARR_APP/"
    mv Readarr $SERVARR_APP/
    echo "Autorisation readarr in $SERVARR_APP/Readarr"
    chown readarr:readarr -R $SERVARR_APP/Readarr
    echo "Remove Readarr*.linux*.tar.gz"
    rm Readarr*.linux*.tar.gz
    $SERVARR_APP/Readarr/Readarr -nobrowser &
    sleep 5s
    sed -i 's|<UrlBase></UrlBase>|<UrlBase>/readarr</UrlBase>|g' ~/.config/Readarr/config.xml
    sed -i 's|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g' ~/.config/Readarr/config.xml
    sed -i 's|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g' ~/.config/Readarr/config.xml
    pkill -f $SERVARR_APP/Readarr
    return
}

function Radarr() {
    echo "Download Radarr..."
    wget -q --show-progress --no-check-certificate --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
    echo "Extract Radarr"
    tar -xvzf Radarr*.linux*.tar.gz >/dev/null 2>&1
    echo "Move Radarr $SERVARR_APP/"
    mv Radarr $SERVARR_APP/
    echo "Autorisation Radarr in $SERVARR_APP/Radarr"
    chown radarr:radarr -R $SERVARR_APP/Radarr
    echo "Remove Radarr*.linux*.tar.gz"
    rm Radarr*.linux*.tar.gz
    $SERVARR_APP/Radarr/Radarr -nobrowser &
    sleep 5s
    sed -i 's|<UrlBase></UrlBase>|<UrlBase>/radarr</UrlBase>|g' ~/.config/Radarr/config.xml
    sed -i 's|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g' ~/.config/Radarr/config.xml
    sed -i 's|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g' ~/.config/Radarr/config.xml
    pkill -f $SERVARR_APP/Radarr
    return
}

function Sonarr() {
    echo "Download Sonarr..."
    wget -q --show-progress --no-check-certificate --content-disposition 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64'
    echo "Extract Sonarr"
    tar -xvzf Sonarr*.linux*.tar.gz >/dev/null 2>&1
    echo "Move Sonarr $SERVARR_APP/"
    mv Sonarr/ $SERVARR_APP
    echo "Autorisation Sonarr in $SERVARR_APP/Sonarr"
    chown -R root:media $SERVARR_APP/Sonarr
    echo "Remove Sonarr*.linux*.tar.gz"
    rm Sonarr*.linux*.tar.gz
    $SERVARR_APP/Sonarr/Sonarr -nobrowser &
    sleep 5s
    sed -i 's|<UrlBase></UrlBase>|<UrlBase>/sonarr</UrlBase>|g' ~/.config/Sonarr/config.xml
    sed -i 's|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g' ~/.config/Sonarr/config.xml
    sed -i 's|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g' ~/.config/Sonarr/config.xml
    pkill -f $SERVARR_APP/Sonarr
    return
}

function Lidarr() {
    echo "Download Lidarr..."
    wget -q --show-progress --no-check-certificate --content-disposition 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
    echo "Extract Lidarr"
    tar -xvzf Lidarr*.linux*.tar.gz >/dev/null 2>&1
    echo "Move Lidarr $SERVARR_APP/"
    mv Lidarr/ $SERVARR_APP
    echo "Autorisation Lidarr in $SERVARR_APP/Lidarr"
    chown -R root:media $SERVARR_APP/Lidarr
    echo "Remove Lidarr*.linux*.tar.gz"
    rm Lidarr*.linux*.tar.gz
    $SERVARR_APP/Lidarr/Lidarr -nobrowser &
    sleep 5s
    sed -i 's|<UrlBase></UrlBase>|<UrlBase>/lidarr</UrlBase>|g' ~/.config/Lidarr/config.xml
    sed -i 's|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g' ~/.config/Lidarr/config.xml
    sed -i 's|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g' ~/.config/Lidarr/config.xml
    pkill -f $SERVARR_APP/Lidarr
    return
}

function Prowlarr() {
    echo "Download Prowlarr..."
    wget -q --show-progress --no-check-certificate --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
    echo "Extract Prowlarr"
    tar -xvzf Prowlarr*.linux*.tar.gz >/dev/null 2>&1
    echo "Move Prowlarr $SERVARR_APP/"
    mv Prowlarr/ $SERVARR_APP
    echo "Autorisation Prowlarr in $SERVARR_APP/Prowlarr"
    chown prowlarr:prowlarr -R $SERVARR_APP/Prowlarr
    echo "Remove Prowlarr*.linux*.tar.gz"
    rm Prowlarr*.linux*.tar.gz
    $SERVARR_APP/Prowlarr/Prowlarr -nobrowser &
    sleep 5s
    sed -i 's|<UrlBase></UrlBase>|<UrlBase>/prowlarr</UrlBase>|g' ~/.config/Prowlarr/config.xml
    sed -i 's|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g' ~/.config/Prowlarr/config.xml
    sed -i 's|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g' ~/.config/Prowlarr/config.xml
    pkill -f $SERVARR_APP/Prowlarr
    return
}

Config &
wait

# Run in background for best performance
Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &
Homer &
wait

echo "Edit conf nginx"
sed -i "s|_SERVARR_APP_|$SERVARR_APP/Homer|g" /etc/nginx/nginx.conf
echo "Edit conf theme nginx"
sed -i "s|_SERVARR_THEME_|$SERVARR_THEME|g" /etc/nginx/theme-park.conf
echo "Edit conf transmission"
sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_COMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/completed|g" /etc/transmission-daemon/settings.json
sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_INCOMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/incompleted|g" /etc/transmission-daemon/settings.json


echo "Script Ended"
exit 0