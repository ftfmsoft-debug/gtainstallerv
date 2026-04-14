# Script de Instalação: Steam Tools + GTA V Depot Manifest
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

function Log {
    param ([string]$Type, [string]$Message)
    $colors = @{"OK"="Green"; "INFO"="Cyan"; "ERR"="Red"; "WARN"="Yellow"}
    Write-Host "[$Type] $Message" -ForegroundColor $colors[$Type.ToUpper()]
}

# --- BANNER ESTILO VOID ---
Clear-Host
Write-Host "---------------------------------------------" -ForegroundColor Magenta
Write-Host "   STEAM TOOLS & GTA V DEPOTCACHE SETUP      " -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Magenta

# 1. VERIFICAÇÃO DE ADMIN (Obrigatório para mexer na pasta do Steam)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "ERR" "ERRO: VOCE PRECISA EXECUTAR COMO ADMINISTRADOR!"
    Read-Host "Aperte Enter para fechar"; return
}

# 2. DEFINIR CAMINHOS
$depotPath = "C:\Program Files (x86)\Steam\depotcache"
$tempDir = "$env:TEMP\GtaToolsInstaller"

# Criar pasta temp se não existir
if (!(Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory | Out-Null }

# 3. DOWNLOADS
Log "INFO" "Baixando arquivos..."
try {
    $stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
    $gtaUrl = "https://www.dropbox.com/scl/fi/hr4ev06ynw6ey3mnsquvr/271590.zip?rlkey=zzokdeb8fn5mfhmkfmm1xyj3q&st=70mtatc9&dl=1"
    
    Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"
    Invoke-WebRequest -Uri $gtaUrl -OutFile "$tempDir\gta.zip"
    Log "OK" "Downloads concluidos com sucesso."
} catch {
    Log "ERR" "Falha ao baixar arquivos. Verifique sua conexao."; Read-Host "Enter para sair"; return
}

# 4. INSTALAR STEAM TOOLS
Log "WARN" "Iniciando instalador do Steam Tools..."
Log "INFO" "Aguarde a conclusao da instalacao para continuar o script."
Start-Process -FilePath "$tempDir\st.exe" -Wait
Log "OK" "Instalacao do Steam Tools concluida."

# 5. CONFIGURAR DEPOTCACHE
Log "INFO" "Configurando manifest no depotcache..."

# Verificar se a pasta depotcache existe, se não, criar
if (!(Test-Path $depotPath)) {
    Log "WARN" "Pasta depotcache nao encontrada. Criando..."
    New-Item -Path $depotPath -ItemType Directory -Force | Out-Null
}

try {
    # Extrair os arquivos do zip para uma pasta temporária primeiro
    $extractPath = "$tempDir\extracted"
    if (Test-Path $extractPath) { Remove-Item $extractPath -Recurse -Force }
    New-Item -Path $extractPath -ItemType Directory | Out-Null
    
    Expand-Archive -Path "$tempDir\gta.zip" -DestinationPath $extractPath -Force
    
    # Mover arquivos extraídos para o depotcache
    Log "LOG" "Movendo arquivos para: $depotPath"
    Get-ChildItem -Path "$extractPath\*" | Move-Item -Destination $depotPath -Force
    
    Log "OK" "Manifests instalados com sucesso no depotcache!"
} catch {
    Log "ERR" "Erro ao extrair arquivos: $_"
}

# FINALIZAÇÃO E LIMPEZA
Log "INFO" "Limpando arquivos temporarios..."
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "      INSTALACAO CONCLUIDA COM SUCESSO!      " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Log "OK" "Agora voce pode abrir o Steam e o Steam Tools."
Read-Host "Aperte Enter para fechar"
