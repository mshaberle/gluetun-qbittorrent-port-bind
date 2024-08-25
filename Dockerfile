FROM alpine:3.14

ENV GLUETUN_SERVER=localhost
ENV GLUETUN_PORT=8000

ENV QBITTORRENT_SERVER=localhost
ENV QBITTORRENT_PORT=8080
ENV QBITTORRENT_USERNAME=admin
ENV QBITTORRENT_PASSWORD=adminadmin

COPY port-refresh.sh /port-refresh.sh

RUN chmod +x /port-refresh.sh \
	&& echo '*  *  *  *  *    /bin/sh /port-refresh.sh' > /etc/crontabs/root \
	&& apk add --no-cache curl jq \
	&& rm -rf /var/cache/apk/*

CMD ["crond", "-f"]
