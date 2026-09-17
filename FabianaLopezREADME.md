# Taller en Clase: Configuración de Template para Router Cisco C3725 sobre GNS3 VM (VMware Workstation)

**Estudiante:** 

$$
Fabiana   López
$$

**Asignatura:** Banda Ancha

**Fecha:** 17 de Septiembre, 2026

**Entorno de Trabajo:** Windows 11 | GNS3 v2.2.61 | VMware Workstation Pro

## 📋 Propósito del Taller

Implementar el despliegue y la vinculación exitosa de la máquina virtual **GNS3 VM** bajo el hipervisor **VMware Workstation Pro**, asegurando la conectividad de red entre el cliente local GNS3 (GUI) y la VM. Posteriormente, configurar una plantilla (*template*) para el router **Cisco C3725** ejecutándose obligatoriamente sobre la GNS3 VM (no en el servidor local), como fase previa para la integración de appliances avanzados (p. ej. FortiGate).

## 🛠️ Requisitos Previos e Infraestructura

* **GNS3 GUI:** Versión 2.2.61.

* **GNS3 VM:** Versión 2.2.61 (coincidencia estricta de versiones entre el cliente y el servidor VM).

* **VMware Workstation Pro:** Adaptadores virtuales `VMnet1` (Host-Only) y `VMnet8` (NAT) habilitados con servicio DHCP activo.

* **Imagen IOS Cisco C3725:** Archivo `.bin` o `.image` descomprimido.

## ⚙️ Procedimiento Paso a Paso y Evidencias

### Paso 1: Importación e Inicio de la GNS3 VM en VMware

1. Se realizó la importación del archivo OVA de la **GNS3 VM** hacia VMware Workstation con el nombre personalizado `GNS3 VMware`.

2. Se reajustó el esquema de red en VMware mediante **Virtual Network Editor** (`Restore Defaults`) para garantizar la asignación IP dinámica.

3. Se inició la máquina virtual asegurando que la interfaz `eth0` obtuviera una dirección IP válida dentro del segmento Host-Only (`192.168.36.128`).


*Figura 1: Pantalla principal de la GNS3 VM en VMware mostrando la versión y la dirección IP asignada.*

### Paso 2: Configuración del Servidor Local y Vinculación en GNS3

1. En GNS3, se accedió a `Edit > Preferences > Server`.

2. Se activó la casilla **Enable local server** con los parámetros:

   * **Host binding:** `localhost` (127.0.0.1)

   * **Port:** `3080 TCP`

   * **Password Protection:** Deshabilitado

3. En la sección `GNS3 VM`:

   * Se marcó **Enable the GNS3 VM**.

   * **Virtualization engine:** `VMware (recommended)`.

   * **VM name:** `GNS3 VMware`.

4. Se aplicaron los cambios confirmando el estado **Verde** (conectado y activo) en el panel de *Servers Summary* para ambos nodos (`local main` y `GNS3 VM`).


*Figura 2: Panel Servers Summary con el servidor local y la GNS3 VM en estado activo (verde).*

### Paso 3: Importación y Creación del Template Router Cisco C3725

1. Se ingresó a `Edit > Preferences > Dynamips > IOS routers`.

2. Se creó un nuevo router seleccionando la opción estricta del taller:

   `[x] Run this IOS router on the GNS3 VM`

3. Se cargó la imagen del router Cisco C3725 y se autorizó su descompresión.

4. Se asignaron los parámetros recomendados de memoria RAM y slots.

5. Se ejecutó el cálculo del **Idle-PC finder** para evitar el uso excesivo del procesador (CPU) del equipo host durante la ejecución del IOS.


*Figura 3: Selección explícita de la ejecución del router C3725 sobre la GNS3 VM.*

### Paso 4: Despliegue en Topología y Verificación de Ejecución

1. Se creó un nuevo proyecto en blanco en GNS3.

2. Se arrastró el dispositivo **Cisco C3725** desde el panel de Routers hacia el área de trabajo.

3. Se encendió el nodo y se constató en el panel `Topology Summary` que el router está corriendo sobre el servidor **GNS3 VM**.


*Figura 4: Topología con el nodo C3725 activo ejecutándose sobre la máquina virtual.*

## 💻 Entradas y Comandos de Consola

### Verificación de la versión y procesos en GNS3 VM (vía Shell SSH)

```
# Conexión SSH hacia la máquina virtual
ssh gns3@192.168.36.128

# Comprobación de estado del servicio gns3server
systemctl status gns3server

# Comprobación de interfaces de red activas
ip a show eth0

```

### Arranque de la consola del Router C3725 en GNS3

```
C3725> enable
C3725# show version
Cisco IOS Software, 3700 Software (C3725-ADVENTERPRISEK9-M), Version 12.4(25d), RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.

C3725# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            unassigned      YES unset  administratively down down
FastEthernet0/1            unassigned      YES unset  administratively down down

```

## 📌 Recomendaciones Cumplidas

* **Sincronización de Versiones:** Cliente GNS3 (GUI) y GNS3 VM están en la misma versión (`2.2.61`).

* **Secuencia de Arranque:** Se garantizó que la VM en VMware iniciara y desplegara su IP antes de abrir el cliente GNS3.

* **Ejecución en VM:** El router C3725 quedó alojado exclusivamente en el entorno virtualizado de la MV, dejando la plataforma lista para la posterior incorporación de dispositivos que requieren QEMU/KVM como FortiGate.