#!/bin/bash
cat << EOF
#-------------------------------------------------------------------------------------------------------------------------#
#   _____   ___  ____   __ __   ____  ____   ____          ___     ____   _____ __ __  ____    ___    ____  ____   ___    #
#  / ___/  /  _]|    \ |  |  | /    ||    \ |    \        |   \   /    | / ___/|  |  ||    \  /   \  /    ||    \ |   \   #
# (   \_  /  [_ |  D  )|  |  ||  o  ||  D  )|  D  ) _____ |    \ |  o  |(   \_ |  |  ||  o  )|     ||  o  ||  D  )|    \  #
#  \__  ||    _]|    / |  |  ||     ||    / |    / |     ||  D  ||     | \__  ||  _  ||     ||  O  ||     ||    / |  D  | #
#  /  \ ||   [_ |    \ |  :  ||  _  ||    \ |    \ |_____||     ||  _  | /  \ ||  |  ||  O  ||     ||  _  ||    \ |     | #
#  \    ||     ||  .  \ \   / |  |  ||  .  \|  .  \       |     ||  |  | \    ||  |  ||     ||     ||  |  ||  .  \|     | #
#   \___||_____||__|\_|  \_/  |__|__||__|\_||__|\_|       |_____||__|__|  \___||__|__||_____| \___/ |__|__||__|\_||_____| #
#                                                                                                                         #
#                                  ____   __ __          __  _   ____  _      ____  ____   ____    ____  ___     ___      #
#                                 |    \ |  |  |        |  |/ ] /    || |    |    ||    \ |    \  /    ||   \   /   \     #
#                                 |  o  )|  |  |        |  ' / |  o  || |     |  | |  o  )|  D  )|  o  ||    \ |     |    #
#                                 |     ||  ~  |        |    \ |     || |___  |  | |     ||    / |     ||  D  ||  O  |    #
#                                 |  O  ||___, |        |     \|  _  ||     | |  | |  O  ||    \ |  _  ||     ||     |    #
#                                 |     ||     |        |  .  ||  |  ||     | |  | |     ||  .  \|  |  ||     ||     |    #
#                                 |_____||____/         |__|\_||__|__||_____||____||_____||__|\_||__|__||_____| \___/     #
#-------------------------------------------------------------------------------------------------------------------------#                                                                                                                                                                                                                                                                                              
EOF

if [ "$EUID" -ne 0 ]; then
    echo "⚡ 👉 Please run as root."
    exit 1
fi
############################################################
# Variables                                                #
############################################################
SERVARR_APP_PATH=${SERVARR_APP_PATH:='/opt'}
SERVARR_CONFIG_PATH=${SERVARR_CONFIG_PATH:="/config"}
SERVARR_LOGS_PATH=${SERVARR_LOGS_PATH:="/var/log"}
USER_APP=${USER:='root'}

ExecType="full"
Apps="all"

