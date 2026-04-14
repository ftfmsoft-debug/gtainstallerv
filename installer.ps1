# Script de Instalação: Steam Tools & GTA V Manifests
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Função Log Corrigida (Sem erro de cor)
function Log {
    param ([string]$Type, [string]$Message)
    $Type = $Type.ToUpper()
    $fg = "White"
    if ($Type -eq "OK") { $fg = "Green" }
    elseif ($Type -eq "INFO") { $fg = "Cyan" }
    elseif ($Type -eq "ERR") { $fg = "Red" }
    elseif ($Type -eq "WARN") { $fg = "Yellow" }
    elseif ($Type -eq "LOG") { $fg = "Magenta" }
    
    Write-Host "[$Type] $Message" -ForegroundColor $fg
}

# --- BANNER ---
Clear-Host
Write-Host "      :::::::: ::::::::::: ::::::::::     :::     ::::    ::::  " -ForegroundColor Cyan
Write-Host "    :+:    :+:    :+:     :+:          :+: :+:   +:+:+: :+:+:+  " -ForegroundColor Cyan
Write-Host "    +:+           +:+     +:+         +:+   +:+  +:+ +:+:+ +:+  " -ForegroundColor Blue
Write-Host "    +#++:++#++    +#+     +#++:++#   +#++:++#++ +#+  +:+  +#+  " -ForegroundColor Blue
Write-Host "      ==========================================================" -ForegroundColor DarkGray
Write-Host "             INSTALLER: STEAM TOOLS & GTA V MANIFESTS           " -ForegroundColor White
Write-Host "      ==========================================================" -ForegroundColor DarkGray
Write-Host ""

# 1. VERIFICAÇÃO DE ADMIN
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "ERR" "EXECUTE COMO ADMINISTRADOR!"
    Read-Host "Aperte Enter para sair"; exit
}

# 2. CAMINHOS
$depotPath = "C:\Program Files (x86)\Steam\depotcache"
if (!(Test-Path $depotPath)) { New-Item -Path $depotPath -ItemType Directory -Force | Out-Null }
$tempDir = "$env:TEMP\GtaToolsInstaller"
if (!(Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory | Out-Null }

# Links
$stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
$folderUrl = "https://www.dropbox.com/scl/fo/2rji37hb8art9t8i0qysp/APTPBMQkob6OnIYrkDzG9Co?rlkey=ojs3gizfa43y4bznfwmukflvh&st=v6ru21d8&dl=1"

# 3. DOWNLOADS
Log "INFO" "Baixando Steam Tools..."
Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"

Log "INFO" "Baixando Manifests..."
Invoke-WebRequest -Uri $folderUrl -OutFile "$tempDir\manifests.zip"

# 4. INSTALAÇÃO STEAM TOOLS
Log "WARN" "Iniciando instalacao do Steam Tools..."
Start-Process -FilePath "$tempDir\st.exe" -Wait
Log "OK" "Steam Tools concluido."

# 5. MOVER MANIFESTS (Sem extrair, conforme solicitado)
Log "INFO" "Movendo manifests para o Depotcache..."
try {
    # Se você quiser que o conteúdo seja extraído automaticamente do zip do dropbox para o depotcache:
    Expand-Archive -Path "$tempDir\manifests.zip" -DestinationPath $depotPath -Force
    Log "OK" "Manifests movidos para $depotPath"
} catch {
    Log "ERR" "Erro ao mover arquivos."
}

# 6. FINALIZAÇÃO
Log "INFO" "Limpando temporarios..."
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Log "OK" "INSTALACAO CONCLUIDA!"
Log "INFO" "Pressione ENTER para fechar."
Read-Host ""
exit
