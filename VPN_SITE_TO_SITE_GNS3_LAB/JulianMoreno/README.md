# Laboratorio VPN IPsec sitio a sitio en GNS3

**Estudiante:** Julián Camilo Moreno Valderrama  
**Herramientas:** GNS3 y routers Cisco 7200 con IOS 15.2(4)M7.  
**Guía:** [VPN_SITE_TO_SITE_GNS3_LAB](../README.md).

## Objetivo

Configurar y comprobar una VPN IPsec entre R1 y R2. La VPN protege el tráfico entre `1.1.1.0/24` y `2.2.2.0/24`. En cada lado se configuró además una red interna: OSPF entre R1, R3 y R4; EIGRP entre R2, R5 y R6.

## 1. Topología y direcciones

La siguiente captura muestra el proyecto al abrirlo, antes de encender y configurar los routers. El enlace central une R1 con R2; Cloud-1 aparece conectado a R6 por VMnet8.

![Topología inicial del proyecto](img/01-topologia.png)

| Router | Interfaz | Dirección | Conexión |
| --- | --- | --- | --- |
| R1 | GigabitEthernet1/0 | `12.1.1.1/24` | R2, extremo de la VPN |
| R1 | Loopback0 | `1.1.1.1/24` | Red protegida izquierda |
| R1 | GigabitEthernet3/0 | `13.1.1.1/24` | R3 |
| R1 | GigabitEthernet4/0 | `14.1.1.1/24` | R4 |
| R2 | GigabitEthernet1/0 | `12.1.1.2/24` | R1, extremo de la VPN |
| R2 | Loopback0 | `2.2.2.1/24` | Red protegida derecha |
| R2 | GigabitEthernet5/0 | `25.1.1.2/24` | R5 |
| R2 | GigabitEthernet6/0 | `26.1.1.2/24` | R6 |
| R3 | GigabitEthernet3/0 | `13.1.1.3/24` | R1 |
| R4 | GigabitEthernet4/0 | `14.1.1.4/24` | R1 |
| R5 | GigabitEthernet5/0 | `25.1.1.5/24` | R2 |
| R6 | GigabitEthernet6/0 | `26.1.1.6/24` | R2 |

La guía no especifica las direcciones de R3, R4, R5 y R6. Se eligieron direcciones disponibles dentro de los segmentos indicados por las interfaces de R1 y R2.

## 2. Interfaces y enlace entre R1 y R2

Se asignó `12.1.1.1/24` a R1 y `12.1.1.2/24` a R2. Las loopbacks representan las redes que se van a proteger. Se habilitaron las interfaces con `no shutdown` y se guardaron los cambios con `write memory`.

![Interfaces activas de R1](img/02-r1-interfaces.png)

![Interfaces activas de R2](img/03-r2-interfaces.png)

El ping desde R2 a `12.1.1.1` respondió **5 de 5**. Esto comprobó el enlace físico antes de configurar el cifrado.

![Prueba del enlace R2 a R1](img/04-enlace-r2-r1.png)

## 3. Rutas hacia la red remota

Cada router necesita una ruta hacia la red protegida del otro extremo. Se configuraron estas rutas estáticas:

```text
R1: ip route 2.2.2.0 255.255.255.0 12.1.1.2
R2: ip route 1.1.1.0 255.255.255.0 12.1.1.1
```

Las consultas de la tabla de rutas mostraron el siguiente salto correcto en ambos routers.

![Ruta estática en R1](img/05-ruta-r1.png)

![Ruta estática en R2](img/06-ruta-r2.png)

## 4. Configuración y prueba de la VPN

En R1 y R2 se configuró IKEv1 con clave compartida, una transformación IPsec y un *crypto map* en `GigabitEthernet1/0`. Las listas de acceso son simétricas: en R1 identifican tráfico de `1.1.1.0/24` a `2.2.2.0/24` y en R2 identifican el sentido contrario.

| Parámetro | Valor usado en el laboratorio |
| --- | --- |
| IKEv1 | Política 1, autenticación con clave compartida |
| Cifrado y hash | 3DES y MD5 |
| Diffie-Hellman | Grupo 2 |
| Transformación IPsec | `SEC`, ESP 3DES y ESP MD5-HMAC, modo túnel |
| Crypto map | `R1R2`, secuencia 10, aplicado en `GigabitEthernet1/0` |
| Peer de R1 | `12.1.1.2` |
| Peer de R2 | `12.1.1.1` |

Estos algoritmos se usaron para reproducir la guía del laboratorio. Las configuraciones completas y guardadas de los seis routers están en la carpeta [`configs`](configs/).

Para iniciar tráfico que coincidiera con la lista de acceso de la VPN, en R1 se ejecutó:

```text
ping 2.2.2.1 source 1.1.1.1
```

Respondieron **5 de 5** paquetes y `show crypto isakmp sa` mostró `QM_IDLE` y `ACTIVE`.

![Ping e IKEv1 en R1](img/07-ping-isakmp-r1.png)

La consulta `show crypto ipsec sa` mostró asociaciones ESP activas en R1, con **9 paquetes encapsulados y 9 desencapsulados** en el momento de la captura.

![Asociaciones IPsec en R1](img/08-ipsec-sa-r1.png)

Se repitió el ping en sentido contrario, desde `2.2.2.1` hacia `1.1.1.1`. En R2 respondió **5 de 5** y los contadores IPsec mostraron **14 paquetes encapsulados y 14 desencapsulados**. Los valores de los contadores pueden aumentar al repetir las pruebas.

