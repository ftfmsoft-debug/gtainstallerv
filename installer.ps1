# Script de Instalação: Steam Tools & GTA V Depot Manifests
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Função de Log ultra-simples e segura contra erros de cor
function Log([string]$Type, [string]$Message) {
    $fg = "White"
    if ($Type -eq "OK") { $fg = "Green" }
    elseif ($Type -eq "INFO") { $fg = "Cyan" }
    elseif ($Type -eq "ERR") { $fg = "Red" }
    elseif ($Type -eq "WARN") { $fg = "Yellow" }
    
    Write-Host "[$Type] " -ForegroundColor $fg -NoNewline
    Write-Host $Message
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
    Log "ERR" "VOCE PRECISA EXECUTAR COMO ADMINISTRADOR!"
    Read-Host "Pressione Enter para sair"
    return
}

# 2. CONFIGURAÇÃO DE CAMINHOS
$depotPath = "C:\Program Files (x86)\Steam\depotcache"
if (!(Test-Path $depotPath)) { 
    New-Item -Path $depotPath -ItemType Directory -Force | Out-Null 
}

$tempDir = "$env:TEMP\GtaToolsInstaller"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -Path $tempDir -ItemType Directory | Out-Null

# 3. DOWNLOAD E INSTALAÇÃO STEAM TOOLS
Log "INFO" "Baixando Steam Tools..."
$stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"

Log "WARN" "Instale o Steam Tools agora. O script continuara apos voce fechar o instalador."
$proc = Start-Process -FilePath "$tempDir\st.exe" -Wait -PassThru
Log "OK" "Steam Tools finalizado."

# 4. DOWNLOAD DOS MANIFESTS
Log "INFO" "Instalando manifests no Depotcache..."

$manifests = @(
    @{ n="271590.lua"; u="https://www.dropbox.com/scl/fi/2b3ivdjgykujloiu4fknt/271590.lua?rlkey=a1669qbo63vkzyhmaxcl16esa&st=n6kxh046&dl=1" },
    @{ n="271591_6768057890420400504.manifest"; u="https://www.dropbox.com/scl/fi/zo6jtjuxvseou3dge5057/271591_6768057890420400504.manifest?rlkey=zwhidfuu9leoxeyi01et51v94&st=91uv2671&dl=1" },
    @{ n="271592_8238436718767500927.manifest"; u="https://www.dropbox.com/scl/fi/6sznfot5eb4g8j10a0wm7/271592_8238436718767500927.manifest?rlkey=n58mc0grcgl095drgaodxxj0x&st=xe6uv0t3&dl=1" },
    @{ n="271593_2967789647252082634.manifest"; u="https://www.dropbox.com/scl/fi/1lkdmuu6ql2g2i9phd9nm/271593_2967789647252082634.manifest?rlkey=3h4j65hmhwjzmnjyia9wumuqi&st=e9ld03gi&dl=1" },
    @{ n="271594_8854874882423166314.manifest"; u="https://www.dropbox.com/scl/fi/wyffhxej965kx74g50pwv/271594_8854874882423166314.manifest?rlkey=n189lywe18z3jt1rx5tmpf8fm&st=vujog6ro&dl=1" },
    @{ n="271595_1376135673068470825.manifest"; u="https://www.dropbox.com/scl/fi/ckrrqgcainu79i6o3d5df/271595_1376135673068470825.manifest?rlkey=tiyn9eycxf2ut4kz5ebv29v1p&st=f73mo5pu&dl=1" },
    @{ n="1899671_274155245002712969.manifest"; u="https://www.dropbox.com/scl/fi/by2e8jdmgaxuqhqswj7dx/1899671_274155245002712969.manifest?rlkey=dh5s423z3y3gnhfqyez5okpi8&st=lsku86hy&dl=1" }
)

foreach ($file in $manifests) {
    Log "INFO" "Baixando: $($file.n)"
    Invoke-WebRequest -Uri $file.u -OutFile "$depotPath\$($file.n)"
}

# 5. LIMPEZA
Log "INFO" "Limpando arquivos temporarios..."
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue }

# 6. MENSAGEM FINAL
Write-Host ""
Log "OK" "INSTALACAO CONCLUIDA COM SUCESSO!"
Log "INFO" "Pressione ENTER para fechar este instalador."
Read-Host ""
# FIM DO SCRIPT
