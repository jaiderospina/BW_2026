# Laboratorio: Implementación y Validación de IPsec VPN Site-to-Site (Crypto Maps) en GNS3- Oscar Ivan Garcia Rojas - COD:1701814

Este repositorio contiene la solución completa y el cuestionario resuelto para el laboratorio de **IPsec VPN Site-to-Site basada en políticas** implementada en GNS3 sobre routers Cisco C7200.

\---

## 📌 Contenido del Repositorio

El proyecto incluye la siguiente documentación de soporte:

* **`SOLUCION EJERCICIO VPN SITE TO SITE.pdf`**: Documento principal en formato PDF que contiene la guía de laboratorio, topología, direccionamiento, comandos aplicados en R1 y R2, y evidencias de validación (pruebas de ping y capturas de terminal `show crypto isakmp sa` / `show crypto ipsec sa`).
* **`Respuestas al Cuestionario.docx`**: Documento de Word con las respuestas desarrolladas a detalle para el cuestionario evaluativo y preguntas orientadoras de la práctica.

\---

## 🌐 Resumen de la Topología 

### Redes y Enrutamiento

* **Sitio 1 (R1):** Red protegida `1.1.1.0/24` (Loopback0). Dominio de enrutamiento OSPF (Área 0).
* **Sitio 2 (R2):** Red protegida `2.2.2.0/24` (Loopback0). Dominio de enrutamiento EIGRP (AS 100).
* **Enlace de Tránsito:** Segmento `12.1.1.0/24` entre Gi1/0 de R1 (`12.1.1.1`) y Gi1/0 de R2 (`12.1.1.2`).

### Configuración IPsec VPN

|Parámetro|Configuración|
|-|-|
|**Fase 1 (IKEv1 / ISAKMP)**|Policy 1, Cifrado 3DES, Hash MD5, Pre-Share Key (`ccie123`), DH Group 2|
|**Fase 2 (IPsec)**|Transform-Set `SEC` (esp-3des esp-md5-hmac), Mode Tunnel|
|**Tráfico Interesante**|ACL VPN: `1.1.1.0/24` $\\leftrightarrow$ `2.2.2.0/24`|
|**Crypto Map**|Tag `R1R2` aplicado en la interfaz `GigabitEthernet1/0`|

\---

## 🛠️ Pasos para hacerlo en GNS3

1. Se carga la imagen IOS de Cisco C7200 en GNS3.
2. Se debe iniciar la topología y digitar la configuración que esta en la guia a los routers R1 y R2.
3. Se genera trafico forzando ping a la IP de origen:

```text
   R1# ping 2.2.2.1 source 1.1.1.1
   ```

4. Verificar el estado operativo del túnel:

```text
   R1# show crypto isakmp sa
   R1# show crypto ipsec sa
   ```

