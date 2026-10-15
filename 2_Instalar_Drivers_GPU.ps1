# ==============================================================================
# SCRIPT 2: INSTALACAO E OTIMIZACAO DE DRIVERS DE VIDEO (GPU)
# Atualizado e limpo - Sem referencias externas ou promocoes de terceiros
# Baixa drivers diretamente da NVIDIA, AMD e Intel oficiais
# ==============================================================================

# Execucao automatica como Administrador
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Host.UI.RawUI.WindowTitle = "Instalacao de Drivers & Otimizacao de GPU (Administrador)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Verificacao de conexao com a Internet
if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
    Write-Host "Conexao com a Internet necessaria para baixar os drivers oficiais.`n" -ForegroundColor Red
    Pause
    exit
}

$progresspreference = 'silentlycontinue'

function show-menu {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "     INSTALACAO DE DRIVER DE VIDEO & OTIMIZACOES DE GPU    " -ForegroundColor Yellow
    Write-Host "==========================================================`n" -ForegroundColor Yellow
    Write-Host " 1. NVIDIA (GeForce Game Ready Driver Oficial)" -ForegroundColor Green
    Write-Host " 2. AMD    (Radeon Software Adrenalin Edition)" -ForegroundColor Red
    Write-Host " 3. INTEL  (Intel Graphics Software / Arc)`n" -ForegroundColor Cyan
    Write-Host "Escolha sua placa de video (1-3): " -NoNewline
}

