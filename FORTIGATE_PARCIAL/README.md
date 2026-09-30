# Guía de Laboratorio : Exploración Funcional de FortiOS y su Aplicación en Redes de Banda Ancha

**Modalidad:** Aula Invertida / Laboratorio de Exploración Guiada

**Carácter:** Individual

**Duración en clase:** 90 minutos (1 hora y media)

**Entorno de trabajo:** Instancia local de FortiGate VM en GNS3 (previamente instalada)

**Entregable:** Archivo `README.md` estructurado en el repositorio personal de la asignatura

**Mecanismo de evaluación:** Control de actividad individual (*check-in* presencial / revisión de consola) durante la sesión

---

## 1. Contextualización y Propósito de la Práctica

El desarrollo de las redes de banda ancha modernas demanda que los ingenieros reconozcan de inmediato la correlación entre las interfaces de configuración de dispositivos comerciales y los principios de transporte, enrutamiento avanzado, disponibilidad y cifrado de datos.

La presente práctica plantea un reconocimiento exhaustivo y estructurado de la interfaz web gráfica (GUI) de la máquina virtual FortiGate desplegada en GNS3. El estudiante debe contrastar cada módulo administrativo con la teoría de redes de banda ancha, capturar la evidencia visual correspondiente y redactar una síntesis técnica rigurosa en el `README.md` de su repositorio.

---

## 2. Metodología de Ejecución (Estructura de la Sesión de 90 Minutos)

Exploración individual.

---

## 3. Módulos de Exploración Obligatoria

Cada estudiante debe acceder a su entorno en GNS3 vía navegador web (`https://<IP_FortiGate>`) y navegar sistemáticamente por todas las interfaces; entre otras:



### Conectividad y Transporte Seguro (VPN)

* **IPsec Wizard / Custom IPsec:**
* *Ruta en GUI:* `VPN > IPsec Tunnels > Create New`.
* *Exploración:* Navegar entre el asistente predefinido (*IPsec Wizard: Site to Site, Hub-and-Spoke, Remote Access*) y la opción de túnel personalizado (*Custom*).
* *Investigación y encuadre:* Identificar la función de la Fase 1 (establecimiento de canal seguro IKE, Diffie-Hellman) y Fase 2 (selectores de tráfico de red local y remota, encapsulación ESP). Explicar por qué el cifrado IPsec es indispensable para interconectar sedes sobre enlaces de banda ancha compartidos de Internet.


* **SSL-VPN Portals y SSL-VPN Settings:**
* *Ruta en GUI:* `VPN > SSL-VPN Portals` y `VPN > SSL-VPN Settings`.
* *Exploración:* Contrastar los modos de conexión (*Web Mode* sin cliente vs. *Tunnel Mode* completo con túnel virtual). Analizar la asignación del *IP Pool* para clientes remotos y la selección de puertos de escucha.
* *Investigación y encuadre:* Evaluar la relevancia de las SSL-VPN en esquemas de teletrabajo de alta concurrencia y su impacto en el consumo de ancho de banda upstream en el nodo corporativo.



### Orquestación y Resiliencia de Enlaces (SD-WAN)

* **SD-WAN Zones y Member Interfaces:**
* *Ruta en GUI:* `Network > SD-WAN > SD-WAN Zones`.
* *Exploración:* Visualizar la agrupación de múltiples interfaces físicas o virtuales dentro de una misma zona de transporte WAN.
* *Investigación y encuadre:* Explicar cómo la abstracción de enlaces permite combinar conexiones de banda ancha dispares (fibra dedicada, cable módem, satélite de baja órbita) bajo una única política unificada.


* **Performance SLA:**
* *Ruta en GUI:* `Network > SD-WAN > Performance SLA`.
* *Exploración:* Analizar los servidores de prueba (*probe servers*), protocolos de sondeo (`Ping`, `HTTP`, `DNS`) y umbrales tolerables de latencia, fluctuación de retardo (*jitter*) y pérdida de paquetes (*packet loss*).
* *Investigación y encuadre:* Determinar por qué la medición de SLA es la base para el enrutamiento determinista de aplicaciones críticas (videoconferencias, telefonía VoIP) en canales de datos saturados.


* **SD-WAN Rules:**
* *Ruta en GUI:* `Network > SD-WAN > SD-WAN Rules`.
* *Exploración:* Revisar los métodos de selección de interfaz: *Manual*, *Best Quality*, *Lowest Cost* y *Maximize Bandwidth (SLA)*.
* *Investigación y encuadre:* Detallar el mecanismo mediante el cual se evita la saturación de los enlaces metropolitanos derivando el tráfico recreativo al enlace secundario.



### Parametrización Perimetral y Control de Calidad

* **Interfaces y Políticas de Firewall:**
* *Ruta en GUI:* `Network > Interfaces` y `Policy & Objects > Firewall Policy`.
* *Exploración:* Identificar los modos de direccionamiento de interfaz (`Static`, `DHCP`), servicios de acceso permitidos y los parámetros obligatorios de una regla de firewall (`Incoming Interface`, `Outgoing Interface`, `Source`, `Destination`, `Service`, `Action`, `NAT`).


