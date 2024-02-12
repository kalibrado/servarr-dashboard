#!/bin/bash

echo "--> Update Nginx conf"
envsubst '$SERVARR_THEME $SERVARR_APP_DIR $SERVARR_LOG_DIR' < /etc/nginx/init-nginx.conf > /etc/nginx/nginx.conf

echo "--> Setup settings Transmission"
path_file="$SERVARR_CONF_DIR/Transmission/"
envsubst '$TRANSMISSION_COMPLETED_DIR $TRANSMISSION_INCOMPLETED_DIR $RPC_USERNAME $RPC_AUTH_REQUIRED $RPC_PASSWORD' < "$path_file/init-settings.json" > "$path_file/settings.json"

/usr/bin/transmission-daemon --foreground --config-dir "$SERVARR_CONF_DIR"/Transmission