![Pruebas de VPN desde R2](img/09-verificacion-vpn-r2.png)

## 5. Enrutamiento interno OSPF

R1, R3 y R4 forman el área 0 de OSPF. Se configuraron los enlaces `13.1.1.0/24` y `14.1.1.0/24`, además de la loopback de R1. En R1, `show ip ospf neighbor` mostró a R3 y R4 en estado **FULL**.

![Vecinos OSPF vistos desde R1](img/10-vecinos-ospf-r1.png)

R3 aprendió por OSPF la ruta a `1.1.1.1/32` a través de R1 y pudo hacer ping a esa dirección con **5 de 5** respuestas.

![Ruta y ping OSPF desde R3](img/12-ruta-ospf-r3.png)

## 6. Enrutamiento interno EIGRP

R2, R5 y R6 usan EIGRP con el sistema autónomo 100. Se configuraron los enlaces `25.1.1.0/24` y `26.1.1.0/24`, además de la loopback de R2. En R2 aparecieron dos vecinos: R5 (`25.1.1.5`) y R6 (`26.1.1.6`).

![Vecinos EIGRP vistos desde R2](img/11-vecinos-eigrp-r2.png)

R5 aprendió la ruta `2.2.2.0/24` por EIGRP a través de R2 y pudo hacer ping a `2.2.2.1` con **5 de 5** respuestas.

![Ruta y ping EIGRP desde R5](img/13-ruta-eigrp-r5.png)

## 7. Respuestas al cuestionario

**1. ¿Por qué el ping sin dirección de origen no inicia la VPN?** R1 usa normalmente como origen la dirección de salida `12.1.1.1`. La lista de acceso de la VPN solo identifica paquetes de `1.1.1.0/24` a `2.2.2.0/24`, así que ese ping no activa el cifrado. Que el ping simple reciba respuesta depende de las rutas y políticas del entorno; lo que sí se comprobó en esta práctica es que el ping con `source 1.1.1.1` activa y usa la VPN.

**2. ¿Qué ocurre si falta la clave compartida?** R1 y R2 no pueden completar la autenticación IKEv1. Sin la asociación de seguridad de IKE, no se negocian las asociaciones IPsec necesarias para cifrar el tráfico.

**3. ¿Para qué sirve la ruta estática si la ACL ya identifica el tráfico?** La ACL selecciona qué tráfico se cifra, pero no indica por dónde enviarlo. La ruta hace que el paquete salga por `GigabitEthernet1/0`, donde está aplicado el *crypto map*.

**4. ¿Qué se vería en una captura de Wireshark del enlace R1-R2?** Se podrían observar las direcciones externas de los peers, el protocolo ESP y datos de su cabecera. El contenido del paquete original y sus direcciones internas quedarían protegidos por ESP en modo túnel. Esta respuesta describe el comportamiento esperado; no se realizó una captura de Wireshark en esta práctica.

**5. ¿Por qué OSPF y EIGRP no forman vecindad a través de esta VPN?** El *crypto map* protege tráfico IP seleccionado por una ACL entre dos redes. Los mensajes de OSPF y EIGRP emplean multicast y este diseño no los transporta como un enlace entre los dos dominios. Por eso OSPF y EIGRP funcionan cada uno en su lado. Para intercambiar protocolos dinámicos por un enlace cifrado se puede usar un túnel GRE protegido con IPsec u otra solución de VPN basada en interfaz.

Las ACL de R1 y R2 tienen origen y destino invertidos para proteger las mismas comunicaciones en cada sentido. Se omitió el diálogo inicial de Cisco IOS para ingresar directamente la configuración requerida desde la consola.

## 8. Problemas encontrados

| Situación | Cómo se resolvió |
| --- | --- |
| IOS mostró un aviso de exceso de capacidad del bus PCI al arrancar. | Se esperó el arranque y se comprobó que los routers llegaban al indicador de comandos. El aviso no impidió esta simulación. |
| Varios comandos se pegaron seguidos en PuTTY y aparecieron errores de sintaxis. | Se guardaron bloques de texto con una línea por comando en Bloc de notas y se pegaron desde el indicador correcto (`Router#` o `R1#`). |
| El proyecto anterior no conservó la configuración esperada. | Se abrió de nuevo la topología, se configuraron los routers y se guardó cada uno con `write memory`. También se conservó una copia local de las seis configuraciones. |

## 9. Alcance y fuentes

El nodo Cloud-1 figura conectado a VMnet8 en la topología. En esta entrega se comprobó la VPN y las vecindades internas; no se documenta una prueba de conectividad externa a través de Cloud-1.

Las configuraciones 3DES, MD5 y grupo 2 corresponden a la práctica indicada por el profesor. Para redes de producción se deben utilizar parámetros criptográficos actuales.

- [Guía del laboratorio del repositorio](../README.md)
- [Cisco: interpretación de `show crypto isakmp sa` y `show crypto ipsec sa`](https://www.cisco.com/c/en/us/support/docs/security-vpn/ipsec-negotiation-ike-protocols/5409-ipsec-debug-00.html)
- [Cisco: protocolos de enrutamiento sobre GRE e IPsec](https://www.cisco.com/c/en/us/support/docs/security-vpn/ipsec-negotiation-ike-protocols/14381-gre-ipsec-ospf.pdf)
