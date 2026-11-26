# Registros suministrados — Grupo 1

Los ocho registros originales se copiaron sin modificar su contenido desde la carpeta Evidencias de la entrega de referencia. No se incluye la conversación completa ni archivos temporales de Office. No se copiaron los SHA256SUMS originales porque corresponden a otra organización de archivos; no acreditan la integridad de este nuevo paquete.

| Registro | Qué permite comprobar |
|---|---|
| verification-after-restart.json | IP/ruta y HTTP 200 de DC-SRV y webterm1-2 después de detener e iniciar esos contenedores. No valida el reinicio posterior de los últimos cambios cloud. |
| wan-cloud-verification.json | HTTP 200 del frontal 192.168.42.84 y acceso desde sede y sucursal en la prueba anterior. |
| sdwan-http-nube-destino-enrutado.json | HTTP 200 hacia 10.30.10.10 desde sucursal, ruta por 10.20.10.1 y estado de CLOUD-EDGE. La coincidencia de regla se completa con la captura 70 de la entrega. |
| tcp-80-vs-8080.json | Servicio temporal 8080 positivo localmente, HTTP 80 positivo desde sucursal y timeout de 8080; incluye retiro del servicio temporal. No identifica el firewall que descartó. |
| shaper-session-check.json | Sesión con reply-shaper QOS_DC_ALTA y shaping_policy_id 1; no demuestra por sí sola beneficio de rendimiento. |
| comparacion-4Mbps.json | Tiempos de la comparación de DC sin/con prioridad, orden inferido de la confirmación del usuario y ausencia de mejora. Falta un registro completo de nube sin prioridad. |
| gestion-inventario-verificacion.txt | Intento de las 16:38 que omitió diagnósticos por falta de login/prompt. Se conserva como antecedente, no como ejecución exitosa. |
| gestion-centralizada-fortigate.txt | Ejecución histórica de las 16:44 del 25/11: seis consultas leídas, tres en cada borde. |

La revisión posterior de las 19:05 registró DHCP de PC1 10.10.10.101 y PC-SUC 10.20.10.100, HTTP 200 de DC/nube y una consulta central parcial de FG-SUC. Ese estado consta en el contexto y la conversación suministrados; no hay un archivo bruto adicional en esta carpeta que deba confundirse con la corrida histórica de seis lecturas.

En sdwan-http-nube-destino-enrutado.json, el campo http_ok=false de CLOUD-EDGE acompaña comandos de inspección de red, sin una solicitud HTTP en ese objeto. El objeto del cliente sí contiene la respuesta HTTP 200. No interpretar aquel campo como una prueba fallida del servidor cloud.

Estos son resultados históricos de corridas concretas, no una certificación del estado actual del laboratorio.