############################################################
# Help                                                     #
############################################################
Help() {
    echo "--------------------------------------------------------------"
    # Display Help
    echo "Using the installation script to automate Servarr-Dashboard"
    echo
    echo "Syntax: setup.sh [-t|a|h]"
    echo "options:"
    echo "-t     The -t argument is the execution type: docker or full by default it is full "
    echo "-a     The -a argument supports a string of application to install separated by semicolons if it is not specified by default all"
    echo "-h     Print this Help."
    echo
    echo "Here is an example of using the script to install full and only the radarr and sonarr applications"
    echo "bash setup.sh -t full -a 'radarr;sonarr'"
    echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################
function __install_Packages() {
    echo "--------------------------------------------------------------"
    arr=("$@")
    for i in "${arr[@]}"; do
        if ! [ -x "$(command -v "$i")" ]; then
            echo "  👉 installing $i"
            apt-get -y -qq install "$i"
        else
            echo "  👌 $i already installed"
        fi
    done
}

function __set_app() {
    echo "--------------------------------------------------------------"
    app=$1
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "  👉 Create log dir for $app_lower"
    mkdir -p "$SERVARR_LOGS_PATH/$app_lower"
    echo "  👉 Autorisation $app in $SERVARR_APP_PATH/$app"
    chown "$USER_APP":"$USER_APP" -R "$SERVARR_APP_PATH/$app"
    "$SERVARR_APP_PATH/$app/$app" -nobrowser -data="$SERVARR_CONFIG_PATH/$app" &
    sed -i "s|<UrlBase></UrlBase>|<UrlBase>/$app_lower</UrlBase>|g" "$SERVARR_CONFIG_PATH/$app/config.xml"
    pkill -f "$SERVARR_APP_PATH/$app/$app"
    return
}

function __get_app() {
    echo "--------------------------------------------------------------"
    app=$1
    url=$2
    extra=$3
    typefile=$4
    app_lower=$(echo "$app" | tr "[:upper:]" "[:lower:]")
    echo "  👉 GET: $app "
    wget -q --show-progress --no-check-certificate "$extra" "$url"
    if [[ "$typefile" == "zipfile" ]]; then
        echo "      👉 Extract zip file $app_lower.zip in $SERVARR_APP_PATH/$app"
        unzip -qqo "$app_lower".zip -d "$SERVARR_APP_PATH/$app"
        echo "      👉 Delete $app_lower.zip"
        rm "$app_lower".zip
    else
        echo "      👉 Extract $app*.tar.gz"
        tar -xzf "$app"*.tar.gz
        echo "      👉 Delete $app*.tar.gz"
        rm "$app"*.tar.gz
        echo "      👉 Move $app $SERVARR_APP_PATH/"
        mv "$app" "$SERVARR_APP_PATH/"
    fi
    return
}

function homer() {
    echo "--------------------------------------------------------------"
    __get_app "Homer" "https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip" --content-disposition "zipfile"
    if [[ "$ExecType" == "full" ]]; then
        echo " 👉 Copie assets Homer"
        cp ./assets/** "$SERVARR_APP_PATH/Homer/assets"
        echo " 👉 Edit favicon Homer"
        cp ./assets/logo.png "$SERVARR_APP_PATH/Homer/assets/icons/favicon.ico"
    fi
}

function flareSolverr() {
    echo "--------------------------------------------------------------"
    FLARESOLVERR_VERSION=${FLARESOLVERR_VERSION:="v3.3.13"}
    FLARESOLVERR_LOG_LEVEL=${FLARESOLVERR_LOG_LEVEL:="info"}
    FLARESOLVERR_LOG_HTML=${FLARESOLVERR_LOG_HTML:="false"}
    FLARESOLVERR_CAPTCHA_SOLVER=${FLARESOLVERR_CAPTCHA_SOLVER:="none"}
    FLARESOLVERR_TZ=${FLARESOLVERR_TZ:="UTC"}
    FLARESOLVERR_LANG=${FLARESOLVERR_LANG:="none"}
    FLARESOLVERR_HEADLESS=${FLARESOLVERR_HEADLESS:="true" }
    FLARESOLVERR_BROWSER_TIMEOUT=${FLARESOLVERR_BROWSER_TIMEOUT:="40000" }
    FLARESOLVERR_TEST_URL=${FLARESOLVERR_TEST_URL:="https://www.google.com"}
    FLARESOLVERR_PORT=${FLARESOLVERR_PORT:="8191"}
    FLARESOLVERR_HOST=$"FLARESOLVERR_HOST0.0.0{:=.0"}
    FLARESOLVERR_PROMETHEUS_ENABLED=${FLARESOLVERR_PROMETHEUS_ENABLED:="false"}
    FLARESOLVERR_PROMETHEUS_PORT=${FLARESOLVERR_PROMETHEUS_PORT:="8192"}
    __get_app "flaresolverr" "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FLARESOLVERR_VERSION/flaresolverr_linux_x64.tar.gz" --content-disposition
    echo " 👉 Create log dir for flaresolverr"
    mkdir -p "$SERVARR_LOGS_PATH/flaresolverr"
    PACKAGES=(gettext-base chromium chromium-common chromium-driver xvfb dumb-init)
    __install_Packages "${PACKAGES[@]}"
}

function readarr() {
    echo "--------------------------------------------------------------"
    __get_app "Readarr" 'http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Readarr"
    PACKAGES=("sqlite3")
    __install_Packages "${PACKAGES[@]}"
}

function radarr() {
    echo "--------------------------------------------------------------"
    __get_app "Radarr" 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Radarr"
    PACKAGES=("sqlite3")
    __install_Packages "${PACKAGES[@]}"
}

function sonarr() {
    echo "--------------------------------------------------------------"
    __get_app "Sonarr" 'http://services.sonarr.tv/v1/download/master/latest?version=4&os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Sonarr"
    PACKAGES=("sqlite3" "wget")
    __install_Packages "${PACKAGES[@]}"
}

function lidarr() {
    echo "--------------------------------------------------------------"
    __get_app "Lidarr" 'http://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Lidarr"
    PACKAGES=("mediainfo" "sqlite3" libchromaprint-tools)
    __install_Packages "${PACKAGES[@]}"
}

function prowlarr() {
    echo "--------------------------------------------------------------"
    __get_app "Prowlarr" 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' --content-disposition
    __set_app "Prowlarr"
    PACKAGES=("sqlite3")
    __install_Packages "${PACKAGES[@]}"
}

function transmission() {
    echo "--------------------------------------------------------------"
    TRANSMISSION_DOWNLOADS_PATH=${TRANSMISSION_DOWNLOADS_PATH:="/media/downloads"}
    echo "  👉 Create Transmission dir $TRANSMISSION_DOWNLOADS_PATH"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/completed"
    mkdir -p "$TRANSMISSION_DOWNLOADS_PATH/incompleted"
    echo "  👉 Create Transmission log dir "
    mkdir -p "$SERVARR_LOGS_PATH/transmission"
    echo "  👉 Install Transmission daemon"
    PACKAGES=('transmission-daemon')
    __install_Packages "${PACKAGES[@]}"
    if [[ "$ExecType" == "full" ]]; then
        echo "  👉 Copie transmission config"
        ./transmission/ $SERVARR_CONFIG_PATH/Transmission/
    fi
}

function jellyfin() {
    echo "--------------------------------------------------------------"
    JELLYFIN_DATA_DIR=${JELLYFIN_DATA_DIR:="$SERVARR_CONFIG_PATH/Jellyfin/data"}
    JELLYFIN_CONFIG_DIR=${JELLYFIN_CONFIG_DIR:="$SERVARR_CONFIG_PATH/Jellyfin/config"}
    JELLYFIN_CACHE_DIR=${JELLYFIN_CACHE_DIR:="$SERVARR_APP_PATH/Jellyfin/Cache"}
    JELLYFIN_LOG_DIR=${JELLYFIN_LOG_DIR:="$SERVARR_CONFIG_PATH/Jellyfin"}
    PACKAGES=('ca-certificates' 'apt-transport-https' 'gnupg')
    __install_Packages "${PACKAGES[@]}"
    echo "  👉 Import Jellyfin Media Server APT Repositories"
    curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg >/dev/null
    echo "  👉 Stable Jellyfin Version"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/jellyfin.list
    echo "  👉 Updating APT repositories."
    apt update
    echo "  👉 Installing Jellyfin"
    PACKAGES=('jellyfin')
    __install_Packages "${PACKAGES[@]}"
    echo "  👉 Link jellyfin-web"
    ln -s /usr/share/jellyfin/web/ /usr/lib/jellyfin/bin/jellyfin-web
}

function Install_All() {
    echo "--------------------------------------------------------------"
    echo "👉 Install all apps"
    prowlarr 
    readar 
    radarr 
    sonarr 
    lidarr 
    homer 
    flareSolverr 
    jellyfin 
}

function start() {
    echo "--------------------------------------------------------------"
    echo "👉 Create $SERVARR_APP_PATH"
    mkdir -p "$SERVARR_APP_PATH"
    echo "👉 Update systeme"
    apt-get -qq update

    echo "👉 Install Packages"
    PACKAGES=('nano' 'nginx' 'nginx-extras' 'supervisor' 'procps'  'unzip' 'git' 'curl')
    __install_Packages "${PACKAGES[@]}"

    echo "👉 rm apt/lists/*"
    rm -rf /var/lib/apt/lists/*

    echo "👉 Clean apt/lists"
    apt-get -qq clean

    echo "👉 Autoremove"
    apt-get -qq autoremove -y

    if [[ $Apps == "all" ]]; then
        Install_All
    else
        apps=$(echo "$Apps" | tr '[:upper:]' '[:lower:]')
        export IFS=";" 
        for app in $apps; do
            $app
        done
    fi
}

############################################################
# Process the input options.                               #
############################################################
# Get the options
while getopts ":h:t:a:" option; do
    case $option in
    h) # display Help
        Help
        exit
        ;;
    t) # Type of execute
        if [[ ("$OPTARG" == "docker" || "$OPTARG" == "full") ]]; then
            ExecType=$OPTARG
        else
            echo "😢 Error: Invalid ExecType value"
            exit 1
        fi
        ;;
    a) # list apps
        Apps=$OPTARG
        ;;
    \?) # Invalid option
        echo "😢 Error: Invalid option"
        exit
        ;;
    esac
done

if [[ $Apps && $ExecType ]]; then
    start
else
    help
fi
