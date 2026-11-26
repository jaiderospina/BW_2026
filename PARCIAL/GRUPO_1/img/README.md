# Capturas del proyecto SD WAN del grupo 1

El informe principal utiliza estas ocho capturas y el [diagrama lógico](../Diagrama_logico.png). Se eligieron por su legibilidad y porque cada una aporta una comprobación diferente. Los 70 originales permanecen en esta carpeta para consultar los ensayos y sus cambios.

El [anexo de documentación por fases](../Documentacion_por_fases.md) integra 33 capturas para mostrar también la preparación, las configuraciones, los problemas encontrados y sus comprobaciones. Cada imagen tiene una explicación vinculada a la fase donde se utilizó. Está disponible además en [Word](../Anexo_Documentacion_Fases_Grupo_1.docx) y [PDF](../Anexo_Documentacion_Fases_Grupo_1.pdf).

| Evidencia | Qué se observa | Cómo se interpreta |
| --- | --- | --- |
| [27 DHCP LAN Internet y DNS](27-PC1-DHCP-LAN-Internet-DNS-verificacion.png) | Concesión DHCP de PC1 y respuestas del gateway, una IP externa y un nombre. | Es una prueba histórica con PC1 en 10.10.10.100; la última concesión registrada fue 10.10.10.101. Al repetir, primero se ejecuta ip dhcp y después show ip. |
| [42 Recorrido GRE](42-GRE-trafico-sucursal-DC-sin-NAT.png) | Solicitudes y respuestas ICMP entre sucursal y DC por GRE-ISP1 y port4. | Las IP privadas se conservan. No demuestra HTTP ni cifrado. |
| [48 Aplicación del DC](48-Sucursal-HTTP-DC.png) | El cliente webterm1-2 solicita 10.10.20.10 y recibe la página del DC. | Acredita el contenido recibido desde sucursal. La captura no muestra la cabecera HTTP 200; esa comprobación también consta en los registros. |
| [51 Recuperación de HTTP](51-HTTP-durante-conmutacion-a-ISP2.png) | Códigos 200, varios fallos 000 y nuevos 200 durante la prueba de caída. | El intervalo entre el primer intento fallido y el primero nuevamente exitoso fue de 7 s. No es una medición exacta desde el instante de caída. |
| [52 Ruta de respaldo](52-Ruta-al-DC-activa-por-GRE-ISP2.png) | La ruta al DC aparece por GRE-ISP2 con distancia 20. | Complementa la recuperación del servicio de la captura 51 y permite identificar el camino de respaldo. |
| [54 Retorno al principal](54-Retorno-ruta-GRE-ISP1.png) | Keepalive activo y ruta al DC por GRE-ISP1 con distancia 10. | Confirma el regreso al camino principal; no mide cuánto tardó el retorno. |
| [64 Descargas de QoS](64-QoS-dos-descargas-completas.png) | Tamaños, tiempos y HTTP 200 de las dos descargas en la prueba de 4000 kbps. | No demuestra una mejora. La asignación de QOS_DC_ALTA se revisa por separado en el diagnóstico de sesión. |
| [70 Regla de nube](70-SDWAN-HTTP-nube-regla-2-coincidencia-ISP1.png) | Destino 10.30.10.10, port1 y hit_count=1 en la regla HTTP_NUBE_ISP1. | Demuestra coincidencia de la regla. La respuesta HTTP 200 del destino enrutado está en el registro de nube. |

## Registros que complementan las imágenes

- [HTTP después de arrancar los contenedores](../registros/verification-after-restart.json).
- [HTTP al destino cloud enrutado](../registros/sdwan-http-nube-destino-enrutado.json).
- [TCP 80 permitido y TCP 8080 inaccesible desde sucursal](../registros/tcp-80-vs-8080.json). Esta prueba se documentó como registro; no se creó una captura que no existiera.
- [Perfil QoS asociado a una sesión](../registros/shaper-session-check.json) y [comparación de tiempos](../registros/comparacion-4Mbps.json).
- [Seis consultas históricas de supervisión](../registros/gestion-centralizada-fortigate.txt). La revisión posterior solo completó tres consultas de FG-SUC.

## Consulta de los originales

Las capturas 01 a 28 recogen LAN, DHCP, WAN y calidad de los caminos. Las 29 a 39 muestran almacenamiento, preparación del DC e interfaces de los túneles. Las 40 a 49 documentan conectividad y acceso web; las 50 a 55, caída y retorno; las 56 a 64, mediciones de QoS; y las 65 a 70, la regla de nube y su corrección.

Algunas imágenes muestran fallos intermedios, direcciones anteriores o contadores en cero. Se conservaron como antecedentes y no se presentan como el resultado final. Las capturas no fueron alteradas para cambiar comandos, direcciones o resultados.
