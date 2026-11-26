# Diagrama lógico SD-WAN

Grupo 1 · Juan Felipe Becerra Briceño · Fabiana Lopez Piñeros · Julián Camilo Moreno Valderrama

~~~mermaid
flowchart LR
    subgraph SEDE["Sede"]
        LAN1["SW-LAN · 10.10.10.0/24<br/>PC1 y webterm1-1"]
        FG1["FortiGate sede<br/>LAN 10.10.10.1"]
        DC["DC-SRV · 10.10.20.10/24<br/>HTTP"]
        LAN1 --- FG1
        FG1 ---|"port4 · 10.10.20.1"| DC
    end

    subgraph SUC["Sucursal"]
        LAN2["Switch1 · 10.20.10.0/24<br/>PC-SUC y webterm1-2"]
        FG2["FG-SUC<br/>LAN 10.20.10.1"]
        LAN2 --- FG2
    end

    ISP1["ISP1 simulado · 192.168.42.0/24<br/>NAT en GNS3 VM"]
    ISP2["ISP2 simulado · 192.168.140.0/24<br/>VMnet8"]
    FG1 ---|"port1 · 192.168.42.27"| ISP1
    FG2 ---|"port1 · 192.168.42.111"| ISP1
    FG1 ---|"port3 · 192.168.140.144"| ISP2
    FG2 ---|"port3 · 192.168.140.145"| ISP2
    FG1 -.->|"GRE-ISP1 · principal"| FG2
    FG1 -.->|"GRE-ISP2 · respaldo"| FG2

    subgraph CLOUD["Nube simulada"]
        EDGE["CLOUD-EDGE<br/>HTTP en 192.168.42.84:80"]
        SRV["CLOUD-SRV · 10.30.10.10/24<br/>HTTP"]
        EDGE ---|"eth1 · 10.30.10.1"| SRV
    end
    ISP1 ---|"CLOUD-ISP1 · eth0"| EDGE
~~~

Las líneas continuas muestran los segmentos y enlaces de transporte. Las líneas punteadas muestran los túneles lógicos entre los bordes. Las tres conexiones al segmento ISP1 corresponden a nodos NAT que comparten el transporte en la GNS3 VM. La entrada HTTP de CLOUD-EDGE funcionó desde ambas LAN. Desde la sucursal se probó además el acceso enrutado a CLOUD-SRV por la regla SD-WAN 2.
