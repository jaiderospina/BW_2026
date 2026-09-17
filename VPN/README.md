# Guía Técnica: Redes Privadas Virtuales (VPN), Tecnologías, Seguridad y Redes WAN

---

## 1. ¿Qué es una VPN (Virtual Private Network)?

Una **VPN** (Red Privada Virtual) es una tecnología de red que crea una conexión de red cifrada, segura y punto a punto sobre una infraestructura de red pública o no confiable (comúnmente Internet).

### Principio Fundamental
En lugar de depender de enlaces físicos dedicados y costosos (como líneas arrendadas privadas), una VPN genera un **túnel lógico** (*tunneling*) entre dos nodos. Los datos que viajan a través de este túnel son encapsulados y, generalmente, cifrados, garantizando tres pilares de la seguridad de la información:
* **Confidencialidad:** Nadie fuera del túnel puede leer la información interceptada.
* **Integridad:** Los datos no pueden ser alterados durante el tránsito sin ser detectados.
* **Autenticidad:** Ambas partes validan mutuamente su identidad antes de intercambiar tráfico.

---

## 2. Tecnologías y Protocolos de VPN

El funcionamiento de una VPN depende de protocolos de transporte, encapsulación y cifrado. A continuación se presentan las principales tecnologías:

| Protocolo / Tecnología | Capa del Modelo OSI | Nivel de Seguridad | Rendimiento | Caso de Uso Típico |
| :--- | :--- | :--- | :--- | :--- |
| **IPsec (Internet Protocol Security)** | Capa 3 (Red) | Muy Alto (Cifrado robusto) | Alto (optimizado por hardware) | Enlaces Sitio a Sitio (*Site-to-Site*) y WAN empresarial |
| **OpenVPN** | Capa 4/7 (Transporte/Aplicación) | Muy Alto (Usa OpenSSL) | Medio - Alto | Acceso remoto flexible, multiplataforma |
| **WireGuard** | Capa 3 (Red) | Muy Alto (Criptografía moderna) | Sobresaliente (Baja latencia, poco código) | Acceso remoto moderno, enlaces WAN ágiles |
| **SSL / TLS** | Capa 4/7 (Transporte/Aplicación) | Alto | Alto | Portales VPN basados en navegador, trabajo remoto sin cliente pesado |
| **L2TP / IPsec** | Capa 2 / 3 | Alto (cuando usa IPsec) | Medio | Compatibilidad nativa con sistemas operativos heredados |
| **PPTP** | Capa 2 (Enlace de datos) | Obsoleto / Inseguro | Alto (cifrado débil) | En desuso (vulnerable a ataques criptográficos) |

### Modos de Operación Relevantes:
* **Modo Túnel (IPsec):** Cifra y encapsula el paquete IP completo (encabezado original + datos) dentro de un nuevo paquete IP. Es el estándar para conexiones sitio a sitio.
* **Modo Transporte (IPsec):** Cifra únicamente la carga útil (*payload*) del paquete, conservando el encabezado IP original. Se usa comúnmente en comunicaciones extremo a extremo dentro de una misma red.

---

## 3. Tipos y Mecanismos de Seguridad en VPNs

Para asegurar un canal virtual, las VPN combinan múltiples capas criptográficas y de control:

### A. Cifrado de Datos (*Data Encryption*)
* **Cifrado Simétrico:** Utilizado para la transferencia masiva de datos por su eficiencia computacional. Estándares comunes: **AES-256-GCM**, **ChaCha20-Poly1305**.
* **Cifrado Asimétrico:** Empleado durante el apretón de manos inicial (*handshake*) e intercambio de claves. Algoritmos comunes: **RSA (2048/4096 bits)**, **Curvas Elípticas (ECDH, Ed25519)**.

### B. Autenticación y Control de Identidad
* **Claves Precompartidas (PSK):** Métodos simples para pruebas o entornos pequeños.
* **Infraestructura de Clave Pública (PKI) y Certificados Digitales (X.509):** Estándar corporativo para autenticación mutua de servidores y clientes.
* **Autenticación Multifactor (MFA/2FA):** Integración con directorios de identidad corporativos (Active Directory, LDAP, SAML, RADIUS/TACACS+) para accesos remotos de usuarios.

### C. Integridad y No Repudio
* **HMAC (Hash-based Message Authentication Code):** Funciones hash criptográficas como **SHA-256** o **SHA-512** que aseguran que ningún paquete haya sufrido modificaciones en tránsito.
* **Perfect Forward Secrecy (PFS):** Garantiza que si una clave de sesión a largo plazo se ve comprometida en el futuro, las sesiones pasadas no podrán ser descifradas.

