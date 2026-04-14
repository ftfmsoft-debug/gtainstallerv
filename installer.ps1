# Script de Instalação Profissional: Steam Tools & GTA V Depot Manifest
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

function Log {
    param ([string]$Type, [string]$Message)
    $colors = @{"OK"="Green"; "INFO"="Cyan"; "ERR"="Red"; "WARN"="Yellow"}
    Write-Host "[$Type] $Message" -ForegroundColor $colors[$Type.ToUpper()]
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
    Log "ERR" "ERRO: VOCE PRECISA EXECUTAR COMO ADMINISTRADOR!"
    Read-Host "Aperte Enter para sair"; exit
}

# 2. CONFIGURAÇÃO DE CAMINHOS
$depotPath = "C:\Program Files (x86)\Steam\depotcache"
$tempDir = "$env:TEMP\GtaToolsInstaller"
if (!(Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory | Out-Null }

# Links (dl=1 para baixar a pasta como zip)
$stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
$folderUrl = "https://www.dropbox.com/scl/fo/2rji37hb8art9t8i0qysp/APTPBMQkob6OnIYrkDzG9Co?rlkey=ojs3gizfa43y4bznfwmukflvh&st=v6ru21d8&dl=1"

# 3. DOWNLOADS
Log "INFO" "Baixando instalador Steam Tools..."
try {
    Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"
    Log "INFO" "Baixando pasta de manifests (isso pode demorar um pouco)..."
    Invoke-WebRequest -Uri $folderUrl -OutFile "$tempDir\manifests.zip"
    Log "OK" "Downloads concluidos."
} catch {
    Log "ERR" "Erro no download. Verifique o link ou a internet."; Read-Host "Enter para sair"; exit
}

# 4. INSTALAR STEAM TOOLS
Log "WARN" "Iniciando instalacao do Steam Tools..."
Log "INFO" "Instale o programa e feche a janela do instalador para continuar."
Start-Process -FilePath "$tempDir\st.exe" -Wait
Log "OK" "Steam Tools pronto."

# 5. EXTRAIR MANIFESTS NO DEPOTCACHE
Log "INFO" "Extraindo manifests para o Depotcache..."
if (!(Test-Path $depotPath)) { New-Item -Path $depotPath -ItemType Directory -Force | Out-Null }

try {
    $extractPath = "$tempDir\extracted_files"
    if (Test-Path $extractPath) { Remove-Item $extractPath -Recurse -Force }
    New-Item -Path $extractPath -ItemType Directory | Out-Null

    Expand-Archive -Path "$tempDir\manifests.zip" -DestinationPath $extractPath -Force
    
    # Move todos os arquivos de dentro da pasta baixada para o depotcache
    Log "LOG" "Movendo arquivos para $depotPath"
    Get-ChildItem -Path "$extractPath\*" -Recurse | Where-Object { ! $_.PSIsContainer } | Move-Item -Destination $depotPath -Force -ErrorAction SilentlyContinue
    
    Log "OK" "Todos os manifests foram instalados no depotcache!"
} catch {
    Log "ERR" "Falha ao extrair manifests: $_"
}

# 6. FINALIZAÇÃO
Log "INFO" "Limpando arquivos temporarios..."
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "      INSTALACAO CONCLUIDA COM SUCESSO!      " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Log "OK" "Pressione ENTER para finalizar e fechar esta janela."
Read-Host ""
exit
