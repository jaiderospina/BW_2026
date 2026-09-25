# Desactivar el hipervisor de Windows

Ejecutar en PowerShell como administrador:

```powershell
bcdedit.exe /set "{current}" hypervisorlaunchtype off
```

Reiniciar Windows para aplicar el cambio.
