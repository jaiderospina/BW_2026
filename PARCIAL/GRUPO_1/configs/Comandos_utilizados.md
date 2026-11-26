# Comandos utilizados en el laboratorio — Grupo 1

**Integrantes:** Juan Felipe Becerra Briceño, Fabiana Lopez Piñeros y Julián Camilo Moreno Valderrama.  
**Corte del material:** 25 de noviembre de 2026.

## Alcance y trazabilidad

Se transcriben comandos y fragmentos documentados en la conversación del laboratorio, las capturas y el Word base. Cuando un bloque de configuración procede del procedimiento indicado en la conversación, se cita además la comprobación posterior de su estado. Son fragmentos históricos, no una exportación completa de FortiOS. No se infieren comandos de configuración que no aparezcan en el material.

Los bloques contienen modificaciones realizadas durante el laboratorio, incluida la caída administrativa de port1. No forman una secuencia para aplicar de principio a fin. Los identificadores edit 1, edit 2 y edit 5 corresponden a los objetos de esa prueba; edit 0 se utilizó para crear objetos y no acredita sus ID finales.

Las direcciones WAN son concesiones observadas: sede port1 192.168.42.27, sucursal port1 192.168.42.111, sede port3 192.168.140.144 y sucursal port3 192.168.140.145. El frontal CLOUD-EDGE fue 192.168.42.84. No son IP fijas garantizadas después de restaurar.

## 1. Interfaces LAN, DHCP y WAN

### Sede: port2 con gateway fijo y DHCP para los clientes

Fragmento del procedimiento del mensaje 049; las capturas posteriores de interfaz/DHCP y la conectividad de PC1 corroboraron el resultado. Se conserva la corrección de filtro DHCP del mensaje 055. El diagnóstico inicial continuó hasta recuperar la conectividad; este fragmento no reconstruye todos los valores predeterminados del servidor.

~~~text
config system interface
    edit "port2"
        set alias "LAN"
        set mode static
        set ip 10.10.10.1 255.255.255.0
        set allowaccess ping http
        set role lan
        set status up
    next
end

config system dhcp server
    edit 1
        set status enable
        set interface "port2"
        set default-gateway 10.10.10.1
        set netmask 255.255.255.0
        set dns-service specify
        set dns-server1 8.8.8.8
        set dns-server2 1.1.1.1
        config ip-range
            edit 1
                set start-ip 10.10.10.100
                set end-ip 10.10.10.200
            next
        end
    next
end

config system dhcp server
    edit 1
        set vci-match disable
    next
end
~~~

En VPCS se utilizaron estos comandos para solicitar y comprobar la concesión:

~~~text
ip dhcp
show ip
ping 10.10.10.1
ping 8.8.8.8
ping google.com
~~~

La última revisión registrada, mensaje 364, obtuvo PC1 10.10.10.101/24, gateway 10.10.10.1, y PC-SUC 10.20.10.100/24, gateway 10.20.10.1. No se dispone de la configuración completa final del pool DHCP de FG-SUC para transcribirla. El gateway port2 de cada FortiGate permanece con IP fija; no se utilizó el cambio de port2 a cliente DHCP propuesto como explicación en el mensaje 367.

### Sede: configuración histórica de ISP2

Procedimiento del mensaje 072, seguido por captura de port3 y comprobación de salida WAN. Posteriormente se integró a SD-WAN y se igualaron prioridades; la distancia histórica de este bloque no representa por sí sola la selección final.

~~~text
config system interface
    edit "port1"
        set alias "ISP1"
        set distance 10
    next
    edit "port3"
        set alias "ISP2"
        set mode dhcp
        set defaultgw enable
        set distance 20
        set dns-server-override disable
        set role wan
        set status up
    next
end
~~~

Comandos usados para revisar interfaces, DHCP y rutas:

~~~text
get system interface physical
show system interface port2
show system dhcp server
get router info routing-table database
get router info routing-table all
~~~

La captura original del mensaje 252 confirma FG-SUC port1 y port3 en modo DHCP, y port2 estático en 10.20.10.1/24. Se conserva ese estado observado sin inventar el bloque completo con que se configuró el segundo borde.

