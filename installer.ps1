# Custom Installer: Steam Tools & GTA V Legacy
# Baseado no estilo VoidTools

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# --- CONFIGURAÇÃO ---
$ST_URL = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
$GTA_URL = "https://www.dropbox.com/scl/fi/hr4ev06ynw6ey3mnsquvr/271590.zip?rlkey=zzokdeb8fn5mfhmkfmm1xyj3q&st=70mtatc9&dl=1"
$tempDir = "$env:TEMP\GtaToolsInstaller"

# Função de Log Estilizada
function Log {
    param ([string]$Type, [string]$Message)
    $Type = $Type.ToUpper()
    switch ($Type) {
        "OK"   { $foreground = "Green" }
        "INFO" { $foreground = "Cyan" }
        "ERR"  { $foreground = "Red" }
        "WARN" { $foreground = "Yellow" }
        "LOG"  { $foreground = "Magenta" }
        default { $foreground = "White" }
    }
    $date = Get-Date -Format "HH:mm:ss"
    Write-Host "[$date] " -ForegroundColor "DarkGray" -NoNewline
    Write-Host "[$Type] " -ForegroundColor $foreground -NoNewline
    Write-Host $Message
}

function Show-Banner {
    Clear-Host
    Write-Host "      :::::::: ::::::::::: ::::::::::     :::     ::::    ::::  " -ForegroundColor Cyan
    Write-Host "    :+:    :+:    :+:     :+:          :+: :+:   +:+:+: :+:+:+  " -ForegroundColor Cyan
    Write-Host "    +:+           +:+     +:+         +:+   +:+  +:+ +:+:+ +:+  " -ForegroundColor Blue
    Write-Host "    +#++:++#++    +#+     +#++:++#   +#++:++#++ +#+  +:+  +#+  " -ForegroundColor Blue
    Write-Host "           +#+    +#+     +#+        +#+     +#+ +#+       +#+  " -ForegroundColor DarkBlue
    Write-Host "    #+#    #+#    #+#     #+#        #+#     #+# #+#       #+#  " -ForegroundColor DarkBlue
    Write-Host "     ########     ###     ########## ###     ### ###       ###  " -ForegroundColor Magenta
    Write-Host "      ==========================================================" -ForegroundColor DarkGray
    Write-Host "             INSTALLER: STEAM TOOLS & GTA V LEGACY              " -ForegroundColor White
    Write-Host "      ==========================================================" -ForegroundColor DarkGray
    Write-Host ""
}

# 1. Início e Banner
Show-Banner
Log "INFO" "Iniciando instalador personalizado..."

# 2. Verificar Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "ERR" "Execute o PowerShell como ADMINISTRADOR!"
    exit
}

# 3. Detectar Steam
Log "LOG" "Buscando instalacao do Steam..."
$steamPath = $null
$registries = @("HKLM:\SOFTWARE\WOW6432Node\Valve\Steam", "HKLM:\SOFTWARE\Valve\Steam", "HKCU:\SOFTWARE\Valve\Steam")
foreach ($reg in $registries) {
    if (Test-Path $reg) {
        $path = (Get-ItemProperty -Path $reg -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
        if ($path -and (Test-Path $path)) { $steamPath = $path; break }
    }
}

if (-not $steamPath) {
    Log "ERR" "Steam nao encontrado. Verifique se o Steam esta instalado."
    exit
}
Log "OK" "Steam encontrado em: $steamPath"

# 4. Criar Pasta Temporária
if (!(Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory | Out-Null }

# 5. Instalar Steam Tools
Log "INFO" "Baixando Steam Tools..."
try {
    $stExe = "$tempDir\st-setup.exe"
    Invoke-WebRequest -Uri $ST_URL -OutFile $stExe
    Log "LOG" "Executando instalador do Steam Tools..."
    Start-Process -FilePath $stExe -Wait
    Log "OK" "Steam Tools processado."
} catch {
    Log "ERR" "Erro ao instalar Steam Tools: $_"
}

# 6. Instalar GTA V Manifest
Log "INFO" "Baixando Manifest GTA V Legacy..."
try {
    $zipPath = "$tempDir\gta_manifest.zip"
    $manifestDest = Join-Path $steamPath "steamapps"
    
    Invoke-WebRequest -Uri $GTA_URL -OutFile $zipPath
    Log "LOG" "Extraindo manifest em: $manifestDest"
    
    Expand-Archive -Path $zipPath -DestinationPath $manifestDest -Force
    Log "OK" "Manifest do GTA V instalado com sucesso!"
} catch {
    Log "ERR" "Erro ao instalar Manifest: $_"
}

# 7. Finalização
Log "INFO" "Limpando arquivos temporarios..."
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host "       INSTALACAO CONCLUIDA COM SUCESSO!    " -ForegroundColor Green
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host ""
Log "OK" "Tudo pronto. Reinicie seu Steam."
Read-Host "Aperte Enter para sair"
