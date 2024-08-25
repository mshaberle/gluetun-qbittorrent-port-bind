# Gluetun qBittorrent Port Bind

This utility was created to bind the forwarded port from Gluetun to qBittorrent using the provided APIs from both utilities. This is intended to work with containerized Gluetun and qBittorrent applications.

The provided refresh script is run by cron once a minute.


## Deployment

To deploy this image by itself create a docker compose entry like so:

```
services:
  gluetun-qbittorrent-port-bind:
    image: mhabes/gluetun-qbittorrent-port-bind:latest
    container_name: gluetun-qbittorrent-port-bind
    network_mode: "container:gluetun"
    environment:
      - GLUETUN_SERVER=localhost
      - GLUETUN_PORT=8000
      - QBITTORRENT_SERVER=localhost
      - QBITTORRENT_PORT=8080
      - QBITTORRENT_USERNAME=admin
      - QBITTORRENT_PASSWORD=adminadmin
    restart: unless-stopped
```

To deploy this image in a stack with gluetun and qbittorrent create a docker compose entry like so:

```
services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8080:8080 # Allow for access to qBittorrent web ui
      - 8888:8888/tcp # HTTP proxy
      - 8388:8388/tcp # Shadowsocks
      - 8388:8388/udp # Shadowsocks
    environment:
      # See https://github.com/qdm12/gluetun-wiki/tree/main/setup#setup
      - VPN_SERVICE_PROVIDER=protonvpn
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=#YOURPRIVATEKEYHERE
      - PORT_FORWARD_ONLY=on
      - VPN_PORT_FORWARDING=on
      - VPN_PORT_FORWARDING_PROVIDER=protonvpn
      - TZ=#YOURTZHERE
      - UPDATER_PERIOD=24h
    volumes:
      - /config/to/gluetun:/gluetun
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    environment:
      - TZ=#YOURTZHERE
      - WEBUI_PORT=8080
      - PUID=1000
      - PGID=1000
    volumes:
      - /config/to/qbittorrent:/config
      - /path/to/downloads:/downloads
    restart: unless-stopped

  gluetun-qbittorrent-port-bind:
    image: mhabes/gluetun-qbittorrent-port-bind:latest
    container_name: gluetun-qbittorrent-port-bind
    network_mode: "service:gluetun"
    environment:
      - GLUETUN_SERVER=localhost
      - GLUETUN_PORT=8000
      - QBITTORRENT_SERVER=localhost
      - QBITTORRENT_PORT=8080
      - QBITTORRENT_USERNAME=admin
      - QBITTORRENT_PASSWORD=adminadmin
    restart: unless-stopped
```


## Environment Variables

| Evironment Variable | Purpose |
| :----: | --- |
| `GLUETUN_SERVER` | The address of the Gluetun container |
| `GLUETUN_PORT` | The port for the Gluetun Control Server |
| `QBITTORRENT_SERVER` | The address of the qBittorrent instance |
| `QBITTORRENT_PORT` | The port for the qBittorrent Web UI |
| `QBITTORRENT_USERNAME` | The username for the qBittorrent Web UI |
| `QBITTORRENT_PASSWORD` | The password for the qBittorrent Web UI |