---

## 4. Tipologías y Usos Principales

```
              ┌─────────────────────────────────────────────────────────┐
              │                   TIPOS DE ARQUITECTURA                 │
              └─────────────────────────────────────────────────────────┘
                                           │
         ┌─────────────────────────────────┴─────────────────────────────────┐
         ▼                                                                   ▼
┌─────────────────────────────────┐                         ┌─────────────────────────────────┐
│       Sitio a Sitio (WAN)       │                         │   Acceso Remoto (Client-to-Site)│
│  Conecta sucursales a través de │                         │  Conecta teletrabajadores a la  │
│      túneles permanentes        │                         │        red corporativa          │
└─────────────────────────────────┘                         └─────────────────────────────────┘
```

1. **VPN Sitio a Sitio (*Site-to-Site*):**
   * Conecta redes de área local (LAN) completas entre sucursales, fábricas o centros de datos.
   * Transparente para los usuarios finales: los dispositivos se comunican usando direccionamiento IP privado sin requerir software cliente individual.

2. **VPN de Acceso Remoto (*Client-to-Gateway*):**
   * Permite a trabajadores remotos acceder de forma segura a servidores internos de archivos, bases de datos e intranets.

3. **VPN de Privacidad y Evasión de Restricciones (Consumo Masivo):**
   * Enruta el tráfico comercial del usuario a través de servidores intermediarios para ocultar la dirección IP real frente a proveedores de Internet y proteger el tráfico en redes Wi-Fi abiertas.

---

## 5. Contexto en Banda Ancha y Tecnologías WAN

### A. La Evolución de las Redes WAN: De Enlaces Dedicados a VPN sobre Banda Ancha
Históricamente, las redes de área amplia (WAN) dependían de enlaces dedicados punto a punto como **T1/E1**, **Frame Relay**, **ATM** o circuitos cerrados **MPLS (Multiprotocol Label Switching)**. Aunque ofrecían calidad de servicio (QoS) predecible y aislamiento físico, presentaban serias desventajas:
* Costos operativos mensuales muy elevados.
* Tiempos de aprovisionamiento de semanas o meses.
* Ancho de banda limitado en comparación con el crecimiento del tráfico de datos moderno.

La masificación de la **banda ancha de alta velocidad** (Fibra óptica simétrica, GPON, cable módem DOCSIS e incluso enlaces inalámbricos 4G/5G/Starlink) permitió el despliegue de **VPNs sobre Internet pública como una alternativa WAN rentable y escalable**.

### B. Ventajas de la VPN en el Ecosistema WAN
* **Reducción de Costes (Capex/Opex):** Sustituir o complementar líneas MPLS caras con enlaces de banda ancha comercial protegidos por VPN IPsec reduce drásticamente los gastos de conectividad.
* **Conectividad Global Inmediata:** Cualquier ubicación con acceso básico a Internet de banda ancha puede integrarse a la WAN corporativa en minutos.
* **Redundancia y Alta Disponibilidad:** Permite configurar túneles VPN activos/pasivos sobre múltiples proveedores de banda ancha distintos (ISP multi-homing).

### C. La Nueva Frontera: SD-WAN (Software-Defined WAN)
La combinación de VPN y banda ancha alcanzó su madurez con **SD-WAN**:
* SD-WAN utiliza túneles VPN dinámicos (principalmente basados en IPsec) sobre múltiples enlaces híbridos (Internet de banda ancha, MPLS, 5G).
* Un controlador centralizado mide en tiempo real la latencia, el *jitter* y la pérdida de paquetes, enrutando el tráfico crítico (como VoIP o videollamadas) por el mejor camino disponible y reservando el tráfico general para el túnel de banda ancha estándar.

---

## 6. Resumen y Consideraciones de Implementación

| Factor | Recomendación Técnica |
| :--- | :--- |
| **Selección de Protocolo WAN** | **IPsec IKEv2** o **WireGuard** para enlaces entre sucursales por velocidad y estabilidad. |
| **Cifrado Recomendado** | **AES-GCM-256** para aprovechar la aceleración por hardware (AES-NI). |
| **Consideración MTU/MSS** | La encapsulación VPN añade encabezados adicionales; ajustar el MSS (*Maximum Segment Size*) evita la fragmentación de paquetes en conexiones de banda ancha. |
| **Plan de Resiliencia** | Utilizar al menos dos proveedores de banda ancha diferentes configurados con failover automático de túneles VPN. |