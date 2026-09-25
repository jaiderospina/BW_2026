# Desactivar el hipervisor de Windows

Ejecutar en PowerShell como administrador:

~~~powershell
Disable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard" /v Enabled /t REG_DWORD /d 0 /f
bcdedit.exe /set "{current}" hypervisorlaunchtype off
~~~

Después de guardar el trabajo, reiniciar Windows. Este comando reinicia el equipo inmediatamente:

~~~powershell
shutdown.exe /r /t 0
~~~
