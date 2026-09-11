# Despliegue de FortiGate en GNS3 integrado con VMware Workstation

Procedimiento documentado para la clase de Banda Ancha, en el que se integra **GNS3** con **VMware Workstation** como virtualizador, con el fin de importar y ejecutar un appliance **FortiGate** dentro del entorno de simulación.

## Requisitos previos

- VMware Workstation Pro instalado y con la virtualización de hardware (Intel VT-x/AMD-V) habilitada en el BIOS/UEFI.
- GNS3 instalado en el equipo anfitrión (host).
- GNS3 VM (la máquina virtual oficial de GNS3) importada en VMware.
- Imagen de FortiGate (KVM) descargada, en este caso la versión **7.6.7**.

> **Importante:** la versión de GNS3 (aplicación de escritorio) y la versión de la GNS3 VM que corre en VMware deben coincidir exactamente. En este procedimiento se usó la versión **2.2.61** en ambos casos, para evitar problemas de compatibilidad e incompatibilidades de protocolo entre el cliente y el servidor remoto.

## Procedimiento

### 1. Verificar coincidencia de versiones

Antes de iniciar cualquier configuración, se confirmó que la versión de GNS3 instalada en el host y la versión de la GNS3 VM en VMware fueran la misma (**2.2.61**). Esto es crítico porque GNS3 se comunica con la VM como un servidor remoto, y un desfase de versiones suele provocar errores de conexión o de carga de módulos.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141422.png)

### 2. Iniciar la máquina virtual de GNS3 en VMware

Se enciende la GNS3 VM directamente desde VMware Workstation. Esta VM actúa como el servidor donde realmente se ejecutan los dispositivos emulados (incluyendo el FortiGate), mientras que la aplicación de escritorio de GNS3 funciona como cliente/interfaz gráfica.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141429.png)

### 3. Configurar el virtualizador en las preferencias de GNS3

Con la VM ya encendida, en GNS3 se ingresa a **Edit → Preferences** y se selecciona el tipo de virtualizador utilizado (VMware) junto con el nombre de la máquina virtual previamente creada, para que GNS3 sepa a qué VM conectarse.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141437.png)

### 4. Seleccionar la VM en el apartado "VMware VMs"

Dentro de las mismas preferencias, en la sección **VMware VMs**, se vuelve a seleccionar la máquina virtual creada. Este paso registra formalmente la VM como el servidor GNS3 remoto disponible para alojar dispositivos.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141444.png)

### 5. Verificar el estado de los servidores

En la barra lateral derecha de GNS3 se revisa que los servidores (local y remoto/VM) aparezcan en **color verde**, indicando que están activos. Uno de ellos, en particular, refleja específicamente el estado de la conectividad entre GNS3 (cliente) y la GNS3 VM (servidor) — si este indicador no está en verde, ningún dispositivo basado en VMware podrá desplegarse correctamente.

### 6. Crear la plantilla (template) del dispositivo

Una vez confirmada la conectividad, se crea una nueva **template** desde GNS3, la cual servirá como base para instanciar el dispositivo FortiGate dentro de los proyectos.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141451.png)

### 7. Actualizar el catálogo desde el Online Registry

Se actualiza el listado de imágenes de FortiGate disponibles a través del **Online Registry** (Marketplace) de GNS3, lo que permite ubicar la versión correspondiente al appliance que se va a instalar.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141458.png)

### 8. Instalar la imagen descargada

Se instala la nueva versión del appliance, previamente descargada, utilizando los siguientes parámetros:

| Parámetro | Valor |
|---|---|
| VM Images | `fortigate` |
| Tipo de imagen | KVM |
| Versión | `7.6.7` |

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141506.png)

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141514.png)

### 9. Verificar la disponibilidad del dispositivo

Una vez importada e instalada correctamente, el appliance de **FortiGate** queda disponible dentro de GNS3, en la categoría **Security Devices** del panel de dispositivos.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141521.png)

### 10. Iniciar y configurar el FortiGate

- Se arrastra el dispositivo FortiGate al proyecto (topología) de GNS3.
- Se enciende (start) el dispositivo.
- Se accede a él mediante **consola**.
- Se configura una **contraseña nueva** para el usuario administrador, completando así la puesta en marcha inicial del equipo.

![](https://github.com/FelipeBe62/Banda_Ancha/blob/c8bc8b33037ea79cd3cfcaba27ba3a9de5d1e834/Captura%20de%20pantalla%202026-09-11%20141528.png)

## Resultado

Al finalizar este procedimiento, el appliance FortiGate queda completamente funcional dentro de GNS3, ejecutándose sobre la GNS3 VM alojada en VMware, y listo para ser integrado en topologías de red simuladas para la clase de Banda Ancha.

## Notas y posibles problemas comunes

- Si el servidor de la VM no aparece en verde, revisar que la virtualización anidada esté habilitada y que no haya conflictos con otros hipervisores (por ejemplo, Hyper-V o VirtualBox activos simultáneamente).
- Si el Online Registry no muestra la imagen esperada, verificar la conexión a internet del host y refrescar el catálogo manualmente.
- Los recursos asignados a la GNS3 VM en VMware (RAM/CPU) deben ser suficientes para soportar el appliance FortiGate, que suele requerir más recursos que dispositivos de red convencionales.
