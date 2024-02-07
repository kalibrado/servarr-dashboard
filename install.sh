#!/bin/bash
set -e

EXEC_TYPE=${1:="full"}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

WORKDIR=${SERVARR_APP_PATH:='/opt'}
USER_APP=${USER:='root'}
packages=(nano wget nginx sqlite3 mediainfo libchromaprint-tools nginx-extras supervisor procps ca-certificates transmission-daemon unzip)

function __set_app() {
    app=$1
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "Autorisation $app in $WORKDIR/$app"
    chown "$USER_APP":"$USER_APP" -R "$WORKDIR/$app"
    "$WORKDIR/$app/$app" -nobrowser &
    sleep 5s
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$HOME/.config/$app/config.xml"
    sed -i "s|<AuthenticationMethod></AuthenticationMethod>|<AuthenticationMethod>Basic</AuthenticationMethod>|g" "$HOME/.config/$app/config.xml"
    sed -i "s|<AuthenticationRequired></AuthenticationRequired>|<AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>|g" "$HOME/.config/$app/config.xml"
    pkill -f "$WORKDIR/$app"
    return
}


function __get_app(){
    app=$1
    url=$2
    extra=$3
    typefile=$4
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "[GET] => $app "
    wget -q --show-progress --no-check-certificate "$extra" "$url"
    if [[ "$typefile" == "zipfile" ]]; then
        echo "Extract zip file $app_lower.zip in $WORKDIR/$app"
        unzip -qqo "$app_lower".zip -d "$WORKDIR/$app"
        echo "Delete homer.zip"
        rm "$app_lower".zip
    else
        echo "Extract $app*.tar.gz"
        tar -xvzf "$app"*.tar.gz
        echo "Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "Move $app $WORKDIR/"
        mv "$app" "$WORKDIR/"
    fi
    return 
}

function Config() {
    echo "Update systeme..."
    apt-get -qq update 
    for i in "${packages[@]}"
    do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "--- installing $i ---" 
            apt-get -y -qq install "$i"
        else
            echo "--- $i already installed --- "
        fi
    done
    echo "Clean apt/lists..."
    rm -rf /var/lib/apt/lists/*
    apt-get -qq clean
    apt-get -qq autoremove -y
    echo "Create workspace $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "Create Workspace $WORKDIR"
    mkdir -p "$WORKDIR"
    return
}

function Homer() {
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    if [[ "$EXEC_TYPE" == "full" ]]; then
        echo "Copie assets Homer"
        cp ./assets/** "$WORKDIR/Homer/assets"
        echo "Edit favicon Homer"
        cp ./assets/logo.png "$WORKDIR/Homer/assets/icons/favicon.ico"
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
sed -i "s|_WORKDIR_|$WORKDIR/Homer|g" /etc/nginx/nginx.conf
echo "Edit conf theme nginx"
sed -i "s|_SERVARR_THEME_|$SERVARR_THEME|g" /etc/nginx/theme-park.conf
echo "Edit conf transmission"
sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_COMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/completed|g" /etc/transmission-daemon/settings.json
sed -i "s|_TRANSMISSION_DOWNLOADS_PATH_INCOMPLETED_|$TRANSMISSION_DOWNLOADS_PATH/incompleted|g" /etc/transmission-daemon/settings.json

echo "Script Ended"
exit 0