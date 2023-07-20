FROM alpine

RUN apk add --no-cache unbound openssl wget

RUN wget -S https://www.internic.net/domain/named.root -O /etc/unbound/root.hints

COPY scripts /usr/local/bin

COPY ./unbound.conf /etc/unbound/unbound.conf

RUN unbound-checkconf

EXPOSE 53/tcp
EXPOSE 53/udp

WORKDIR /etc/unbound

ENTRYPOINT [ "entrypoint.sh" ]
