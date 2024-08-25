FROM alpine:3.14

ENV GLUETUN_SERVER=localhost \
    GLUETUN_PORT=8000 \
    QBITTORRENT_SERVER=localhost \
    QBITTORRENT_PORT=8080 \
    QBITTORRENT_USERNAME=admin \
    QBITTORRENT_PASSWORD=adminadmin

COPY port-refresh.sh /port-refresh.sh

RUN chmod +x /port-refresh.sh \
	&& echo '*  *  *  *  *    /bin/sh /port-refresh.sh' > /etc/crontabs/root \
	&& apk add --no-cache curl jq \
	&& rm -rf /var/cache/apk/*

CMD ["crond", "-f"]
