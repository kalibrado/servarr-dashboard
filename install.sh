#!/bin/bash

# Script for install all app 

set -e


if [ "$EUID" -ne 0 ]; then
    echo "--> Please run as root."
    exit 1
fi

SERVARR_APP_PATH=${SERVARR_APP_PATH:='/opt'}
SERVARR_CONFIG_PATH=${SERVARR_CONFIG_PATH:="/config"}
TRANSMISSION_DOWNLOADS_PATH=${TRANSMISSION_DOWNLOADS_PATH:="/media/downloads"}
USER_APP=${USER:='root'}
EXEC_TYPE=${1:="full"}
PACKAGES=(nano wget nginx sqlite3 mediainfo libchromaprint-tools nginx-extras supervisor procps ca-certificates transmission-daemon unzip gettext-base)


if [[ "$EXEC_TYPE" == "full" ]]; then
    echo "--> Update systeme..."
    apt-get -qq update 
    for i in "${PACKAGES[@]}"
    do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "--> installing $i ---" 
            apt-get -y -qq install "$i"
        else
            echo "-->  $i already installed --- "
        fi
    done
    echo "--> Clean apt/lists..."
    rm -rf /var/lib/apt/lists/*
    apt-get -qq clean
    apt-get -qq autoremove -y
    echo "--> Create workspace $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "--> Create Workspace $SERVARR_APP_PATH"
    mkdir -p "$SERVARR_APP_PATH"
fi



function __set_app() {
    app=$1
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> Autorisation $app in $SERVARR_APP_PATH/$app"
    chown "$USER_APP":"$USER_APP" -R "$SERVARR_APP_PATH/$app"
    "$SERVARR_APP_PATH/$app/$app" -nobrowser -data="$SERVARR_CONFIG_PATH/$app" &
    sleep 5s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    sed -i "s|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    sed -i "s|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    pkill -f "$SERVARR_APP_PATH/$app/$app"
    return
}


function __get_app(){
    app=$1
    url=$2
    extra=$3
    typefile=$4
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "--> GET: $app "
    wget -q --show-progress --no-check-certificate "$extra" "$url"
    if [[ "$typefile" == "zipfile" ]]; then
        echo "--> Extract zip file $app_lower.zip in $SERVARR_APP_PATH/$app"
        unzip -qqo "$app_lower".zip -d "$SERVARR_APP_PATH/$app"
        echo "--> Delete $app_lower.zip"
        rm "$app_lower".zip
    else
        echo "--> Extract $app*.tar.gz"
        tar -xzf "$app"*.tar.gz
        echo "--> Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "--> Move $app $SERVARR_APP_PATH/"
        mv "$app" "$SERVARR_APP_PATH/"
    fi
    return 
}

function Homer() {
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    if [[ "$EXEC_TYPE" == "full" ]]; then
        echo "--> Copie assets Homer"
        cp ./assets/** "$SERVARR_APP_PATH/Homer/assets"
        echo "--> Edit favicon Homer"
        cp ./assets/logo.png "$SERVARR_APP_PATH/Homer/assets/icons/favicon.ico"
    fi
    return
}

function Readar() { 
    __get_app "Readarr" 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Readarr"
    return
}

function Radarr() {
    __get_app "Radarr" 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Radarr"
    return
}

function Sonarr() {
    __get_app "Sonarr" 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Sonarr"
    return
}

function Lidarr() {
    __get_app "Lidarr" 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Lidarr"
    return
}

function Prowlarr() {
    __get_app "Prowlarr" 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Prowlarr"
    return
}

Prowlarr &
Readar &
Radarr &
Sonarr &
Lidarr &
Homer &
wait

echo "--> Script Ended"
exit 0