* **Traffic Shaping (Modelado de Tráfico):**
* *Ruta en GUI:* `Policy & Objects > Traffic Shaping` (o `Traffic Shaping Policy`).
* *Exploración:* Observar los parámetros de ancho de banda garantizado (*Guaranteed Bandwidth*), ancho de banda máximo (*Maximum Bandwidth*) y prioridades de cola (*High, Medium, Low*).
* *Investigación y encuadre:* Justificar el uso de modeladores de tráfico en redes con asimetría de subida/bajada para garantizar la equidad de canal entre usuarios de la red.



---

## 4. Estructura Requerida para el `README.md`

El repositorio de cada estudiante debe contener en la raíz el archivo `README.md` estructurado de acuerdo con la siguiente plantilla:

```markdown
# Bitácora de Exploración Funcional: FortiGate VM en Redes de Banda Ancha

**Estudiante:** [Nombre Completo del Estudiante]  
**Código / ID:** [Código Estudiantil]  
**Fecha:** [Fecha de Ejecución]  
**Asignatura:** Redes de Banda Ancha  

---

## 1. Topología y Verificación de Entorno
* [Inserte captura de pantalla de la topología en GNS3 mostrando el nodo FortiGate activo].
* [Inserte captura de pantalla del Dashboard general de FortiOS donde sea visible el hostname y la versión].

---

## 2. Tecnologías de VPN y Cifrado Perimetral

### 2.1 IPsec Wizard y Túneles Personalizados
* **Evidencia gráfica:** [Captura de la pantalla del IPsec Wizard y de la configuración de selectores de Fase 2].
* **Definición técnica:** [Definición con palabras propias de Fase 1, Fase 2 y selectores de tráfico].
* **Impacto en Redes de Banda Ancha:** [Explicación de cómo mitiga los riesgos en canales públicos y su relación con el tamaño de MTU/MSS en enlaces de alta velocidad].

### 2.2 SSL-VPN (Portales y Configuraciones)
* **Evidencia gráfica:** [Captura del panel de SSL-VPN Portals distinguiendo Web Mode y Tunnel Mode].
* **Definición técnica:** [Diferencia de operación entre el acceso por navegador y el túnel con adaptador virtual].
* **Impacto en Redes de Banda Ancha:** [Análisis del dimensionamiento del ancho de banda upstream requerido para soportar múltiples conexiones simultáneas].

---

## 3. Arquitectura SD-WAN (Gestión Dinámica de Enlaces)

### 3.1 Zonas e Interfaces Miembro
* **Evidencia gráfica:** [Captura de la configuración de zonas SD-WAN y miembros asociados].
* **Concepto técnico:** [Definición del principio de agregación lógica de enlaces heterogéneos].

### 3.2 Performance SLA y Mecanismos de Calidad de Enlace
* **Evidencia gráfica:** [Captura de la parametrización de un Performance SLA mostrando objetivos de latencia y jitter].
* **Concepto técnico:** [Definición de las métricas evaluadas y el papel de las sondas].
* **Impacto en Redes de Banda Ancha:** [Por qué el monitoreo de SLA sustituye ventajosamente al enrutamiento estático tradicional].

### 3.3 Estrategias de Reglas SD-WAN
* **Evidencia gráfica:** [Captura de los algoritmos de selección de salida (Best Quality, Lowest Cost, etc.)].
* **Concepto técnico:** [Diferenciación técnica de cada estrategia de balanceo].

---

## 4. Control de Tráfico Perimetral y Calidad de Servicio (QoS)

### 4.1 Traffic Shaping
* **Evidencia gráfica:** [Captura del módulo de Traffic Shaping con parámetros de ancho de banda].
* **Concepto técnico y aplicación:** [Importancia de delimitar anchos de banda máximos y garantizados en entornos de alta demanda].

---

## 5. Conclusiones Personales
* [Tres conclusiones concretas sobre el papel del firewall como concentrador de servicios en enlaces metropolitanos de alta capacidad].

```

---

## 5. Criterios de Evaluación y Control en Clase

La calificación se otorgará de forma inmediata durante la sesión mediante el **Control de Actividad** (revisión presencial del repositorio y sustentación breve):

| Criterio | Peso | Descripción |
| --- | --- | --- |
| **Completitud de Evidencias (Pantallazos)** | 20 % | Todas las capturas solicitadas corresponden a la instancia personal del estudiante en GNS3 (verificable por hostname o direccionamiento asignado). |
| **Rigor Conceptual y Encuadre en Banda Ancha** | 20 % | Las explicaciones articulan la funcionalidad del software con conceptos teóricos de la asignatura (latencia, jitter, MTU, ancho de banda, SLAs, encapsulación). |
| **QUIZ escrito**| 60 % |