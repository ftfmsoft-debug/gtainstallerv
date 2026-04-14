# Script de Instalação: Steam Tools & GTA V (Cópia Exata do Manual)
$ErrorActionPreference = 'SilentlyContinue'

function Log($Type, $Message) {
    $fg = "White"; if ($Type -eq "OK") { $fg = "Green" } elseif ($Type -eq "INFO") { $fg = "Cyan" } elseif ($Type -eq "ERR") { $fg = "Red" } elseif ($Type -eq "WARN") { $fg = "Yellow" }
    Write-Host "[$Type] " -ForegroundColor $fg -NoNewline; Write-Host $Message
}

Clear-Host
Write-Host "      :::::::: ::::::::::: ::::::::::     :::     ::::    ::::  " -ForegroundColor Cyan
Write-Host "    +#++:++#++    +#+     +#++:++#   +#++:++#++ +#+  +:+  +#+  " -ForegroundColor Blue
Write-Host "      ==========================================================" -ForegroundColor DarkGray

# 1. ADMIN
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log "ERR" "EXECUTE COMO ADMINISTRADOR!"; cmd /c pause; return
}

# 2. FECHAR STEAM COMPLETAMENTE (OBRIGATÓRIO)
Log "WARN" "Fechando Steam..."
taskkill /F /IM steam.exe /T > $null 2>&1
Start-Sleep -Seconds 3

# 3. CAMINHOS
$steamPath = "C:\Program Files (x86)\Steam"
$depotPath = "$steamPath\depotcache"
$appsPath = "$steamPath\steamapps"
$commonPath = "$appsPath\common\Grand Theft Auto V"
$tempDir = "$env:TEMP\GtaToolsInstaller"

if (!(Test-Path $depotPath)) { New-Item -Path $depotPath -ItemType Directory -Force | Out-Null }
if (!(Test-Path $commonPath)) { New-Item -Path $commonPath -ItemType Directory -Force | Out-Null }
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force | Out-Null }
New-Item -Path $tempDir -ItemType Directory | Out-Null

# 4. DOWNLOAD STEAM TOOLS
Log "INFO" "Baixando Steam Tools..."
$stUrl = "https://www.dropbox.com/scl/fi/rkffh5lriikh66p46zci6/st-setup-1.8.30-3.exe?rlkey=ru57xfxm4n8wu914wgils1use&st=jhumhix8&dl=1"
Invoke-WebRequest -Uri $stUrl -OutFile "$tempDir\st.exe"
Log "WARN" "Instale o Steam Tools agora. O script continuara apos voce FECHAR o instalador."
Start-Process -FilePath "$tempDir\st.exe" -Wait

# 5. DOWNLOAD DOS MANIFESTS (Links Diretos)
Log "INFO" "Baixando arquivos .manifest e .lua..."
$manifests = @(
    @{ n="271590.lua"; u="https://www.dropbox.com/scl/fi/uxfpcdr6afzys54x8qbaw/271590.lua?rlkey=nfojbwrrq2awgycgo34zptn0b&st=173lsclt&dl=1" },
    @{ n="271591_6768057890420400504.manifest"; u="https://www.dropbox.com/scl/fi/e15cpv0skhyc08am2hife/271591_6768057890420400504.manifest?rlkey=sm6i1dv3ygz054qam1rtn1gxj&st=0nu7sd1h&dl=1" },
    @{ n="271592_8238436718767500927.manifest"; u="https://www.dropbox.com/scl/fi/7qq1iydnv691bzsoywzx4/271592_8238436718767500927.manifest?rlkey=cy81g3u8o273an0h4j15roaam&st=6et8h98s&dl=1" },
    @{ n="271593_2967789647252082634.manifest"; u="https://www.dropbox.com/scl/fi/iq5kx3d8wyrvvos5agffu/271593_2967789647252082634.manifest?rlkey=ubby7t99gflswnc06k6jczxp9&st=wtnpwfg8&dl=1" },
    @{ n="271594_8854874882423166314.manifest"; u="https://www.dropbox.com/scl/fi/or4kr8dekqsycl0eb4lvv/271594_8854874882423166314.manifest?rlkey=jedaiel4io8d6zjzp0ilyrcgt&st=chg1txva&dl=1" },
    @{ n="271595_1376135673068470825.manifest"; u="https://www.dropbox.com/scl/fi/ovgp2j5fbx761t02kplcs/271595_1376135673068470825.manifest?rlkey=128kqemi805ywfyrwr0wsuiad&st=zh2ro8iz&dl=1" },
    @{ n="1899671_274155245002712969.manifest"; u="https://www.dropbox.com/scl/fi/s0u1vbc7ako4ejtmq112x/1899671_274155245002712969.manifest?rlkey=3ztek241eruynrgffemtgl57h&st=cej2d97l&dl=1" }
)

foreach ($m in $manifests) {
    Log "INFO" "Baixando: $($m.n)"
    Invoke-WebRequest -Uri $m.u -OutFile "$depotPath\$($m.n)"
}

# 6. CRIAR APPMANIFEST (Exatamente no formato que o Steam reconhece)
Log "INFO" "Gerando registro de instalacao..."
$acfContent = @'
"AppState"
{
	"appid"		"271590"
	"Universe"		"1"
	"name"		"Grand Theft Auto V"
	"StateFlags"		"1026"
	"installdir"		"Grand Theft Auto V"
	"LastUpdated"		"0"
	"UpdateResult"		"0"
	"SizeOnDisk"		"0"
	"buildid"		"0"
}
'@
# Salvar com codificação ANSI (Essencial para o Steam ler)
[System.IO.File]::WriteAllLines("$appsPath\appmanifest_271590.acf", $acfContent, [System.Text.Encoding]::Default)

# 7. LIMPEZA
Remove-Item $tempDir -Recurse -Force | Out-Null

Write-Host ""
Log "OK" "ARQUIVOS COPIADOS!"
Log "INFO" "1. Abra o Steam Tools."
Log "INFO" "2. Adicione o AppID 271590 se ele nao estiver na lista."
Log "INFO" "3. Clique em 'Unlock' ou 'Apply' no Steam Tools."
Log "INFO" "4. Abra o Steam e o GTA V devera estar pronto para JOGAR."
Log "INFO" "Pressione ENTER para fechar."
cmd /c pause > $null
