#!/bin/bash
set -e

SERVARR_CONFIG_PATH=${SERVARR_CONFIG_PATH:="/config"}
TRANSMISSION_DOWNLOADS_PATH=${TRANSMISSION_DOWNLOADS_PATH:="/media/downloads"}
TRANSMISSION_USER=${TRANSMISSION_USER:="transmission"}
TRANSMISSION_PASS=${TRANSMISSION_PASS:="transmission"}
TRANSMISSION_AUTH=${TRANSMISSION_AUTH:="true"}

echo "--> Setup settings Transmission"
sed -i "s|"download-dir":|"download-dir": "$TRANSMISSION_DOWNLOADS_PATH/completed,"|g" $SERVARR_CONFIG_PATH/Tranmission/settings.json
sed -i "s|"incomplete-dir":|"incomplete-dir": "$TRANSMISSION_DOWNLOADS_PATH/incompleted,"|g" $SERVARR_CONFIG_PATH/Tranmission/settings.json
sed -i "s|"rpc-authentication-required":|"rpc-authentication-required": $TRANSMISSION_AUTH","|g" $SERVARR_CONFIG_PATH/Tranmission/settings.json
sed -i "s|"rpc-username":|"rpc-username": "$TRANSMISSION_USER,"|g" $SERVARR_CONFIG_PATH/Tranmission/settings.json
sed -i "s|"rpc-password":|"rpc-password": "$TRANSMISSION_PASS,"|g" $SERVARR_CONFIG_PATH/Tranmission/settings.json