### Sede: puerto del Data Center

Procedimiento del mensaje 173, con comprobación posterior del puerto en la evidencia 32:

~~~text
config system interface
    edit "port4"
        set mode static
        set ip 10.10.20.1 255.255.255.0
        set alias "DC"
        set role lan
        set allowaccess ping
        set status up
    next
end

show system interface port4
~~~

## 2. SD-WAN de sede y selección por calidad

Fragmentos de los mensajes 084, 086, 089 y 092; las capturas 05, 07 y 08 y el registro central posterior corroboran miembros y salud WAN. Se muestran el alta de miembros y los ajustes posteriores de costos/prioridad.

~~~text
config system sdwan
    set status enable
    config members
        edit 2
            set interface "port3"
            set zone "virtual-wan-link"
            set gateway 0.0.0.0
            set priority 20
        next
    end
end

config firewall policy
    edit 1
        set name "LAN_a_SDWAN"
        set dstintf "virtual-wan-link"
    next
end

config system sdwan
    config members
        edit 1
            set interface "port1"
            set zone "virtual-wan-link"
            set gateway 0.0.0.0
            set priority 1
        next
    end
end

config router static
    edit 1
        set dst 0.0.0.0 0.0.0.0
        set sdwan-zone "virtual-wan-link"
        set distance 10
    next
end
~~~

Monitor Internet_LAB:

~~~text
config system sdwan
    config health-check
        edit "Internet_LAB"
            set server "8.8.8.8" "1.1.1.1"
            set protocol ping
            set members 1 2
            set interval 1000
            set probe-timeout 1000
            set failtime 5
            set recoverytime 5
            set update-static-route enable
            config sla
                edit 1
                    set link-cost-factor latency jitter packet-loss
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
    end
end

config system interface
    edit "port3"
        set priority 1
    next
end

config system sdwan
    config members
        edit 1
            set priority 1
            set cost 10
        next
        edit 2
            set priority 1
            set cost 20
        next
    end
    config service
        edit 1
            set name "LAN_SLA"
            set mode sla
            set src "LAN_LAB"
            set dst "all"
            config sla
                edit "Internet_LAB"
                    set id 1
                next
            end
            set priority-members 1 2
        next
    end
end
~~~

Diagnósticos utilizados:

~~~text
diagnose sys sdwan member
diagnose sys sdwan health-check
diagnose sys sdwan service 1
~~~

La sucursal tiene los objetos Internet_SUC y SUC_SLA documentados por sus salidas. No se reconstruye su configuración completa por analogía con sede.

## 3. GRE y rutas entre sucursal y DC

### GRE-ISP1: extremos observados

Procedimiento del mensaje 208, confirmado por las capturas posteriores de los dos extremos y por el tráfico de la evidencia 42. GRE encapsula sin cifrar.

En sede:

~~~text
config system gre-tunnel
    edit "GRE-ISP1"
        set interface "port1"
        set local-gw 192.168.42.27
        set remote-gw 192.168.42.111
    next
end
~~~

En FG-SUC:

~~~text
config system gre-tunnel
    edit "GRE-ISP1"
        set interface "port1"
        set local-gw 192.168.42.111
        set remote-gw 192.168.42.27
    next
end
~~~

Rutas del procedimiento del mensaje 210. El estado posterior muestra la ruta principal con distancia 10; el fragmento original no especificaba una distancia explícita.

En FG-SUC:

~~~text
config router static
    edit 0
        set dst 10.10.20.0 255.255.255.0
        set device "GRE-ISP1"
    next
end
~~~

En sede:

~~~text
config router static
    edit 0
        set dst 10.20.10.0 255.255.255.0
        set device "GRE-ISP1"
    next
end
~~~

La prueba inicial de PC-SUC usó temporalmente la IP estática siguiente; fue sustituida posteriormente por DHCP:

~~~text
ip 10.20.10.10/24 10.20.10.1
ping 10.20.10.1
ping 10.10.20.10
~~~

