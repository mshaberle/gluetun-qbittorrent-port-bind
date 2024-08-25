#!/bin/sh

COOKIES="/tmp/cookies.txt"

GLUETUN_URL="http://$GLUETUN_SERVER:$GLUETUN_PORT/v1/openvpn/portforwarded"

QBITTORRENT_URL="http://$QBITTORRENT_SERVER:$QBITTORRENT_PORT/api/v2"

function GetQBitPort {
	qBitPort=$(curl -s -S -b ${COOKIES} ${QBITTORRENT_URL}/app/preferences | jq -r '.listen_port')
	echo "Got qBittorrent port! (${qBitPort})"
}

function SetQBitPort {
	curl -s -S -b ${COOKIES} --data 'json={"listen_port":"'"$gluetunPort"'"}' ${QBITTORRENT_URL}/app/setPreferences
	echo "Changed qBittorrent port to ${gluetunPort}!"
}

function GetSID {
	curl -s -S -c ${COOKIES} --data "username=$QBITTORRENT_USERNAME&password=$QBITTORRENT_PASSWORD" ${QBITTORRENT_URL}/auth/login
	
	if grep -q SID ${COOKIES}; then
		echo "Successfully logged in to qBittorrent!"
	else
		echo "Failed to login to qBittorrent!"
		exit 1
	fi
}

function GetGluetunPort {
	gluetunPort=$(curl -s -S ${GLUETUN_URL} | jq -r '.port')
	echo "Got Gluetun port! (${gluetunPort})"
}

GetSID
GetQBitPort

GetGluetunPort

if [[ $gluetunPort -ne $qBitPort ]]; then
	echo "The qBittorrent port does not match the Gluetun port! Changing ports!"
	SetQBitPort
fi

rm -f /tmp/cookies.txt
