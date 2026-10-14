# Solución de Guía de Laboratorio: Configuración de VPN IPsec Site-to-Site en Cisco IOS

Este repositorio contiene la guía paso a paso y la documentación técnica para la implementación de un túnel **IPsec Site-to-Site** utilizando **Crypto Maps** y el protocolo **IKEv1 (ISAKMP)** entre dos routers Cisco IOS (`R1` y `R2`).

---

## 📐 Topología y Diagrama de Red

```text
       [ Red Local R1 ]                                           [ Red Local R2 ]
    Loopback0: 1.1.1.1/24                                      Loopback0: 2.2.2.1/24
              |                                                          |
            +----+  Gi1/0                                   Gi1/0  +----+
            | R1 |-------------------------------------------------| R2 |
            +----+  12.1.1.1/24                       12.1.1.2/24  +----+
                                   <=== Túnel IPsec ===>
```

> **📌 Ubicación de Imagen 1:** Coloca aquí la captura del esquema general de la red en GNS3 / CNO.
> `![Topología General](./imagenes/01_topologia_gns3.png)`

---

## 🛠️ Paso 1: Configuración Básica e Interfaces en R1

Se asignan las direcciones IP a las interfaces físicas (`Gi1/0`, `Gi3/0`, `Gi4/0`) y a la interfaz lógica (`Loopback0`). Adicionalmente, se declara el proceso OSPF básico.

```cisco
R1> enable
R1# configure terminal
R1(config)# hostname R1
R1(config)# no ip domain-lookup

! Interfaz de tránsito hacia R2
R1(config)# interface GigabitEthernet1/0
R1(config-if)# ip address 12.1.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit

! Interfaces adicionales / LAN
R1(config)# interface GigabitEthernet3/0
R1(config-if)# ip address 13.1.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit

R1(config)# interface GigabitEthernet4/0
R1(config-if)# ip address 14.1.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit

! Interfaz Loopback0 (Red Origen Local a proteger)
R1(config)# interface Loopback0
R1(config-if)# ip address 1.1.1.1 255.255.255.0
R1(config-if)# exit

! Configuración OSPF
R1(config)# router ospf 1
R1(config-router)# network 1.1.1.0 0.0.0.255 area 0
R1(config-router)# network 11.11.11.0 0.0.0.255 area 0
R1(config-router)# network 12.1.1.0 0.0.0.255 area 0
R1(config-router)# network 13.1.1.0 0.0.0.255 area 0
R1(config-router)# network 14.1.1.0 0.0.0.255 area 0
R1(config-router)# exit

! Ruta estática apuntando a la red destino remota
R1(config)# ip route 2.2.2.0 255.255.255.0 12.1.1.2
```

> **📌 Ubicación de Imagen 2:** Captura del CLI aplicando la configuración inicial y OSPF en R1.
> `![Configuración Inicial R1](./imagenes/02_config_inicial_r1.png)`

---

## 🛠️ Paso 2: Configuración del Túnel IPsec / ISAKMP en R1

1. **Fase 1 (IKEv1 - ISAKMP):** Establecer política de negociación y clave precompartida (PSK).
2. **Tráfico Interesante:** Definir ACL extendida para matchear `1.1.1.0/24` $\rightarrow$ `2.2.2.0/24`.
3. **Fase 2 (IPsec Transform Set & Crypto Map):** Asociar algoritmos de cifrado/autenticación e imbuir el crypto map a la interfaz física de salida `Gi1/0`.

```cisco
! Configuración IKE / ISAKMP Policy (Fase 1)
R1(config)# crypto isakmp policy 1
R1(config-isakmp)# encr 3des
R1(config-isakmp)# hash md5
R1(config-isakmp)# authentication pre-share
R1(config-isakmp)# group 2
R1(config-isakmp)# exit

! Clave Precompartida (PSK) hacia el Peer R2
R1(config)# crypto isakmp key ccie123 address 12.1.1.2

! Definición de Tráfico Interesante (ACL VPN)
R1(config)# ip access-list extended VPN
R1(config-ext-nacl)# permit ip 1.1.1.0 0.0.0.255 2.2.2.0 0.0.0.255
R1(config-ext-nacl)# exit

! Conjunto de Transformaciones IPsec (Fase 2)
R1(config)# crypto ipsec transform-set SEC esp-3des esp-md5-hmac
R1(cfg-crypto-trans)# mode tunnel
R1(cfg-crypto-trans)# exit

! Crypto Map
R1(config)# crypto map R1R2 10 ipsec-isakmp
R1(config-crypto-map)# set peer 12.1.1.2
R1(config-crypto-map)# set transform-set SEC
R1(config-crypto-map)# match address VPN
R1(config-crypto-map)# exit

! Aplicar Crypto Map a la interfaz WAN
R1(config)# interface GigabitEthernet1/0
R1(config-if)# crypto map R1R2
R1(config-if)# exit
R1# copy running-config startup-config
```

