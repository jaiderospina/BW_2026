# Simulacion de gestion centralizada: solo GET y tres consultas FortiOS.
# Uso: powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\gestionar-bordes.ps1 -EsperaPromptSegundos 2 -SondearPrompt
# Abrir previamente las consolas autenticadas. No escribir mientras se consulta.
# Use -SondearPrompt solo si ambas consolas ya muestran #, con la linea vacia.
# El sondeo envia Enter solo si la consola no ha mostrado ninguna salida textual.
[CmdletBinding()]
param(
    [ValidateRange(1, 30)][int]$EsperaPromptSegundos = 4,
    [switch]$SondearPrompt
)

$ErrorActionPreference = 'Stop'
$api = 'http://192.168.232.1:3080/v2'
$originalProject = 'ee82c824-511f-40e4-a875-f19c0bf3bdf2'
$names = @('FortiGate7.2.0x-1', 'FG-SUC')
$commands = @('diagnose sys sdwan member', 'diagnose sys sdwan health-check',
              'diagnose sys gre keepalive all')
$report = [System.Text.StringBuilder]::new()
function Add-Report([string]$Text) { [void]$report.AppendLine($Text) }
function Get-CleanText([string]$Text) {
    return (($Text -replace '\x1b\[[0-?]*[ -/]*[@-~]', '') -replace '[\x00\x08]', '')
}
function Get-RootPrompt([string]$Text) {
    # Excluye modo configuracion "hostname (contexto) #" y exige el ultimo prompt.
    $match = [regex]::Match((Get-CleanText $Text), '(?m)^([A-Za-z0-9_.:-]+ #)[ \t\r\n]*\z')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}
function Send-Bytes($Session, [byte[]]$Bytes) {
    $Session.Stream.Write($Bytes, 0, $Bytes.Length)
    $Session.Stream.Flush()
}
function Read-Console($Session, [int]$Milliseconds) {
    $text = [System.Text.StringBuilder]::new()
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $buffer = [byte[]]::new(8192)
    while ($timer.ElapsedMilliseconds -lt $Milliseconds) {
        if (-not $Session.Stream.DataAvailable) { Start-Sleep -Milliseconds 25; continue }
        $count = $Session.Stream.Read($buffer, 0, $buffer.Length)
        if ($count -eq 0) { throw 'Consola desconectada.' }
        for ($i = 0; $i -lt $count; $i++) {
            $b = [int]$buffer[$i]
            switch ($Session.TelnetState) {
                0 {
                    if ($b -eq 255) { $Session.TelnetState = 1 }
                    elseif ($b -lt 128) { [void]$text.Append([char]$b) }
                }
                1 {
                    if ($b -ge 251 -and $b -le 254) {
                        $Session.TelnetVerb = $b; $Session.TelnetState = 2
                    } elseif ($b -eq 250) { $Session.TelnetState = 3 }
                    else { $Session.TelnetState = 0 }
                }
                2 {
                    # Rechaza opciones Telnet; no son comandos del dispositivo.
                    if ($Session.TelnetVerb -eq 253) { Send-Bytes $Session ([byte[]]@(255, 252, $b)) }
                    elseif ($Session.TelnetVerb -eq 251) { Send-Bytes $Session ([byte[]]@(255, 254, $b)) }
                    $Session.TelnetState = 0
                }
                3 { if ($b -eq 255) { $Session.TelnetState = 4 } }
                4 { if ($b -eq 240) { $Session.TelnetState = 0 } else { $Session.TelnetState = 3 } }
            }
        }
    }
    return $text.ToString()
}
function Invoke-Diagnostic($Session, [string]$Command, [string]$Prompt) {
    Send-Bytes $Session ([System.Text.Encoding]::ASCII.GetBytes($Command + "`r`n"))
    $answer = [System.Text.StringBuilder]::new()
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $moreOffset = 0
    while ($timer.Elapsed.TotalSeconds -lt 12) {
        [void]$answer.Append((Read-Console $Session 150))
        $raw = $answer.ToString()
        $clean = Get-CleanText $raw
        if ($clean -match '(?im)(?:login|username|password)\s*:\s*$') { break }
        $more = $raw.IndexOf('--More--', $moreOffset, [StringComparison]::Ordinal)
        if ($more -ge 0) { Send-Bytes $Session ([byte[]]@(32)); $moreOffset = $more + 8 }
        if ((Get-RootPrompt $raw) -ceq $Prompt) {
            $status = 'LEIDO'
            if ($clean -match '(?i)command parse error|unknown action|command fail|permission denied') {
                $status = 'COMANDO_RECHAZADO'
            }
            return [pscustomobject]@{ Status = $status; Text = $clean; Complete = $true }
        }
        if ($answer.Length -gt 200000) { break }
    }
    return [pscustomobject]@{ Status = 'INCOMPLETO_NO_SE_ENVIARAN_MAS_COMANDOS'; Text = (Get-CleanText $answer.ToString()); Complete = $false }
}

