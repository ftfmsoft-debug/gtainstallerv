# Script de Instalação Profissional: Steam Tools & GTA V Legacy
# Baseado no estilo voidtools.cloud

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# --- CONFIGURAÇÃO DE LINKS ---
$ST_URL = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
$GTA_URL = "https://www.dropbox.com/scl/fi/hr4ev06ynw6ey3mnsquvr/271590.zip?rlkey=zzokdeb8fn5mfhmkfmm1xyj3q&st=70mtatc9&dl=1"
$tempDir = "$env:TEMP\GtaToolsInstaller"

# Função de Log com Cores
function Log {
    param ([string]$Type, [string]$Message)
    $Type = $Type.ToUpper()
    switch ($Type) {
        "OK"   { $fg = "Green" }
        "INFO" { $fg = "Cyan" }
        "ERR"  { $fg = "Red" }
        "WARN" { $fg = "Yellow" }
        "LOG"  { $fg = "Magenta" }
        default { $fg = "White" }
    }
    $date = Get-Date -Format "HH:mm:ss"
    Write-Host "[$date] " -ForegroundColor "DarkGray" -NoNewline
    Write-Host "[$Type] " -ForegroundColor $fg -NoNewline
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

# Início
Show-Banner
Log "INFO" "Verificando ambiente..."

# 1. Verificar Privilégios
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "ERR" "ERRO: Execute o PowerShell como ADMINISTRADOR!"
    exit
}

# 2. Localizar Steam via Registro
Log "LOG" "Buscando o Steam no sistema..."
$steamPath = $null
$registries = @("HKLM:\SOFTWARE\WOW6432Node\Valve\Steam", "HKLM:\SOFTWARE\Valve\Steam", "HKCU:\SOFTWARE\Valve\Steam")
foreach ($reg in $registries) {
    if (Test-Path $reg) {
        $path = (Get-ItemProperty -Path $reg -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
        if ($path -and (Test-Path $path)) { $steamPath = $path; break }
    }
}

if (-not $steamPath) {
    Log "ERR" "Steam nao encontrado automaticamente."
    exit
}
Log "OK" "Steam detectado: $steamPath"

# 3. Preparação
if (!(Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory | Out-Null }

# 4. Instalação do Steam Tools
Log "INFO" "Baixando instalador Steam Tools..."
try {
    $stExe = "$tempDir\st-setup.exe"
    Invoke-WebRequest -Uri $ST_URL -OutFile $stExe
    Log "WARN" "O instalador vai abrir. Siga os passos na tela."
    Start-Process -FilePath $stExe -Wait
    Log "OK" "Instalacao do Steam Tools finalizada."
} catch {
    Log "ERR" "Falha ao baixar Steam Tools."
}

# 5. Instalação do GTA V Legacy (Manifest)
Log "INFO" "Baixando arquivos do GTA V Legacy..."
try {
    $zipPath = "$tempDir\gta_legacy.zip"
    $manifestDest = Join-Path $steamPath "steamapps"
    
    Invoke-WebRequest -Uri $GTA_URL -OutFile $zipPath
    Log "LOG" "Extraindo para a pasta steamapps..."
    
    Expand-Archive -Path $zipPath -DestinationPath $manifestDest -Force
    Log "OK" "GTA V Legacy (Manifest) configurado!"
} catch {
    Log "ERR" "Erro ao processar o Manifest do GTA."
}

# 6. Limpeza
Log "INFO" "Limpando arquivos temporarios..."
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host "       TUDO PRONTO! REINICIE O SEU STEAM    " -ForegroundColor Green
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host ""
Log "OK" "Script finalizado."
Read-Host "Aperte Enter para fechar"
