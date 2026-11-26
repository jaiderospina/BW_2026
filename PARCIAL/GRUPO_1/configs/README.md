# Configuraciones y comandos recuperados — Grupo 1

**Integrantes:** Juan Felipe Becerra Briceño, Fabiana Lopez Piñeros y Julián Camilo Moreno Valderrama.

Esta carpeta reúne archivos técnicos suministrados y fragmentos de comandos del laboratorio. No constituye un backup completo de los FortiGate ni un proyecto GNS3 restaurable. Los archivos copiados conservan su nombre y contenido original; no se ejecutaron durante la preparación de la entrega.

## Archivos

| Archivo | Función y procedencia |
|---|---|
| gestionar-bordes.ps1 | Script suministrado de supervisión. Consulta el inventario de GNS3 mediante GET y lee tres diagnósticos por FortiGate mediante su consola Telnet. No inicia sesión, no incluye contraseñas y no cambia configuración. |
| Comandos_utilizados.md | Fragmentos reales documentados, contexto de ejecución y evidencia posterior. Conserva los cambios históricos que explican los resultados. No se debe aplicar como una secuencia de restauración. |
| Referencias-tecnicas/docker-http-persistence/interfaces-DC-SRV.txt | Contenido suministrado para /etc/network/interfaces de DC-SRV: IP, gateway y arranque HTTP. |
| Referencias-tecnicas/cloud-lab/interfaces-CLOUD-SRV.txt | Contenido suministrado para /etc/network/interfaces de CLOUD-SRV: IP, gateway y arranque HTTP. |
| Referencias-tecnicas/cloud-lab/interfaces-CLOUD-EDGE-routed-cloud.txt | Contenido suministrado para /etc/network/interfaces de CLOUD-EDGE: WAN DHCP, red cloud y reenvío IPv4. |
| Referencias-tecnicas/cloud-lab/interfaces-webterm1-2-routed-cloud.txt | Contenido suministrado para /etc/network/interfaces del cliente de sucursal: IP fija .20 y rutas específicas. |
| Referencias-tecnicas/cloud-lab/cloud-ingress.sh | Dependencia de arranque invocada desde CLOUD-EDGE como /root/cloud-ingress.sh. Detecta su IP de ISP1 y publica TCP/80 mediante socat hacia CLOUD-SRV. |

Los nombres de archivo describen su destino original; no deben confundirse con archivos de configuración completos de GNS3.

## Parámetros dependientes del laboratorio

El script de supervisión conserva la API privada 192.168.232.1:3080, la identificación del proyecto original y los nombres FortiGate7.2.0x-1 y FG-SUC. Requiere el entorno GNS3 accesible y las dos consolas ya autenticadas en un prompt # vacío. Esos datos son referencias del laboratorio, no credenciales. El script puede omitir un equipo si no encuentra ese prompt.

La ejecución histórica del 25/11 a las 16:44 completó seis consultas; la revisión posterior solo completó tres de FG-SUC porque la consola de sede no estaba lista. Esa ejecución posterior no cuenta con un archivo de registro bruto nuevo en el material suministrado.

Las IP WAN y el frontal de CLOUD-EDGE son concesiones observadas. Los extremos GRE y la ruta cloud dependen de ellas. Verificarlas tras restaurar antes de intentar repetir las pruebas. Las últimas concesiones registradas de los VPCS fueron PC1 10.10.10.101/24 y PC-SUC 10.20.10.100/24; port2 conserva la puerta de enlace fija .1 en cada LAN. La IP 10.10.10.101 de webterm1-1 corresponde a una prueba anterior, no se presenta como simultánea a la concesión final de PC1.

## Lo que requiere el export de GNS3

No se pueden reconstruir íntegramente desde estos fragmentos el proyecto de 16 nodos y 13 enlaces, UUID y cableado nativo, discos de las VM, imágenes base, volúmenes Docker, ajustes de cada plantilla, orden final de todas las políticas, pools DHCP completos de ambos equipos ni toda la configuración efectiva de FortiOS.

También faltan el export portable actualizado, sus dependencias y una restauración de prueba. La persistencia HTTP de DC-SRV y el cliente tuvo una prueba de reinicio previa. Los últimos cambios de ruta hacia 10.30.10.10 y de reenvío IPv4 cloud se guardaron y verificaron por lectura; no consta un nuevo reinicio posterior para validar ese estado final.

GRE se implementó sin cifrado. El perfil QoS se identificó en una sesión, pero las corridas no mostraron mejora. No hay controlador que distribuya políticas ni evidencia de continuidad de la aplicación cloud ante caída de ISP1.