> **📌 Ubicación de Imagen 3:** Captura de la consola activando ISAKMP en `GigabitEthernet1/0` de R1.
> `![Activación Crypto Map R1](./imagenes/03_crypto_map_r1.png)`

---

## 🛠️ Paso 3: Configuración Completa en R2

Se replica la estructura equivalente en **R2**, manteniendo la clave estática, la simetría en la ACL (espejo) y los parámetros de cifrado/hashing.

```cisco
Router> enable
Router# configure terminal
Router(config)# hostname R2
R2(config)# no ip domain-lookup

! Configuración de Interfaces
R2(config)# interface GigabitEthernet1/0
R2(config-if)# ip address 12.1.1.2 255.255.255.0
R2(config-if)# no shutdown
R2(config-if)# exit

R2(config)# interface Loopback0
R2(config-if)# ip address 2.2.2.1 255.255.255.0
R2(config-if)# exit

! Enrutamiento EIGRP y Ruta Estática de retorno
R2(config)# router eigrp 100
R2(config-router)# network 2.2.2.0 0.0.0.255
R2(config-router)# no auto-summary
R2(config-router)# exit

R2(config)# ip route 1.1.1.0 255.255.255.0 12.1.1.1

! Configuración Fase 1 (ISAKMP)
R2(config)# crypto isakmp policy 1
R2(config-isakmp)# encr 3des
R2(config-isakmp)# hash md5
R2(config-isakmp)# authentication pre-share
R2(config-isakmp)# group 2
R2(config-isakmp)# exit

R2(config)# crypto isakmp key ccie123 address 12.1.1.1

! ACL Espejo de Tráfico Interesante (2.2.2.0/24 -> 1.1.1.0/24)
R2(config)# ip access-list extended VPN
R2(config-ext-nacl)# permit ip 2.2.2.0 0.0.0.255 1.1.1.0 0.0.0.255
R2(config-ext-nacl)# exit

! Configuración Fase 2 (Transform Set y Crypto Map)
R2(config)# crypto ipsec transform-set SEC esp-3des esp-md5-hmac
R2(cfg-crypto-trans)# mode tunnel
R2(cfg-crypto-trans)# exit

R2(config)# crypto map R1R2 10 ipsec-isakmp
R2(config-crypto-map)# set peer 12.1.1.1
R2(config-crypto-map)# set transform-set SEC
R2(config-crypto-map)# match address VPN
R2(config-crypto-map)# exit

R2(config)# interface GigabitEthernet1/0
R2(config-if)# crypto map R1R2
R2(config-if)# exit
R2# copy running-config startup-config
```

> **📌 Ubicación de Imagen 4:** Captura del guardado y confirmación de ISAKMP ON en R2.
> `![Configuración R2](./imagenes/04_config_r2.png)`

---

## 🧪 Paso 4: Pruebas de Conectividad y Activación del Túnel

Para disparar la negociación del túnel IPsec, es **indispensable** enviar tráfico interesante especificando como origen la interfaz que coincide con la ACL (`Loopback0` de R1):

```cisco
! Ping directo simple (No activa el túnel)
R1# ping 12.1.1.2

! Ping desde la red origen protegida (Gatilla la VPN)
R1# ping 2.2.2.1 source 1.1.1.1
```

> **📌 Ubicación de Imagen 5:** Captura de la ejecución exitosa del ping con origen `1.1.1.1` hacia `2.2.2.1` con éxito del 80%-100%.
> `![Ping extendido exitoso](./imagenes/05_ping_exitoso.png)`

---

## 🔍 Paso 5: Verificación del Estado de las SAs (ISAKMP e IPsec)

### 1. Verificación de Fase 1 (IKE SA)

```cisco
R1# show crypto isakmp sa
```

