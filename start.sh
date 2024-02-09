#!/bin/bash


SERVARR_CONFIG_PATH=${SERVARR_CONFIG_PATH:="/config"}
TRANSMISSION_DOWNLOADS_PATH=${TRANSMISSION_DOWNLOADS_PATH:="/media/downloads"}
TRANSMISSION_USER=${TRANSMISSION_USER:="transmission"}
TRANSMISSION_PASS=${TRANSMISSION_PASS:="transmission"}
TRANSMISSION_AUTH=${TRANSMISSION_AUTH:="true"}

echo "--> Update Nginx conf"
envsubst '$SERVARR_THEME $SERVARR_APP_PATH' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

echo "--> Setup settings Transmission"
_get_prev_json(){
    grep "$1"  "$SERVARR_CONFIG_PATH/Transmission/settings.json"  | head -n 1 | cut -d ":" -f2 | cut -d "," -f1
}

last_download_dir=$(_get_prev_json "download-dir")
last_incomplete_dir=$(_get_prev_json "incomplete-dir")
last_rpc_authentication_required=$(_get_prev_json "rpc-authentication-required")
last_rpc_username=$(_get_prev_json "rpc-username")
last_rpc_password=$(_get_prev_json "rpc-password")

sed -i "s|\"download-dir\":$last_download_dir,|\"download-dir\": \"$TRANSMISSION_DOWNLOADS_PATH/completed\",|g" "$SERVARR_CONFIG_PATH/Transmission/settings.json"
sed -i "s|\"incomplete-dir\":$last_incomplete_dir,|\"incomplete-dir\": \"$TRANSMISSION_DOWNLOADS_PATH'/incompleted\",|g" "$SERVARR_CONFIG_PATH/Transmission/settings.json"
sed -i "s|\"rpc-authentication-required\":last_rpc_authentication_required', |\"rpc-authentication-required\": $TRANSMISSION_AUTH,|g" "$SERVARR_CONFIG_PATH/Transmission/settings.json"
sed -i "s|\"rpc-username\":$last_rpc_username,|\"rpc-username\": \"$TRANSMISSION_USER\",|g" "$SERVARR_CONFIG_PATH/Transmission/settings.json"
sed -i "s|\"rpc-password\":$last_rpc_password,|\"rpc-password\": \"$TRANSMISSION_PASS\",|g" "$SERVARR_CONFIG_PATH/Transmission/settings.json"

/usr/bin/transmission-daemon --foreground --config-dir "$SERVARR_CONFIG_PATH"/Transmission