Sniffer utilizado en sede y mostrado en la evidencia 42:

~~~text
diagnose sniffer packet any 'icmp and host 10.20.10.10 and host 10.10.20.10' 4 20 1
~~~

### GRE-ISP2: túnel de respaldo

Procedimientos de los mensajes 253, 256 y 259. Las capturas posteriores muestran dos túneles, ping interno 5 de 5 y ruta de respaldo. Las direcciones /32 y remote-ip se conservan tal como aparecen en el procedimiento original.

En sede:

~~~text
config system gre-tunnel
    edit "GRE-ISP2"
        set interface "port3"
        set local-gw 192.168.140.144
        set remote-gw 192.168.140.145
    next
end

config system interface
    edit "GRE-ISP2"
        set ip 10.255.2.1 255.255.255.255
        set remote-ip 10.255.2.2 255.255.255.252
        set allowaccess ping
    next
end

config router static
    edit 0
        set dst 10.20.10.0 255.255.255.0
        set device "GRE-ISP2"
        set distance 20
    next
end
~~~

En FG-SUC:

~~~text
config system gre-tunnel
    edit "GRE-ISP2"
        set interface "port3"
        set local-gw 192.168.140.145
        set remote-gw 192.168.140.144
    next
end

config system interface
    edit "GRE-ISP2"
        set ip 10.255.2.2 255.255.255.255
        set remote-ip 10.255.2.1 255.255.255.252
        set allowaccess ping
    next
end

config router static
    edit 0
        set dst 10.10.20.0 255.255.255.0
        set device "GRE-ISP2"
        set distance 20
    next
end

execute ping-options reset
execute ping-options source 10.255.2.2
execute ping 10.255.2.1
execute ping-options reset
~~~

Keepalive aplicado al principal en ambos bordes, mensaje 262, con salidas posteriores alive:

~~~text
config system gre-tunnel
    edit "GRE-ISP1"
        set keepalive-interval 2
        set keepalive-failtimes 3
    next
end

diagnose sys gre list
diagnose sys gre keepalive all
get router info routing-table database
~~~

## 4. Seguridad: NAT de salida y servicios entre sitios

La política inicial LAN_a_ISP1 del mensaje 069 utilizó NAT. Después la política ID 1 se adaptó a virtual-wan-link, como consta en la sección SD-WAN. Estos son los fragmentos de creación originales, no dos políticas finales independientes.

~~~text
config firewall address
    edit "LAN_LAB"
        set subnet 10.10.10.0 255.255.255.0
    next
end

config firewall policy
    edit 0
        set name "LAN_a_ISP1"
        set srcintf "port2"
        set dstintf "port1"
        set srcaddr "LAN_LAB"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat enable
        set logtraffic all
        set status enable
    next
end
~~~

La política inicial del mensaje 210 permitió PING por GRE sin NAT. En FG-SUC:

~~~text
config firewall policy
    edit 0
        set name "SUC_PING_DC"
        set srcintf "port2"
        set dstintf "GRE-ISP1"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "PING"
        set nat disable
    next
end
~~~

En sede:

~~~text
config firewall policy
    edit 0
        set name "GRE_PING_DC"
        set srcintf "GRE-ISP1"
        set dstintf "port4"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "PING"
        set nat disable
    next
end
~~~

Se añadió HTTP conservando PING. El mensaje 222 identifica la política 5 de sede; el 227 confirma la política 2 de FG-SUC y la corrección tras el timeout inicial. HTTP respondió posteriormente en las evidencias 46–49.

En sede:

~~~text
config firewall policy
    edit 5
        set service "PING" "HTTP"
    next
end
~~~

En FG-SUC:

~~~text
show firewall policy | grep -f "SUC_PING_DC"

config firewall policy
    edit 2
        set service "PING" "HTTP"
    next
end
~~~

Políticas del respaldo, mensaje 259, con ruta y aplicación posteriores comprobadas:

En FG-SUC:

~~~text
config firewall policy
    edit 0
        set name "SUC_DC_ISP2"
        set srcintf "port2"
        set dstintf "GRE-ISP2"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "PING" "HTTP"
        set nat disable
    next
