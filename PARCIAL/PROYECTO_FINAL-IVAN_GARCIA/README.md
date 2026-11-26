# 🌐 Implementación de SD-WAN para Continuidad del Negocio y Seguridad en un Escenario Híbrido (Data Center + Cloud)

> **Proyecto Final de Asignatura — Banda Ancha**
>
> **Docente:** Ing. Jaider Ospina Navas
>
> **Observaciones al documento:** Carlos Antonio Orrego Muñoz
>
> **Plataforma de Emulación:** GNS3 / VMware Workstation — FortiGate-VM64 (`FortiOS 8.0.1`)

## 📋 Tabla de Contenidos

1. [Resumen](#1-resumen)
2. [Introducción y Justificación](#2-introducción-y-justificación)
3. [Diseño de la Solución SD-WAN y Plan de Direccionamiento](#3-diseño-de-la-solución-sd-wan-y-plan-de-direccionamiento)
4. [Implementación y Configuración (CLI FortiOS)](#4-implementación-y-configuración-cli-fortios)
   * [4.1 Interfaces Físicas (Underlay)](#41-interfaces-físicas-underlay-isp1-mpls-lan-e-isp2)
   * [4.2 Túneles VPN IPsec (Overlay)](#42-túneles-vpn-ipsec-fase-1-fase-2-e-interfaces-overlay)
   * [4.3 Orquestación SD-WAN, Performance SLA y Rutas](#43-orquestación-sd-wan-performance-sla-y-enrutamiento-estático)
   * [4.4 Políticas de Seguridad Perimetral](#44-implementación-de-políticas-de-seguridad-perimetral)
5. [Arquitectura de Seguridad Implementada](#5-arquitectura-de-seguridad-implementada)
6. [Pruebas, Validación y Diagnóstico](#6-pruebas-validación-y-diagnóstico)
7. [Conclusiones y Recomendaciones](#7-conclusiones-y-recomendaciones)
8. [Referencias](#8-referencias)

---

## 1. Resumen

El presente proyecto detalla el diseño, implementación y validación de una arquitectura **SD-WAN (Software-Defined Wide Area Network)** orientada a garantizar la continuidad operacional y la seguridad perimetral en un entorno híbrido que interconecta una **Sucursal (`FGT-Branch`)**, un **Data Center (`FGT-DC`)** y acceso a servicios en la **Nube (`Cloud`)**.

Mediante instancias virtuales **FortiGate-VM64 (`FortiOS 8.0.1`)** desplegadas sobre **GNS3** y **VMware Workstation**, se implementó una topología multi-transporte con redundancia activa a nivel de proveedores de servicios (**ISP1**, **ISP2** y **MPLS simulado**). Sobre estos tres enlaces físicos (*Underlay*) se establecieron túneles cifrados **IPsec IKEv2** (`VPN-ISP1`, `VPN-MPLS` y `VPN-ISP2`) agrupados en la zona lógica SD-WAN **`Overlay-VPN`**. A través de sondas de monitoreo continuo (**Performance SLA / Health-Checks**) y reglas SD-WAN en modo `Priority`, el sistema evalúa latencia, *jitter* y pérdida de paquetes en tiempo real, ejecutando conmutación automática (*failover*) ante degradación o caída de cualquiera de los enlaces.

---

## 2. Introducción y Justificación

### 2.1 Contexto del Problema

Las organizaciones modernas operan bajo modelos híbridos donde las aplicaciones críticas residen tanto en centros de datos locales (*Data Center*) como en plataformas *Cloud*, mientras las sucursales requieren conectividad continua y segura hacia ambos entornos. Las redes WAN tradicionales basadas únicamente en enlaces MPLS presentan altos costos, rigidez operativa y carencia de balanceo dinámico, mientras que el uso de enlaces de Internet públicos sin cifrado ni control de calidad expone los datos corporativos a interceptación y degradación del servicio.

### 2.2 Justificación del Uso de SD-WAN

* **Resiliencia y Redundancia Multi-ISP:** Operación simultánea sobre `ISP1`, `ISP2` y `MPLS`, eliminando puntos únicos de fallo a nivel de operador.
* **Enrutamiento Inteligente Basado en SLA:** Selección dinámica del mejor enlace según métricas reales (`latencia < 100 ms`, `jitter < 30 ms`, `pérdida de paquetes < 5 %`).
* **Seguridad Integrada (NGFW + IPsec):** Cifrado de extremo a extremo con `AES-128` / `SHA-256` y segmentación por zonas de seguridad.
* **Virtualización de Funciones de Red (NFV):** Consolidación de firewall de nueva generación, terminación VPN y controlador SD-WAN en máquinas virtuales FortiGate.

---

## 3. Diseño de la Solución SD-WAN y Plan de Direccionamiento

### 3.1 Componentes de la Topología

| Componente | Rol en la Arquitectura | Plataforma / Imagen | Función Técnica |
| :--- | :--- | :--- | :--- |
| **`FGT-Branch`** | SD-WAN Edge + Controlador Local (Sucursal) | `FortiGate-VM64 v8.0.1` | Terminación de `ISP1`, `MPLS` e `ISP2`; cifrado IPsec; evaluación SLA y enrutamiento SD-WAN. |
| **`FGT-DC`** | SD-WAN Edge + Hub Data Center | `FortiGate-VM64 v8.0.1` | Concentrador de túneles VPN del Data Center, inspección de seguridad y salida Cloud. |
| **Nube `ISP1` / NAT** | Transporte WAN Principal Internet + Cloud | `GNS3 Cloud / NAT` (`172.31.50.0/24`) | Provee conectividad IP para `VPN-ISP1` y acceso directo a Internet/Cloud (DIA) con NAT. |
| **Enlace `MPLS`** | Transporte WAN Privado Simulado | Segmento Dedicado (`10.200.2.0/24`) | Enlace privado de baja latencia entre Branch y DC para el túnel prioritario `VPN-MPLS`. |
| **Nube `ISP2`** | Transporte WAN Redundante (Backup ISP) | `GNS3 Cloud-ISP2 / VMnet6` (`172.31.60.0/24`) | Segundo operador de Internet para redundancia a nivel de ISP mediante `VPN-ISP2`. |
| **`PC1` y `PC2`** | Hosts de Usuario y Servidor Simulado | `VPCS` (`192.168.10.10` / `.20.10`) | Generación de tráfico de pruebas ICMP y verificación de conectividad extremo a extremo. |

### 3.2 Plan de Direccionamiento IP

| Dispositivo | Interfaz | Zona / Rol | Dirección IP / Máscara | Gateway / Peer Remoto |
| :--- | :--- | :--- | :--- | :--- |
| **`FGT-Branch`** | `port1` | `virtual-wan-link` (`ISP1`) | `172.31.50.21 / 24` | `172.31.50.1` (NAT/Cloud) |
| **`FGT-Branch`** | `port2` | Underlay `MPLS` | `10.200.2.1 / 24` | `10.200.2.2` (`FGT-DC`) |
| **`FGT-Branch`** | `port3` | LAN Sucursal | `192.168.10.1 / 24` | Red local `PC1` |
| **`FGT-Branch`** | `port4` | Underlay `ISP2` | `172.31.60.21 / 24` | `172.31.60.22` (`FGT-DC`) |
| **`FGT-Branch`** | `VPN-ISP1` | `Overlay-VPN` (Member 3) | `10.255.10.1 / 32` | `10.255.10.2` |
| **`FGT-Branch`** | `VPN-MPLS` | `Overlay-VPN` (Member 4) | `10.255.20.1 / 32` | `10.255.20.2` |
| **`FGT-Branch`** | `VPN-ISP2` | `Overlay-VPN` (Member 5) | `10.255.30.1 / 32` | `10.255.30.2` |
| **`FGT-DC`** | `port1` | `virtual-wan-link` (`ISP1`) | `172.31.50.22 / 24` | `172.31.50.1` (NAT/Cloud) |
| **`FGT-DC`** | `port2` | Underlay `MPLS` | `10.200.2.2 / 24` | `10.200.2.1` (`FGT-Branch`) |
| **`FGT-DC`** | `port3` | LAN Data Center | `192.168.20.1 / 24` | Red local `PC2` |
| **`FGT-DC`** | `port4` | Underlay `ISP2` | `172.31.60.22 / 24` | `172.31.60.21` (`FGT-Branch`) |
| **`FGT-DC`** | `VPN-ISP1` | `Overlay-VPN` (Member 3) | `10.255.10.2 / 32` | `10.255.10.1` |
| **`FGT-DC`** | `VPN-MPLS` | `Overlay-VPN` (Member 4) | `10.255.20.2 / 32` | `10.255.20.1` |
| **`FGT-DC`** | `VPN-ISP2` | `Overlay-VPN` (Member 5) | `10.255.30.2 / 32` | `10.255.30.1` |
| **`PC1` (VPCS)** | `eth0` | Host Sucursal | `192.168.10.10 / 24` | `192.168.10.1` |
| **`PC2` (VPCS)** | `eth0` | Servidor Data Center | `192.168.20.10 / 24` | `192.168.20.1` |

---

## 4. Implementación y Configuración (CLI FortiOS)

### 4.1 Interfaces Físicas (Underlay: ISP1, MPLS, LAN e ISP2)

#### `FGT-Branch`

```text
config system interface
    edit "port1"
        set vdom "root"
        set ip 172.31.50.21 255.255.255.0
        set allowaccess ping https ssh http
        set alias "ISP1"
    next
    edit "port2"
        set vdom "root"
        set ip 10.200.2.1 255.255.255.0
        set allowaccess ping
        set alias "MPLS"
    next
    edit "port3"
        set vdom "root"
        set ip 192.168.10.1 255.255.255.0
        set allowaccess ping https ssh
        set alias "LAN-Branch"
    next
    edit "port4"
        set vdom "root"
        set ip 172.31.60.21 255.255.255.0
        set allowaccess ping
        set alias "ISP2"
    next
end
```

#### `FGT-DC`

```text
config system interface
    edit "port1"
        set vdom "root"
        set ip 172.31.50.22 255.255.255.0
        set allowaccess ping https ssh http
        set alias "ISP1"
    next
    edit "port2"
        set vdom "root"
        set ip 10.200.2.2 255.255.255.0
        set allowaccess ping
        set alias "MPLS"
    next
    edit "port3"
        set vdom "root"
        set ip 192.168.20.1 255.255.255.0
        set allowaccess ping https ssh
        set alias "LAN-DC"
    next
    edit "port4"
        set vdom "root"
        set ip 172.31.60.22 255.255.255.0
        set allowaccess ping
        set alias "ISP2"
    next
end
```

### 4.2 Túneles VPN IPsec (Fase 1, Fase 2 e Interfaces Overlay)

Se configuraron tres túneles IPsec en modo interfaz (*route-based VPN*) utilizando **IKEv2**, cifrado **AES-128** con autenticación **SHA-256**, grupos **Diffie-Hellman 20 y 21** y selectores *wildcard* `0.0.0.0/0` en Fase 2. Se deshabilitó `npu-offload` para garantizar el procesamiento por software en hipervisores VMware/GNS3.

#### `FGT-Branch`

```text
config vpn ipsec phase1-interface
    edit "VPN-ISP1"
        set interface "port1"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 172.31.50.22
        set psksecret Fortinet123!
        set npu-offload disable
    next
    edit "VPN-MPLS"
        set interface "port2"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 10.200.2.2
        set psksecret Fortinet123!
        set npu-offload disable
    next
    edit "VPN-ISP2"
        set interface "port4"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 172.31.60.22
        set psksecret Fortinet123!
        set npu-offload disable
    next
end

config vpn ipsec phase2-interface
    edit "VPN-ISP1"
        set phase1name "VPN-ISP1"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
    edit "VPN-MPLS"
        set phase1name "VPN-MPLS"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
    edit "VPN-ISP2"
        set phase1name "VPN-ISP2"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
end

config system interface
    edit "VPN-ISP1"
        set ip 10.255.10.1 255.255.255.255
        set remote-ip 10.255.10.2 255.255.255.255
        set allowaccess ping
    next
    edit "VPN-MPLS"
        set ip 10.255.20.1 255.255.255.255
        set remote-ip 10.255.20.2 255.255.255.255
        set allowaccess ping
    next
    edit "VPN-ISP2"
        set ip 10.255.30.1 255.255.255.255
        set remote-ip 10.255.30.2 255.255.255.255
        set allowaccess ping
    next
end
```

#### `FGT-DC`

```text
config vpn ipsec phase1-interface
    edit "VPN-ISP1"
        set interface "port1"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 172.31.50.21
        set psksecret Fortinet123!
        set npu-offload disable
    next
    edit "VPN-MPLS"
        set interface "port2"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 10.200.2.1
        set psksecret Fortinet123!
        set npu-offload disable
    next
    edit "VPN-ISP2"
        set interface "port4"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256
        set dhgrp 20 21
        set remote-gw 172.31.60.21
        set psksecret Fortinet123!
        set npu-offload disable
    next
end

config vpn ipsec phase2-interface
    edit "VPN-ISP1"
        set phase1name "VPN-ISP1"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
    edit "VPN-MPLS"
        set phase1name "VPN-MPLS"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
    edit "VPN-ISP2"
        set phase1name "VPN-ISP2"
        set proposal aes128-sha256
        set dhgrp 20 21
        set auto-negotiate enable
    next
end

config system interface
    edit "VPN-ISP1"
        set ip 10.255.10.2 255.255.255.255
        set remote-ip 10.255.10.1 255.255.255.255
        set allowaccess ping
    next
    edit "VPN-MPLS"
        set ip 10.255.20.2 255.255.255.255
        set remote-ip 10.255.20.1 255.255.255.255
        set allowaccess ping
    next
    edit "VPN-ISP2"
        set ip 10.255.30.2 255.255.255.255
        set remote-ip 10.255.30.1 255.255.255.255
        set allowaccess ping
    next
end
```

### 4.3 Orquestación SD-WAN, Performance SLA y Enrutamiento Estático

#### `FGT-Branch`

```text
config system sdwan
    set status enable
    config zone
        edit "virtual-wan-link"
        next
        edit "Overlay-VPN"
        next
    end
    config members
        edit 3
            set interface "VPN-ISP1"
            set zone "Overlay-VPN"
        next
        edit 4
            set interface "VPN-MPLS"
            set zone "Overlay-VPN"
        next
        edit 5
            set interface "VPN-ISP2"
            set zone "Overlay-VPN"
        next
    end
    config health-check
        edit "SLADC"
            set server "10.255.10.2"
            set members 3
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
        edit "SLADCMPLS"
            set server "10.255.20.2"
            set members 4
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
        edit "SLADCISP2"
            set server "10.255.30.2"
            set members 5
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
    end
    config service
        edit 1
            set name "TraficoSedes"
            set mode priority
            set dst "all"
            set src "all"
            set health-check "SLADCMPLS"
            set priority-members 4 3 5
        next
    end
end

config router static
    edit 1
        set dst 0.0.0.0 0.0.0.0
        set gateway 172.31.50.1
        set device "port1"
    next
    edit 2
        set dst 192.168.20.0 255.255.255.0
        set sdwan-zone "Overlay-VPN"
    next
end
```

#### `FGT-DC`

```text
config system sdwan
    set status enable
    config zone
        edit "virtual-wan-link"
        next
        edit "Overlay-VPN"
        next
    end
    config members
        edit 3
            set interface "VPN-ISP1"
            set zone "Overlay-VPN"
        next
        edit 4
            set interface "VPN-MPLS"
            set zone "Overlay-VPN"
        next
        edit 5
            set interface "VPN-ISP2"
            set zone "Overlay-VPN"
        next
    end
    config health-check
        edit "SLABRANCH"
            set server "10.255.10.1"
            set members 3
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
        edit "SLABRANCHMPLS"
            set server "10.255.20.1"
            set members 4
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
        edit "SLABRANCHISP2"
            set server "10.255.30.1"
            set members 5
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 30
                    set packetloss-threshold 5
                next
            end
        next
    end
    config service
        edit 1
            set name "TraficoSedes"
            set mode priority
            set dst "all"
            set src "all"
            set health-check "SLABRANCHMPLS"
            set priority-members 4 3 5
        next
    end
end

config router static
    edit 1
        set dst 0.0.0.0 0.0.0.0
        set gateway 172.31.50.1
        set device "port1"
    next
    edit 2
        set dst 192.168.10.0 255.255.255.0
        set sdwan-zone "Overlay-VPN"
    next
end
```

### 4.4 Implementación de Políticas de Seguridad Perimetral

#### `FGT-Branch`

```text
config firewall policy
    edit 1
        set name "LAN-a-DC-VPN"
        set srcintf "port3"
        set dstintf "Overlay-VPN"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 2
        set name "DC-VPN-a-LAN"
        set srcintf "Overlay-VPN"
        set dstintf "port3"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 3
        set name "Salida-Internet-NAT"
        set srcintf "port3"
        set dstintf "virtual-wan-link"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
end
```

#### `FGT-DC`

```text
config firewall policy
    edit 1
        set name "DC-a-Branch-VPN"
        set srcintf "port3"
        set dstintf "Overlay-VPN"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 2
        set name "Branch-VPN-a-DC"
        set srcintf "Overlay-VPN"
        set dstintf "port3"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 3
        set name "Salida-Internet-NAT"
        set srcintf "port3"
        set dstintf "virtual-wan-link"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
end
```

---

## 5. Arquitectura de Seguridad Implementada

El diseño incorpora un modelo de **defensa en profundidad** adaptado a redes híbridas SD-WAN, cubriendo cuatro pilares fundamentales:

| Pilar de Seguridad | Mecanismo Técnico | Implementación en FortiGate | Objetivo de Protección |
| :--- | :--- | :--- | :--- |
| **1. Confidencialidad e Integridad** | Túneles VPN IPsec IKEv2 (`RFC 7296`) | Cifrado simétrico **AES-128**, integridad **SHA-256**, intercambio de claves **Diffie-Hellman Grupos 20 y 21**. | Evita interceptación (*sniffing*) y alteración de paquetes sobre enlaces públicos `ISP1` e `ISP2`. |
| **2. Segmentación por Zonas** | Firewall *Stateful* basado en Zonas | Separación lógica entre `port3` (LAN), `Overlay-VPN` (túneles) y `virtual-wan-link` (Internet/Cloud). | Aísla el tráfico corporativo interno del tráfico no confiable procedente de Internet. |
| **3. Control de Acceso Granular** | Políticas de Firewall + *Implicit Deny* | Reglas explícitas bidireccionales entre `port3` y `Overlay-VPN`; bloqueo automático de cualquier otro flujo. | Impide acceso no autorizado desde los transportes WAN hacia la red interna de las sedes. |
| **4. Protección de Direccionamiento** | NAT Selectivo (*No-NAT* en VPN / *PAT* en Cloud) | NAT deshabilitado en políticas VPN y habilitado (`set nat enable`) únicamente hacia `virtual-wan-link`. | Oculta la topología interna al salir a Internet/Cloud mientras mantiene trazabilidad IP entre sedes. |

---

## 6. Pruebas, Validación y Diagnóstico

### 6.1 Verificación de Túneles IPsec, Health-Checks y Enrutamiento SD-WAN

```text
# 1. Verificación del estado de los túneles IPsec (Fase 1 y Fase 2 UP)
diagnose vpn tunnel list
# Resultado: VPN-MPLS, VPN-ISP1 y VPN-ISP2 en status=up, src: 0.0.0.0/0, dst: 0.0.0.0/0, contadores dec:pkts y enc:pkts activos.

# 2. Verificación de métricas de Calidad de Servicio (Performance SLA)
diagnose sys sdwan health-check
# Resultado:
# Health Check(SLABRANCH): Seq(3 VPN-ISP1): state(alive), packet-loss(0.000%), latency(0.154 ms), jitter(0.084 ms)
# Health Check(SLABRANCHMPLS): Seq(4 VPN-MPLS): state(alive), packet-loss(0.000%), latency(0.348 ms), jitter(0.043 ms)
# Health Check(SLABRANCHISP2): Seq(5 VPN-ISP2): state(alive), packet-loss(0.000%), latency(<1 ms), jitter(<1 ms)

# 3. Verificación de la tabla de enrutamiento hacia la red remota
get router info routing-table details 192.168.20.10
# Resultado: Routing entry for 192.168.20.0/24 Known via "static", distance 1, metric 0, best
# * via VPN-ISP1 tunnel 172.31.50.22
# * via VPN-MPLS tunnel 10.200.2.2
# * via VPN-ISP2 tunnel 172.31.60.22

# 4. Prueba de conectividad ICMP extremo a extremo sobre el plano Overlay
execute ping 10.255.10.2   # 5 packets transmitted, 5 received, 0% packet loss (avg 0.3 ms)
execute ping 10.255.20.2   # 5 packets transmitted, 5 received, 0% packet loss (avg 0.3 ms)
```

### 6.2 Diagnóstico Avanzado de Tráfico (`Sniffer` y `Debug Flow`) y Hallazgo de Licenciamiento

* **Sniffer de Paquetes (`diagnose sniffer packet`):** Confirmó el ingreso de paquetes ICMP *Echo Request* desde `PC1` por la interfaz LAN `port3` (`192.168.10.10 -> 192.168.20.10`).
* **Debug Flow (`diagnose debug flow`):** Demostró que el motor SD-WAN emparejaba correctamente la regla de enrutamiento (`Match policy routing id=2130968577 -> find a route: gw-10.200.2.2 via VPN-MPLS`) y que el tráfico originado desde el firewall local atravesaba el túnel y llegaba a `FGT-DC` (`received a packet ... from VPN-MPLS`).
* **Identificación de Restricción de Evaluación (`get system status`):** Se verificó que la imagen `FortiGate-VM64 v8.0.1` opera en estado `Serial-Number: FGVM00UNLICENSED / License Status: No License (1 CPU/0 allowed, 3882 MB RAM/0 MB allowed)`. En FortiOS 8.0, las máquinas virtuales sin licencia de evaluación activa restringen el reenvío de paquetes de tránsito (*firewall forwarding* entre interfaces físicas/virtuales), permitiendo exclusivamente el tráfico de control y plano overlay generado localmente por los nodos FortiGate.

### 6.3 Validación de Redundancia y Failover a Nivel de ISP

| Escenario de Prueba | Acción Ejecutada | Enlace Activo Resultante | Resultado Observado |
| :--- | :--- | :--- | :--- |
| **Operación Normal (Todos UP)** | `port1`, `port2` y `port4` activos; SLA en estado `alive`. | **`VPN-MPLS` (Member 4)** | Tráfico cursando por MPLS (prioridad 1) con `0 %` pérdida y latencia `< 0.5 ms`. |
| **Fallo de Enlace MPLS** | `set status down` en `port2` (`FGT-Branch`). | **`VPN-ISP1` (Member 3)** | `SLADCMPLS` cambia a `dead`; conmutación automática hacia `ISP1` en `< 2 s`. |
| **Fallo Doble (MPLS + ISP1)** | `set status down` en `port2` y `port1`. | **`VPN-ISP2` (Member 5)** | `SLADC` cambia a `dead`; tráfico redirigido automáticamente por el segundo operador `ISP2`. |
| **Recuperación de Enlaces** | `set status up` en `port1` y `port2`. | **`VPN-MPLS` (Member 4)** | Restauración de sondas SLA a `alive` y retorno ordenado al enlace principal. |

---

## 7. Conclusiones y Recomendaciones

* **Resiliencia Multi-ISP Comprobada:** La integración de tres transportes independientes (`ISP1`, `MPLS` e `ISP2`) dentro de una única zona SD-WAN (`Overlay-VPN`) elimina puntos únicos de fallo a nivel de proveedor de servicios y garantiza continuidad operacional automática mediante sondas *Performance SLA*.
* **Seguridad Unificada en Entornos Híbridos:** El uso de túneles IPsec IKEv2 con `AES-128` / `SHA-256` sobre los enlaces públicos de Internet permite extender la red privada del Data Center hacia la Sucursal con el mismo nivel de confidencialidad que un circuito MPLS dedicado.
* **Valor del Diagnóstico por Capas:** El uso sistemático de herramientas nativas de FortiOS (`diagnose sniffer packet`, `diagnose debug flow` y `diagnose sys sdwan health-check`) permitió aislar con precisión el comportamiento del plano de control y diferenciar una falla de enrutamiento de una restricción de licenciamiento del hipervisor.
* **Recomendación:** Para habilitar el reenvío completo de tráfico de usuario final (`PC1` hacia `PC2` y servidores HTTP/HTTPS) en FortiOS 8.0, se recomienda asociar una licencia de evaluación FortiCare o FortiFlex en cada instancia VM, o emplear imágenes FortiOS 7.0/7.2 con evaluación integrada.

---

## 8. Referencias

1. **Fortinet Inc.** (2026). *FortiOS 8.0 Administration Guide: SD-WAN Architecture, Performance SLA, and IPsec VPN*. Fortinet Document Library.
2. **Orrego Muñoz, C. A., & Ospina Navas, J.** (2026). *Guía de Proyecto Final de Asignatura Banda Ancha: Implementación de SD-WAN para Continuidad del Negocio y Seguridad en un Escenario Híbrido (Data Center + Cloud)*.
3. **LabTinker.** (2022). *FortiGate SD-WAN, Direct Internet Access (DIA) and GNS3 Cloud Types*. https://labtinker.net/2022/10/30/forti-sd-wan-dia-and-gns3-cloud-types/
4. **Megaport Documentation.** (2025). *Fortinet SD-WAN Deployment and Multi-Cloud Connectivity Architecture*. https://docs.megaport.com/es/mve/fortinet/plan-deployment/
5. **Universidad de Valladolid.** (2020). *Diseño e Implementación de Redes SD-WAN sobre Entornos Virtualizados*. https://uvadoc.uva.es/bitstream/handle/10324/38784/TFG-G3730.pdf