**Resultado esperado:**
- Estado: `QM_IDLE`
- Status: `ACTIVE`

> **📌 Ubicación de Imagen 6:** Captura del comando `show crypto isakmp sa` mostrando estado `QM_IDLE`.
> `![Verificación ISAKMP SA](./imagenes/06_show_crypto_isakmp_sa.png)`

---

### 2. Verificación de Fase 2 (IPsec SA)

```cisco
R1# show crypto ipsec sa
```

**Métricas a verificar:**
- `#pkts encaps: 4, #pkts encrypt: 4`
- `#pkts decaps: 4, #pkts decrypt: 4`
- Inbound/Outbound SPI activo con protocolo `esp-3des esp-md5-hmac`.

> **📌 Ubicación de Imagen 7:** Captura del comando `show crypto ipsec sa` confirmando el empaquetado y cifrado de paquetes.
> `![Verificación IPsec SA](./imagenes/07_show_crypto_ipsec_sa.png)`

---

## 📝 Cuestionario Final y Respuestas Técnicas

### 1. ¿Por qué el comando `ping 2.2.2.1` ejecutado sin especificar la interfaz de origen falla al intentar levantar el túnel IPsec, aun cuando exista enrutamiento hacia esa red?

* **Razón técnica:** En las VPN basadas en políticas (*Crypto Maps*), el router determina si debe aplicar cifrado comparando las direcciones IP de origen y destino del paquete contra la Lista de Acceso Criptográfica (`ip access-list extended VPN`).
* **Origen por defecto:** Si se ejecuta un `ping` directo desde el CLI de `R1` sin parámetro de origen, el router utiliza por defecto la IP de la interfaz física de salida por la cual enruta el paquete hacia el destino (en este caso, `GigabitEthernet1/0` con la IP `12.1.1.1`).
* **Evaluación de la ACL:** El paquete resultante tiene IP origen `12.1.1.1` e IP destino `2.2.2.1`. Al evaluarse contra la norma `permit ip 1.1.1.0 0.0.0.255 2.2.2.0 0.0.0.255`, no hay coincidencia (no es considerado *tráfico interesante*).
* **Resultado:** El router no activa la negociación IKE/IPsec y envía el paquete en texto plano a la red, provocando un fallo o pérdida de paquetes sin cifrar. Para levantarlo correctamente se requiere ejecutar `ping 2.2.2.1 source 1.1.1.1`.

---

### 2. ¿Qué relación técnica existe entre la lista de acceso de R1 (`permit ip 1.1.1.0 2.2.2.0...`) y la de R2 (`permit ip 2.2.2.0 1.1.1.0...`)?

* **Simetría y Espejo (Mirror ACLs):** Las listas de acceso que definen el tráfico interesante en ambos extremos de un túnel IPsec deben ser estrictamente especulares (*espejo*).
* **Matcheo de Security Associations (SA):** Durante la negociación de la Fase 2 (Quick Mode / IPsec SA), ambos pares (*peers*) intercambian sus selectores de tráfico. `R1` establece proteger el tráfico de `1.1.1.0/24` hacia `2.2.2.0/24`, por lo que `R2` debe esperar y aceptar el tráfico inverso correspondiente (`2.2.2.0/24` hacia `1.1.1.0/24`).
* **Impacto ante inconsistencias:** Si las ACLs no son simétricas, la negociación de la Fase 2 fallará reportando errores por desajuste de propuestas/IDs (*proxy ID mismatch* / *proposal mismatch*).

---

### 3. ¿Por qué la ausencia del comando `crypto isakmp key` impide que el router inicie el modo principal (*Main Mode*) durante el intercambio de Fase 1?

* **Autenticación en Fase 1:** Al configurar una política ISAKMP mediante `authentication pre-share`, el motor criptográfico requiere obligatoriamente de una Clave Precompartida (PSK) explícitamente vinculada a la IP remota del peer (`address 12.1.1.2`).
* **Imposibilidad de autenticar:** Durante el *Main Mode* (intercambio de 6 mensajes en IKEv1), ambos pares deben derivar y autenticar sus identidades utilizando el hash generado por la clave precompartida. Si la clave no está presente en la configuración global, el motor de Cisco IOS aborta inmediatamente el proceso de negociación al no contar con el parámetro clave para verificar la identidad remota.

---