:MainLoop while ($true) {
    show-menu
    $choice = Read-Host
    if ($choice -match '^[1-3]$') {
        switch ($choice) {
            1 {
                # --------------------------------------------------------------
                # OPCAO 1: NVIDIA
                # --------------------------------------------------------------
                Clear-Host
                Write-Host "CONFIGURANDO INSTALACAO DO DRIVER NVIDIA...`n" -ForegroundColor Green

                # Garante que o 7-Zip esta instalado
                if (!(Test-Path "$env:SystemDrive\Program Files\7-Zip\7z.exe")) {
                    Write-Host "Instalando 7-Zip para descompactar o driver..." -ForegroundColor Yellow
                    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2301-x64.exe" -OutFile "$env:SystemRoot\Temp\7zip.exe" -UseBasicParsing
                    Start-Process -Wait "$env:SystemRoot\Temp\7zip.exe" -ArgumentList "/S"
                }

                Write-Host "Consultando API oficial da NVIDIA para obter a versao mais recente..." -ForegroundColor Yellow
                $uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&isWHQL=1&dch=1&sort1=0&numberOfResults=1'
                $response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
                $payload = $response.Content | ConvertFrom-Json
                $version = $payload.IDS[0].downloadInfo.Version
                $url = $payload.IDS[0].downloadInfo.DownloadURL

                if (!$url) {
                    $windowsVersion = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {"win10-win11"} else {"win8-win7"}
                    $url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-64bit-international-dch-whql.exe"
                }

                Write-Host "Baixando NVIDIA Game Ready Driver versao $version ..." -ForegroundColor Green
                Invoke-WebRequest $url -OutFile "$env:SystemRoot\Temp\nvidiadriver.exe" -UseBasicParsing

                Write-Host "Extraindo arquivos do instalador..." -ForegroundColor Yellow
                & "$env:SystemDrive\Program Files\7-Zip\7z.exe" x "$env:SystemRoot\Temp\nvidiadriver.exe" -o"$env:SystemRoot\Temp\nvidiadriver" -y | Out-Null

                Write-Host "Instalando driver de video silenciosamente (Instalacao Limpa)..." -ForegroundColor Green
                Start-Process "$env:SystemRoot\Temp\nvidiadriver\setup.exe" -ArgumentList "-s -noreboot -noeula -clean" -Wait -NoNewWindow

                Write-Host "Instalando NVIDIA Control Panel oficial via Microsoft Store..." -ForegroundColor Yellow
                try {
                    winget install --id 9NF8H0H7WMLT --source msstore --accept-package-agreements --accept-source-agreements --silent | Out-Null
                } catch {}

                # Atalho do Painel de Controle NVIDIA
                $WshShell = New-Object -comObject WScript.Shell
                $Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
                $Shortcut = $WshShell.CreateShortcut("$Desktop\NVIDIA Control Panel.lnk")
                $Shortcut.TargetPath = "shell:appsFolder\NVIDIACorp.NVIDIAControlPanel_56jybvy8sckqj!NVIDIACorp.NVIDIAControlPanel"
                $Shortcut.WorkingDirectory = "shell:appsFolder"
                $Shortcut.Save()

                Remove-Item "$env:SystemDrive\NVIDIA" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

                Write-Host "Baixando Nvidia Profile Inspector oficial do autor (Orbmu2k)..." -ForegroundColor Yellow
                $inspectorZip = "$env:SystemRoot\Temp\inspector.zip"
                $inspectorDir = "$env:SystemDrive\Program Files (x86)\Nvidia Profile Inspector"
                New-Item -Path $inspectorDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

                $inspectorUrl = "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/v3.0.2.1/nvidiaProfileInspector.zip"
                try {
                    $orbRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/Orbmu2k/nvidiaProfileInspector/releases/latest" -Headers @{"User-Agent"="PowerShell"} -ErrorAction SilentlyContinue
                    $zipAsset = $orbRelease.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
                    if ($zipAsset) { $inspectorUrl = $zipAsset.browser_download_url }
                } catch {}

                Invoke-WebRequest -Uri $inspectorUrl -OutFile $inspectorZip -UseBasicParsing
                & "$env:SystemDrive\Program Files\7-Zip\7z.exe" x $inspectorZip -o"$inspectorDir" -y | Out-Null

                # Criar atalhos do Nvidia Profile Inspector
                $Shortcut = $WshShell.CreateShortcut("$Desktop\Nvidia Profile Inspector.lnk")
                $Shortcut.TargetPath = "$inspectorDir\nvidiaProfileInspector.exe"
                $Shortcut.WorkingDirectory = $inspectorDir
                $Shortcut.Save()

                $Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Nvidia Profile Inspector.lnk")
                $Shortcut.TargetPath = "$inspectorDir\nvidiaProfileInspector.exe"
                $Shortcut.WorkingDirectory = $inspectorDir
                $Shortcut.Save()

                Write-Host "Aplicando perfil otimizado para baixissima latencia (Input Lag Minimo)..." -ForegroundColor Green
                $nipfile = @'
<?xml version="1.0" encoding="utf-16"?>
<ArrayOfProfile>
  <Profile>
    <ProfileName>Base Profile</ProfileName>
    <Executables/>
    <Settings>
      <ProfileSetting>
        <SettingNameInfo>Frame Rate Limiter V3</SettingNameInfo>
        <SettingID>277041154</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>GSYNC - Application Mode</SettingNameInfo>
        <SettingID>294973784</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>GSYNC - Application State</SettingNameInfo>
        <SettingID>279476687</SettingID>
        <SettingValue>4</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>GSYNC - Global Feature</SettingNameInfo>
        <SettingID>278196567</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>GSYNC - Global Mode</SettingNameInfo>
        <SettingID>278196727</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Maximum Pre-Rendered Frames</SettingNameInfo>
        <SettingID>8102046</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Preferred Refresh Rate</SettingNameInfo>
        <SettingID>6600001</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Ultra Low Latency - CPL State</SettingNameInfo>
        <SettingID>390467</SettingID>
        <SettingValue>2</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Ultra Low Latency - Enabled</SettingNameInfo>
        <SettingID>277041152</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Vertical Sync</SettingNameInfo>
        <SettingID>11041231</SettingID>
        <SettingValue>138504007</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Antialiasing - Mode</SettingNameInfo>
        <SettingID>276757595</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic Filter - Optimization</SettingNameInfo>
        <SettingID>8703344</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Anisotropic Filter - Sample Optimization</SettingNameInfo>
        <SettingID>15151633</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Texture Filtering - Quality</SettingNameInfo>
        <SettingID>13510289</SettingID>
        <SettingValue>20</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>CUDA - Force P2 State</SettingNameInfo>
        <SettingID>1343646814</SettingID>
        <SettingValue>0</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>CUDA - Sysmem Fallback Policy</SettingNameInfo>
        <SettingID>283962569</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Power Management - Mode</SettingNameInfo>
        <SettingID>274197361</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Shader Cache - Cache Size</SettingNameInfo>
        <SettingID>11306135</SettingID>
        <SettingValue>4294967295</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
      <ProfileSetting>
        <SettingNameInfo>Threaded Optimization</SettingNameInfo>
        <SettingID>549528094</SettingID>
        <SettingValue>1</SettingValue>
        <ValueType>Dword</ValueType>
      </ProfileSetting>
    </Settings>
  </Profile>
</ArrayOfProfile>
'@
                Set-Content -Path "$env:SystemRoot\Temp\inspector.nip" -Value $nipfile -Force
                Start-Process -Wait "$inspectorDir\nvidiaProfileInspector.exe" -ArgumentList "-silentImport -silent $env:SystemRoot\Temp\inspector.nip"

                Write-Host "Aplicando ajustes de registro de latencia para NVIDIA..." -ForegroundColor Green
                $subkeys = Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue
                foreach ($key in $subkeys) {
                    if ($key -notlike '*Configuration') {
                        reg add "$key" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f | Out-Null
                        reg add "$key" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f | Out-Null
                        reg add "$key" /v "RmProfilingAdminOnly" /t REG_DWORD /d "0" /f | Out-Null
                    }
                }

                $pathDrs = "C:\ProgramData\NVIDIA Corporation\Drs"
                if (Test-Path $pathDrs) { Get-ChildItem -Path $pathDrs -Recurse | Unblock-File }

                cmd /c "reg add `"HKLM\System\ControlSet001\Services\nvlddmkm\Parameters\Global\NVTweak`" /v `"NvCplPhysxAuto`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
                cmd /c "reg add `"HKLM\System\ControlSet001\Services\nvlddmkm\Parameters\Global\NVTweak`" /v `"NvDevToolsVisible`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
                cmd /c "reg add `"HKLM\System\ControlSet001\Services\nvlddmkm\Parameters\Global\NVTweak`" /v `"RmProfilingAdminOnly`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
                cmd /c "reg add `"HKCU\Software\NVIDIA Corporation\NvTray`" /v `"StartOnLogin`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
                cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS`" /v `"EnableGR535`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

                break MainLoop
            }

            2 {
                # --------------------------------------------------------------
                # OPCAO 2: AMD
                # --------------------------------------------------------------
                Clear-Host
                Write-Host "CONFIGURANDO INSTALACAO DO DRIVER AMD...`n" -ForegroundColor Red

                $spoofwebbrowser = @{
                    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
                    "Accept"     = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
                    "Referer"    = "https://www.amd.com/"
                }

                Write-Host "Buscando instalador oficial do AMD Software Adrenalin..." -ForegroundColor Yellow
                $amdPage = Invoke-WebRequest "https://www.amd.com/en/support/download/drivers.html" -Headers $spoofwebbrowser -UseBasicParsing
                $DownloadAmd = $amdPage.Links | Where-Object { $_.href -match "drivers\.amd\.com/drivers/installer/.*/whql/amd-software-adrenalin-edition-.*-minimalsetup-.*_web\.exe" } | Select-Object -First 1

                Invoke-WebRequest $DownloadAmd.href -UseBasicParsing -Headers $spoofwebbrowser -OutFile "$env:SystemRoot\Temp\amddriver.exe"

                Write-Host "Iniciando instalador oficial da AMD..." -ForegroundColor Green
                Start-Process -Wait "$env:SystemRoot\Temp\amddriver.exe"

                $WshShell = New-Object -comObject WScript.Shell
                $Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
                $Shortcut = $WshShell.CreateShortcut("$Desktop\AMD Radeon Software.lnk")
                $Shortcut.TargetPath = "$env:SystemDrive\Program Files\AMD\CNext\CNext\RadeonSoftware.exe"
                $Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\AMD\CNext\CNext"
                $Shortcut.Save()

                Remove-Item "$env:SystemDrive\AMD" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

                Write-Host "Aplicando ajustes de registro de latencia para AMD..." -ForegroundColor Green
                cmd /c "reg add `"HKCU\Software\AMD\CN`" /v `"AutoUpdate`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
                cmd /c "reg add `"HKCU\Software\AMD\CN`" /v `"WizardProfile`" /t REG_SZ /d `"PROFILE_CUSTOM`" /f >nul 2>&1"

                $basePath = "HKLM:\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
                $adapterKeys = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue
                foreach ($key in $adapterKeys) {
                    if ($key.PSChildName -match '^\d{4}$') {
                        cmd /c "reg add `"$($key.Name)`" /v `"KMD_DeLagEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
                    }
                }

                $allKeys = Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue
                $optionKeys = $allKeys | Where-Object { $_.PSChildName -eq "UMD" }
                foreach ($key in $optionKeys) {
                    cmd /c "reg add `"$($key.Name)`" /v `"VSyncControl`" /t REG_BINARY /d `"3000`" /f >nul 2>&1"
                    cmd /c "reg add `"$($key.Name)`" /v `"TFQ`" /t REG_BINARY /d `"3200`" /f >nul 2>&1"
                    cmd /c "reg add `"$($key.Name)`" /v `"Tessellation`" /t REG_BINARY /d `"3100`" /f >nul 2>&1"
                    cmd /c "reg add `"$($key.Name)`" /v `"Tessellation_OPTION`" /t REG_BINARY /d `"3200`" /f >nul 2>&1"
                }

                cmd /c "reg add `"HKCU\Software\AMD\CN`" /v `"SystemTray`" /t REG_SZ /d `"false`" /f >nul 2>&1"
                cmd /c "reg add `"HKCU\Software\AMD\CN`" /v `"CN_Hide_Toast_Notification`" /t REG_SZ /d `"true`" /f >nul 2>&1"
                cmd /c "reg add `"HKCU\Software\AMD\CN`" /v `"AnimationEffect`" /t REG_SZ /d `"false`" /f >nul 2>&1"

                break MainLoop
            }

            3 {
                # --------------------------------------------------------------
                # OPCAO 3: INTEL
                # --------------------------------------------------------------
                Clear-Host
                Write-Host "CONFIGURANDO INSTALACAO DO DRIVER INTEL...`n" -ForegroundColor Cyan

                Write-Host "Abrindo pagina oficial de downloads de drivers da Intel..." -ForegroundColor Yellow
                Start-Process "https://www.intel.com/content/www/us/en/search.html#sortCriteria=%40lastmodifieddt%20descending&f-operatingsystem_en=Windows%2011%20Family*&f-downloadtype=Drivers&cf-tabfilter=Downloads&cf-downloadsppth=Graphics"
                
                Write-Host "`nBaixe o instalador mais recente para sua placa/processador e pressione qualquer tecla para seleciona-lo..." -ForegroundColor Yellow
                Pause

                Add-Type -AssemblyName System.Windows.Forms
                $Dialog = New-Object System.Windows.Forms.OpenFileDialog
                $Dialog.Title = "Selecione o arquivo de instalacao do driver Intel"
                $Dialog.Filter = "Instaladores (*.exe)|*.exe|Todos os Arquivos (*.*)|*.*"
                $Dialog.ShowDialog() | Out-Null
                $InstallFile = $Dialog.FileName

                if (Test-Path $InstallFile) {
                    Write-Host "Instalando driver Intel..." -ForegroundColor Green
                    Start-Process -Wait "$InstallFile"
                }

                $WshShell = New-Object -comObject WScript.Shell
                $Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
                $Shortcut = $WshShell.CreateShortcut("$Desktop\Intel Graphics Software.lnk")
                $Shortcut.TargetPath = "$env:SystemDrive\Program Files\Intel\Intel Graphics Software\IntelGraphicsSoftware.exe"
                $Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\Intel\Intel Graphics Software"
                $Shortcut.Save()

                Remove-Item "$env:SystemDrive\Intel" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

                Write-Host "Aplicando ajustes de registro de latencia para Intel..." -ForegroundColor Green
                $basePath = "HKLM:\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
                $adapterKeys = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue
                foreach ($key in $adapterKeys) {
                    if ($key.PSChildName -match '^\d{4}$') {
                        cmd /c "reg add `"$($key.Name)\3DKeys`" /f >nul 2>&1"
                        cmd /c "reg add `"$($key.Name)\3DKeys`" /v `"Global_AsyncFlipMode`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
                        cmd /c "reg add `"$($key.Name)\3DKeys`" /v `"Global_LowLatency`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
                    }
                }
                cmd /c "reg add `"HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences`" /v `"DirectXUserGlobalSettings`" /t REG_SZ /d `"SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;`" /f >nul 2>&1"

                break MainLoop
            }
        }
    }
}