end
~~~

En sede:

~~~text
config firewall policy
    edit 0
        set name "ISP2_AL_DC"
        set srcintf "GRE-ISP2"
        set dstintf "port4"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "PING" "HTTP"
        set nat disable
    next
end
~~~

El registro tcp-80-vs-8080.json conserva la activación temporal del servidor de prueba y las consultas siguientes. El servicio 8080 se retiró después; no forma parte del estado final.

En DC-SRV:

~~~sh
/gns3/bin/busybox timeout 35 /gns3/bin/busybox httpd -f -p 10.10.20.10:8080 -h /root/dc-web-lab
curl --noproxy "*" -fsS --max-time 2 -o /dev/null -w "DC_LOCAL_8080=%{http_code}\n" http://10.10.20.10:8080/
~~~

La orden httpd es el comando de servicio incluido dentro del bloque de lanzamiento en segundo plano del registro, no un script autónomo de prueba. En el cliente de sucursal:

~~~sh
ip -4 route get 10.10.20.10
curl --noproxy "*" -fsS --max-time 5 -o /dev/null -w "SUC_80=%{http_code}\n" http://10.10.20.10/
echo "EXIT_80=$?"
curl --noproxy "*" -fsS --connect-timeout 3 --max-time 5 -o /dev/null -w "SUC_8080=%{http_code}\n" http://10.10.20.10:8080/
echo "EXIT_8080=$?"
~~~

Se observó HTTP 200 en local:8080 y desde sucursal:80; sucursal:8080 agotó la espera. No hay log de descarte que permita atribuirlo a un firewall específico.

## 5. HTTP, archivos persistentes y rutas Linux

### DC-SRV y cliente de sucursal

Procedimientos de los mensajes 219 y 222; las respuestas se conservaron en las capturas de HTTP y verification-after-restart.json.

En DC-SRV:

~~~sh
mkdir -p /root/dc-web-lab
printf '<h1>Data Center - Laboratorio Banda Ancha</h1>\n' > /root/dc-web-lab/index.html
/gns3/bin/busybox httpd -p 10.10.20.10:80 -h /root/dc-web-lab
curl -fsS http://10.10.20.10/
~~~

En webterm1-2:

~~~sh
ip link set eth0 up
ip addr add 10.20.10.20/24 dev eth0
ip route replace 10.10.20.0/24 via 10.20.10.1
curl -fsS --max-time 5 http://10.10.20.10/
~~~

Comandos presentes en la verificación posterior al reinicio:

~~~sh
hostname
ip -4 addr show dev eth0
ip -4 route
/gns3/bin/busybox netstat -lnt
curl --noproxy "*" -fsS --max-time 5 -D - http://10.10.20.10/
~~~

Los archivos interfaces-DC-SRV.txt e interfaces-webterm1-2-routed-cloud.txt incluidos en esta carpeta conservan el arranque persistente, sin reconstruirlo de memoria.

### CLOUD-SRV y CLOUD-EDGE

Los archivos de referencia suministrados contienen los comandos de arranque:

~~~sh
/gns3/bin/busybox httpd -p 10.30.10.10:80 -h /root/cloud-web
/bin/sh /root/cloud-ingress.sh
~~~

CLOUD-EDGE publica TCP/80 mediante el script cloud-ingress.sh suministrado. Su contenido exacto, que invoca socat, se entrega por separado; no se simplifica como si constituyera un servicio cloud público.

En la prueba final de destino enrutado se usaron estos comandos. El registro incluido [sdwan-http-nube-destino-enrutado.json](../registros/sdwan-http-nube-destino-enrutado.json) permite revisar la ruta y la respuesta HTTP. El documento de cierre recibido se utilizó como fuente de estos fragmentos y no forma parte de esta carpeta:

~~~sh
ip -4 addr show dev eth0
sysctl -w net.ipv4.ip_forward=1
ip route replace 10.30.10.10/32 via 10.20.10.1 dev eth0
curl --noproxy '*' -fsS --max-time 8 -o /dev/null -w 'HTTP %{http_code}\n' http://10.30.10.10/
~~~