Add-Report ('SIMULACION DE GESTION DE BORDES - ' + (Get-Date -Format o))
Add-Report 'Alcance: estado SD-WAN y GRE. Sin login ni cambios de configuracion.'
try {
    $projects = Invoke-RestMethod -Uri "$api/projects" -Method Get -TimeoutSec 5
    $openedLab = @($projects | Where-Object {
        $_.status -eq 'opened' -and ($_.project_id -eq $originalProject -or $_.name -ceq 'Proyecto_GNS3')
    })
    if ($openedLab.Count -ne 1) {
        Add-Report 'OMITIDO: abre un solo proyecto del laboratorio en GNS3 (Proyecto_GNS3 o el proyecto original).'
        $report.ToString()
        return
    }
    $project = $openedLab[0]
    Add-Report "API: $api | Proyecto: $($project.name) ($($project.project_id))"
    $nodes = Invoke-RestMethod -Uri "$api/projects/$($project.project_id)/nodes" -Method Get -TimeoutSec 5
} catch {
    Add-Report ('API_NO_DISPONIBLE: ' + $_.Exception.Message)
    $report.ToString()
    return
}
foreach ($name in $names) {
    Add-Report ("`n=== $name | " + (Get-Date -Format o) + ' ===')
    $selectedNodes = @($nodes | Where-Object { $_.name -ceq $name })
    if ($selectedNodes.Count -ne 1) { Add-Report 'OMITIDO: nombre ausente o duplicado.'; continue }
    $node = $selectedNodes[0]
    if ($node.node_type -ne 'qemu' -or $node.status -ne 'started' -or $node.console_type -ne 'telnet') {
        Add-Report "OMITIDO: tipo=$($node.node_type), estado=$($node.status), consola=$($node.console_type)."
        continue
    }
    $consoleAddress = [string]$node.console_host
    $consolePort = 0
    if ([string]::IsNullOrWhiteSpace($consoleAddress) -or
        $consoleAddress -in @('0.0.0.0', '::') -or
        -not [int]::TryParse([string]$node.console, [ref]$consolePort) -or
        $consolePort -lt 1 -or $consolePort -gt 65535) {
        Add-Report 'OMITIDO: endpoint de consola no valido; no se adivina un reemplazo.'
        continue
    }
    Add-Report "Nodo: $($node.node_id) | Consola API: ${consoleAddress}:$consolePort"
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        if (-not $client.ConnectAsync($consoleAddress, $consolePort).Wait(3000)) {
            throw 'Tiempo de conexion agotado.'
        }
        $stream = $client.GetStream()
        $stream.ReadTimeout = 1000; $stream.WriteTimeout = 1000
        $session = @{ Stream = $stream; TelnetState = 0; TelnetVerb = 0 }
        $initialWait = if ($SondearPrompt) { 400 } else { $EsperaPromptSegundos * 1000 }
        $initial = Read-Console $session $initialWait
        if ($SondearPrompt -and [string]::IsNullOrWhiteSpace((Get-CleanText $initial))) {
            Send-Bytes $session ([byte[]]@(13, 10))
            $initial += Read-Console $session ($EsperaPromptSegundos * 1000)
        }
        $prompt = Get-RootPrompt $initial
        if (-not $prompt) {
            if ((Get-CleanText $initial) -match '(?im)(?:login|username|password)\s*:\s*$') {
                Add-Report 'OMITIDO_REQUIERE_LOGIN: no se enviaron credenciales ni diagnosticos.'
            } else {
                Add-Report 'OMITIDO_SIN_PROMPT: no se observo un prompt raiz listo; no se enviaron diagnosticos.'
            }
            continue
        }
        foreach ($command in $commands) {
            Add-Report ("`n[" + (Get-Date -Format o) + "] $command")
            $result = Invoke-Diagnostic $session $command $prompt
            Add-Report $result.Text
            Add-Report ('Resultado: ' + $result.Status)
            if (-not $result.Complete) { break }
        }
    } catch {
        Add-Report ('ERROR_CONSOLA: ' + $_.Exception.Message)
    } finally {
        $client.Dispose()
    }
}
Add-Report ("`nFin: " + (Get-Date -Format o))
$report.ToString()