# ------------------------------------------------------------------------------
# OTIMIZACOES GLOBAIS DE GPU (APLICADAS A TODAS AS PLACAS)
# ------------------------------------------------------------------------------
Write-Host "`nAplicando otimizacoes globais de video..." -ForegroundColor Yellow

# Desativa gerenciamento automatico de cores do Windows (elimina stutter em jogos)
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\MonitorDataStore"
$monitorKeys = Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue
foreach ($key in $monitorKeys) {
    cmd /c "reg add `"$($key.Name)`" /v `"AutoColorManagementEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
}

# Ativa modo MSI (Message Signaled Interrupts) para todas as placas de video
$gpuDevices = Get-PnpDevice -Class Display -ErrorAction SilentlyContinue
foreach ($gpu in $gpuDevices) {
    $instanceID = $gpu.InstanceId
    cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties`" /v `"MSISupported`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
}

# Exibe todos os icones na barra de tarefas
$notifyiconsettings = Get-ChildItem -Path 'registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings' -Recurse -Force -ErrorAction SilentlyContinue
foreach ($setreg in $notifyiconsettings) {
    if ((Get-ItemProperty -Path "registry::$setreg" -ErrorAction SilentlyContinue).IsPromoted -ne 0) {
        Set-ItemProperty -Path "registry::$setreg" -Name 'IsPromoted' -Value 1 -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  CONFIGURACAO E OTIMIZACAO CONCLUIDAS COM SUCESSO!       " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Reiniciando o computador em 5 segundos para consolidar todas as alteracoes..." -ForegroundColor Yellow

Start-Sleep -Seconds 5
shutdown -r -t 00