### 4. ¿Qué ventaja operativa representa evitar el diálogo interactivo inicial de configuración (*Setup Dialog*) en Cisco IOS frente a la configuración manual por CLI?

* **Ahorro de tiempo y automatización:** El *Setup Dialog* realiza un cuestionario secuencial rígido que únicamente configura parámetros globales mínimos, resultando lento e ineficiente para topologías complejas.
* **Control preciso:** La configuración directa mediante la línea de comandos (CLI) o scripts permite estructurar comandos avanzados (como políticas criptográficas, ACLs extendidas, crypto maps e interfaces lógicas) de forma limpia y exacta, evitando modificaciones accidentales sobre interfaces no deseadas.

---

### 5. Si en la salida de depuración se observa el mensaje `ISAKMP: (0): No pre-shared key with 12.1.1.2`, ¿cuál es el impacto exacto en el proceso de establecimiento del túnel?

* **Impacto exacto:** El proceso de negociación IKEv1 Fase 1 se detiene de forma inmediata en la etapa de autenticación.
* **Resultado final:** La SA de ISAKMP no se establece (el estado no llegará a `QM_IDLE`). Al no concretarse exitosamente la Fase 1, se cancela la creación de las SAs de Fase 2 (IPsec SA), impidiendo que cualquier paquete de datos sea encapsulado o transmitido a través del túnel.

---

### 6. ¿Cuál es la función específica de la ruta estática `ip route 2.2.2.0 255.255.255.0 12.1.1.2` en R1 si el tráfico entre ambas sedes ya está definido en la lista de acceso de la VPN?

* **Dependencia del motor de enrutamiento plano:** En VPNs basadas en políticas con *Crypto Maps*, el motor de reenvío (*Forwarding Engine*) del router evalúa **primero** la tabla de enrutamiento (*RIB*) para seleccionar la interfaz de salida antes de consultar cualquier regla del mapa criptográfico.
* **Función:** La ruta estática le instruye al router que la red `2.2.2.0/24` es alcanzable vía la interfaz física `GigabitEthernet1/0` (next-hop `12.1.1.2`). Una vez que el paquete es asignado a dicha interfaz, esta identifica que tiene aplicado el `crypto map R1R2`, evalúa la ACL asociada, y procede con la encapsulación IPsec. Sin la ruta estática, el router descarta el paquete antes de llegar a procesar el Crypto Map.

---

### 7. Si se ejecutara una captura con Wireshark en el enlace entre R1 y R2 durante la transmisión de datos, ¿qué información de los paquetes originales sería legible y cuál quedaría oculta?

* **Información Legible (Visible / Plaintext):**
  * Cabecera IP Externa (Pública/Tránsito): IP Origen `12.1.1.1` e IP Destino `12.1.1.2`.
  * Cabecera del protocolo **ESP** (Encapsulating Security Payload - Protocolo IP 50), incluyendo campos como el **SPI** (*Security Parameters Index*) y el número de secuencia.
* **Información Oculta (Cifrada / Encrypted Payload):**
  * Cabecera IP Interna (Original): IP Origen `1.1.1.1` e IP Destino `2.2.2.1`.
  * Cabecera de Capa de Transporte (Puertos TCP/UDP o tipos de mensajes ICMP Echo Request/Reply).
  * Toda la carga útil (*Payload*) o datos transmitidos dentro de la comunicación.

---

### 8. ¿Qué limitación técnica impide que los paquetes de control de OSPF o EIGRP se transmitan y formen vecindades a través de este túnel IPsec configurado con Crypto Maps?

* **Falta de soporte para tráfico Multicast/Broadcast:** Los protocolos de enrutamiento dinámico como OSPF (`224.0.0.5`) y EIGRP (`224.0.0.10`) utilizan direcciones IP de multidifusión (*multicast*) para el descubrimiento continuo de vecinos mediante paquetes *Hello*.
* **Limitación de IPsec Nativo (Crypto Maps):** IPsec operando en modo túnel o transporte estándar **únicamente soporta la encapsulación de tráfico unicast IP**. No admite el transporte de tráfico Multicast ni Broadcast.
* **Solución de arquitectura:** Para transportar protocolos de enrutamiento dinámico sobre un enlace cifrado, se deben utilizar interfaces de túnel como **GRE** (*Generic Routing Encapsulation*) o **VTI** (*Virtual Tunnel Interfaces*), sobre las cuales se aplica posteriormente el cifrado IPsec.