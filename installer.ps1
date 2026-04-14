# Script de Instalação: Steam Tools & GTA V Depot Manifests (Versão Atualizada)
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

function Log($Type, $Message) {
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
    cmd /c pause
    return
}

# 2. FECHAR STEAM
Log "WARN" "Fechando o Steam para aplicar as mudancas..."
Stop-Process -Name "Steam" -Force -ErrorAction SilentlyContinue

# 3. CONFIGURAÇÃO DE CAMINHOS
$steamPath = "C:\Program Files (x86)\Steam"
$depotPath = "$steamPath\depotcache"
$appsPath = "$steamPath\steamapps"
$tempDir = "$env:TEMP\GtaToolsInstaller"

if (!(Test-Path $depotPath)) { New-Item -Path $depotPath -ItemType Directory -Force | Out-Null }
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -Path $tempDir -ItemType Directory | Out-Null

# 4. DOWNLOAD E INSTALAÇÃO STEAM TOOLS
Log "INFO" "Baixando Steam Tools..."
$stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"
Log "WARN" "Instale o Steam Tools e FECHE o instalador para continuar."
$proc = Start-Process -FilePath "$tempDir\st.exe" -Wait -PassThru

# 5. DOWNLOAD DOS NOVOS MANIFESTS (Links Atualizados)
Log "INFO" "Instalando novos manifests no Depotcache..."
$manifests = @(
    @{ n="271590.lua"; u="https://www.dropbox.com/scl/fi/uxfpcdr6afzys54x8qbaw/271590.lua?rlkey=nfojbwrrq2awgycgo34zptn0b&st=173lsclt&dl=1" },
    @{ n="271591_6768057890420400504.manifest"; u="https://www.dropbox.com/scl/fi/e15cpv0skhyc08am2hife/271591_6768057890420400504.manifest?rlkey=sm6i1dv3ygz054qam1rtn1gxj&st=0nu7sd1h&dl=1" },
    @{ n="271592_8238436718767500927.manifest"; u="https://www.dropbox.com/scl/fi/7qq1iydnv691bzsoywzx4/271592_8238436718767500927.manifest?rlkey=cy81g3u8o273an0h4j15roaam&st=6et8h98s&dl=1" },
    @{ n="271593_2967789647252082634.manifest"; u="https://www.dropbox.com/scl/fi/iq5kx3d8wyrvvos5agffu/271593_2967789647252082634.manifest?rlkey=ubby7t99gflswnc06k6jczxp9&st=wtnpwfg8&dl=1" },
    @{ n="271594_8854874882423166314.manifest"; u="https://www.dropbox.com/scl/fi/or4kr8dekqsycl0eb4lvv/271594_8854874882423166314.manifest?rlkey=jedaiel4io8d6zjzp0ilyrcgt&st=chg1txva&dl=1" },
    @{ n="271595_1376135673068470825.manifest"; u="https://www.dropbox.com/scl/fi/ovgp2j5fbx761t02kplcs/271595_1376135673068470825.manifest?rlkey=128kqemi805ywfyrwr0wsuiad&st=zh2ro8iz&dl=1" },
    @{ n="1899671_274155245002712969.manifest"; u="https://www.dropbox.com/scl/fi/s0u1vbc7ako4ejtmq112x/1899671_274155245002712969.manifest?rlkey=3ztek241eruynrgffemtgl57h&st=cej2d97l&dl=1" }
)

foreach ($file in $manifests) {
    Log "INFO" "Baixando: $($file.n)"
    Invoke-WebRequest -Uri $file.u -OutFile "$depotPath\$($file.n)"
}

# 6. CRIAR APPMANIFEST DO GTA V
Log "INFO" "Registrando jogo na biblioteca do Steam..."
$acfContent = '"AppState"{"appid" "271590" "Universe" "1" "StateFlags" "4" "installdir" "Grand Theft Auto V"}'
$acfContent | Out-File -FilePath "$appsPath\appmanifest_271590.acf" -Encoding ASCII

# 7. LIMPEZA
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }

Write-Host ""
Log "OK" "INSTALACAO CONCLUIDA COM SUCESSO!"
Log "INFO" "Abra o Steam e o GTA V aparecera como instalado."
Log "INFO" "Pressione qualquer tecla para fechar."
cmd /c pause > $null