El comando sysctl corresponde a CLOUD-EDGE; la ruta /32 y el curl corresponden a webterm1-2. El archivo interfaces-CLOUD-EDGE-routed-cloud.txt conserva además post-up echo 1 > /proc/sys/net/ipv4/ip_forward. Los últimos ajustes persistentes fueron leídos y comprobados, pero no consta un nuevo reinicio después de ellos.

## 6. Regla SD-WAN para HTTP hacia la nube

El mensaje 300 documentó la creación de HTTP_NUBE_ISP1 para el frontal .84. Las pruebas iniciales respondieron por una ruta directamente conectada y su contador quedó en cero; por tanto, ese destino se sustituyó después. Se transcribe la creación histórica para explicar el cambio, no como la configuración final del destino.

En FG-SUC:

~~~text
config firewall address
    edit "SDWAN_NUBE"
        set subnet 192.168.42.84 255.255.255.255
    next
    edit "SDWAN_LAN_SUC"
        set subnet 10.20.10.0 255.255.255.0
    next
end

config system sdwan
    config service
        edit 2
            set name "HTTP_NUBE_ISP1"
            set mode manual
            set src "SDWAN_LAN_SUC"
            set dst "SDWAN_NUBE"
            set protocol 6
            set start-port 80
            set end-port 80
            set priority-members 1
        next
        move 2 before 1
    end
end
~~~

Ajuste final transcrito del documento de cierre recibido y corroborado por la [captura 70](../img/70-SDWAN-HTTP-nube-regla-2-coincidencia-ISP1.png), con hit_count=1, y el [registro HTTP](../registros/sdwan-http-nube-destino-enrutado.json) a 10.30.10.10:

~~~text
config router static
    edit 0
        set dst 10.30.10.10 255.255.255.255
        set gateway 192.168.42.84
        set device "port1"
        set comment "CLOUD-SRV via CLOUD-EDGE"
    next
end

config firewall address
    edit "SDWAN_CLOUD_SRV"
        set subnet 10.30.10.10 255.255.255.255
    next
end

config system sdwan
    config service
        edit 2
            set dst "SDWAN_CLOUD_SRV"
            set gateway disable
            set default disable
        next
    end
end

get router info routing-table all | grep "10.30.10.10"
diagnose firewall proute list
~~~

La clasificación comprobada utiliza IP y puerto TCP/80. No acredita reconocimiento profundo de aplicaciones ni conmutación de la nube a ISP2.

## 7. QoS: perfil y mediciones

Procedimientos de los mensajes 275, 280, 285 y 288. Las capturas 61–64 y shaper-session-check.json corroboran las descargas y la asignación del perfil.

Límites declarados sucesivamente en port2 de FG-SUC:

~~~text
config system interface
    edit "port2"
        set outbandwidth 8000
    next
end
~~~

Perfil y política de prioridad de retorno del DC:

~~~text
config firewall address
    edit "QOS_DC_SRV"
        set subnet 10.10.20.10 255.255.255.255
    next
end

config firewall shaper traffic-shaper
    edit "QOS_DC_ALTA"
        set bandwidth-unit kbps
        set guaranteed-bandwidth 2000
        set maximum-bandwidth 8000
        set priority high
    next
end

config firewall shaping-policy
    edit 0
        set name "QOS_HTTP_DC"
        set srcintf "port2"
        set dstintf "GRE-ISP1"
        set srcaddr "all"
        set dstaddr "QOS_DC_SRV"
        set service "HTTP"
        set schedule "always"
        set traffic-shaper-reverse "QOS_DC_ALTA"
    next
end
~~~

Para la segunda comparación se utilizó 4000 y se deshabilitó/reactivó la política identificada como ID 1:

~~~text
config system interface
    edit "port2"
        set outbandwidth 4000
    next
end

config firewall shaping-policy
    edit 1
        set status disable
    next
end
~~~

Después de la corrida de referencia:

~~~text
config firewall shaping-policy
    edit 1
        set status enable
    next
