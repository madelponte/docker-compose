#!/bin/sh

for i in server control; do
	if [ ! -f /etc/unbound/unbound_$i.key ] ||
		[ ! -f /etc/unbound/unbound_$i.pem ]; then
			unbound-control-setup && break
	fi
done

unbound-anchor -a /etc/unbound/root.key
chown -R unbound:unbound /etc/unbound

exec unbound -dp
