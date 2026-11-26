#!/bin/sh
set -eu
wan_ip=
for attempt in $(seq 1 15); do
    wan_ip=$(/sbin/ip -4 -o addr show dev eth0 scope global | awk 'NR == 1 {split($4,a,"/"); print a[1]}')
    case "$wan_ip" in 192.168.42.*) break ;; esac
    sleep 1
done
case "$wan_ip" in
    192.168.42.*) ;;
    *) echo "CLOUD-EDGE: no hay IP en el segmento simulado ISP1" >&2; exit 1 ;;
esac
exec /sbin/start-stop-daemon --start --quiet --oknodo --background --make-pidfile --pidfile /run/cloud-ingress.pid --exec /usr/bin/socat -- "TCP4-LISTEN:80,bind=$wan_ip,reuseaddr,fork" "TCP4:10.30.10.10:80,connect-timeout=4"