end
~~~

Archivo de prueba creado en DC-SRV:

~~~sh
dd if=/dev/zero of=/root/dc-web-lab/archivo-qos-dc.bin bs=1M count=4
~~~

Bloque de descargas simultáneas utilizado en webterm1-2:

~~~sh
curl -fsS --max-time 90 -o /dev/null \
  -w 'NUBE: HTTP %{http_code} | %{size_download} bytes | %{time_total} s\n' \
  http://192.168.42.84/archivo-qos.bin &
nube=$!

sleep 1
curl -fsS --max-time 90 -o /dev/null \
  -w 'DC: HTTP %{http_code} | %{size_download} bytes | %{time_total} s\n' \
  http://10.10.20.10/archivo-qos-dc.bin

wait "$nube"
~~~

Diagnóstico que produjo el registro de sesión:

~~~text
diagnose sys session list
~~~

El registro muestra reply-shaper=QOS_DC_ALTA, prio=2 y shaping_policy_id=1. Son distintos de una mejora medida: las descargas del DC pasaron de 9.309107 a 10.015249 s a 8 Mbps y de 21.120041 a 22.543627 s a 4 Mbps. No se conoce una comparación completa de nube a 4 Mbps sin prioridad ni repeticiones controladas suficientes.

## 8. Prueba de caída y retorno del acceso al DC

Procedimiento del mensaje 264; capturas 50–55. La modificación se hizo en FG-SUC, no simultáneamente en ambos bordes.

En webterm1-2:

~~~sh
while true; do
  printf '%s ' "$(date +%H:%M:%S)"
  curl -s --max-time 2 -o /dev/null -w 'HTTP %{http_code}\n' http://10.10.20.10/
  sleep 1
done
~~~

En FG-SUC se desactivó port1:

~~~text
config system interface
    edit "port1"
        set status down
    next
end

get router info routing-table all | grep "10.10.20.0"
~~~

Después se restauró port1 y se consultó la ruta principal:

~~~text
config system interface
    edit "port1"
        set status up
    next
end

diagnose sys gre keepalive all
get router info routing-table all | grep "10.10.20.0"
~~~

El sondeo se detuvo con Ctrl+C. La evidencia muestra tres intentos HTTP fallidos y recuperación por GRE-ISP2, seguida del retorno a GRE-ISP1. Los 7 s registrados se miden entre inicios de intentos, no desde un instante instrumentado de caída.

## 9. Supervisión central de los dos bordes

El archivo gestionar-bordes.ps1 se incluye sin modificaciones. El guion documentó esta invocación desde la carpeta que contiene el script, con ambas consolas previamente autenticadas:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\gestionar-bordes.ps1 -EsperaPromptSegundos 2 -SondearPrompt
~~~

El registro exitoso histórico contiene estas tres consultas en sede y en FG-SUC:

~~~text
diagnose sys sdwan member
diagnose sys sdwan health-check
diagnose sys gre keepalive all
~~~

La corrida de las 16:44 obtuvo seis resultados LEIDO. El intento anterior de las 16:38 omitió equipos por login/prompt. La revisión posterior de las 19:05 solo completó FG-SUC y no sustituye el registro de seis lecturas.

Durante la preparación de esta carpeta no se ejecutaron el script, los bloques de configuración ni las órdenes de servicio. La función central demostrada es lectura de estados; no existe evidencia de distribución o sincronización centralizada de políticas.

## 10. Límites de reconstrucción

Estos fragmentos no contienen todas las rutas, objetos, pools DHCP, valores predeterminados, orden de políticas ni configuraciones completas del estado final. Tampoco incluyen discos FortiGate, imágenes Docker, volúmenes persistentes ni el archivo nativo de los 16 nodos y 13 enlaces.

Se requiere el export portable actualizado de GNS3 y una restauración comprobada para entregar una simulación reproducible completa. El Word base, las capturas y los registros explican la implementación y sus pruebas; no sustituyen ese export. No se incorporaron contraseñas, claves, tokens ni rutas absolutas del computador de origen.
