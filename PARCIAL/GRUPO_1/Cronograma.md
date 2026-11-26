# Cronograma del proyecto — Grupo 1

**Asignatura:** Banda Ancha  
**Docente:** Ing. Jaider Ospina Navas  
**Integrantes:** Julián Camilo Moreno Valderrama, Fabiana Lopez Piñeros y Juan Felipe Becerra Briceño.  
**Fecha de corte:** 25 de noviembre de 2026.

Las fechas de implementación se reconstruyen a partir del registro del laboratorio de Juan Felipe Becerra Briceño. La preparación y la sustentación corresponden al grupo 1. No se atribuyen tareas de implementación a otro integrante sin registro que lo respalde.

| Periodo | Actividad | Responsable según el registro | Resultado o estado |
| --- | --- | --- | --- |
| 11–18 de noviembre | Preparar VMware y GNS3; desplegar FortiGate; configurar LAN, DHCP, NAT, miembros WAN y monitor de calidad. | Juan Felipe Becerra Briceño | Conectividad a Internet y comprobaciones de selección y recuperación de ISP. |
| 19 de noviembre | Respaldar la etapa inicial e incorporar el segmento de Data Center. | Juan Felipe Becerra Briceño | Respaldo inicial conservado y direccionamiento del DC. Ese respaldo no representa la topología final ampliada. |
| 23 de noviembre | Recuperar GNS3, integrar sucursal, configurar HTTP del DC, probar segmentación y añadir nube simulada. | Juan Felipe Becerra Briceño | Respuestas HTTP y comprobaciones de acceso desde sede y sucursal. |
| 24–25 de noviembre | Añadir el túnel GRE de respaldo, probar caída y retorno, aplicar QoS y registrar transferencias. | Juan Felipe Becerra Briceño | Recuperación por GRE-ISP2 y retorno por GRE-ISP1. Perfil QoS identificado; las descargas medidas no mejoraron. |
| 25 de noviembre | Corregir el destino de la regla HTTP de nube y consultar el estado de ambos FortiGate desde un script. | Juan Felipe Becerra Briceño | Regla con `hit_count=1` y HTTP 200. Una ejecución central completó seis lecturas; la revisión posterior completó tres de FG-SUC. |
| 25 de noviembre | Revisar direccionamiento, preparar informe, presentación, guion y tablas para la entrega del grupo 1. | Equipo de sustentación: Julián Camilo Moreno Valderrama, Fabiana Lopez Piñeros y Juan Felipe Becerra Briceño. | Material preparado con resultados y límites del laboratorio diferenciados. |
| Antes de la sustentación | Ensayar diseño y WAN; aplicaciones y seguridad; continuidad y QoS. | Julián Camilo Moreno Valderrama, Fabiana Lopez Piñeros y Juan Felipe Becerra Briceño, respectivamente. | Actividad prevista. Distribución de 4, 5 y 6 minutos, con margen para transiciones y preguntas dentro del máximo de 20 minutos. |
| Antes del cierre de la entrega | Exportar el proyecto GNS3 actualizado, importarlo y verificar topología, dependencias y persistencia. | Equipo; responsable específico por acordar. | Pendiente de recibir y comprobar la exportación completa. |
| Antes del cierre de la entrega | Grabar y añadir el video de funcionamiento. | Equipo; responsable específico por acordar. | Pendiente. Mostrar los resultados reales, incluido el alcance de QoS y GRE. |

El guion base recibido organiza las intervenciones y debe revisarse antes del ensayo. Los pasos técnicos y sus evidencias están en el [informe del repositorio](README.md). Las últimas tres filas son actividades de cierre previstas y no acreditan un ensayo, una exportación o un video ya realizados.
