# ==============================================================================
# MENU PRINCIPAL DE OTIMIZACAO DO WINDOWS & DRIVERS DE VIDEO
# Execucao em um unico comando:
# iwr 'https://raw.githubusercontent.com/<USUARIO>/<REPO>/main/run.ps1' -useb | iex
# ==============================================================================

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Host.UI.RawUI.WindowTitle = "Otimizacao do Windows (Administrador)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Configure aqui o seu usuario e repositorio do GitHub para execucao remota via web:
$GitHubUser = "SEU_USUARIO"
$GitHubRepo = "SEU_REPOSITORIO"
$Branch     = "main"
$RawBase    = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$Branch"

function Show-Header {
    Clear-Host
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "           PAINEL DE OTIMIZACAO DO WINDOWS & DRIVERS             " -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host " 1. Otimizar Sistema Completo (Debloat, Latencia & Brave Browser)" -ForegroundColor Green
    Write-Host " 2. Instalar Drivers de Video e Otimizar GPU (NVIDIA / AMD / Intel)" -ForegroundColor Yellow
    Write-Host " 3. Sair`n" -ForegroundColor Red
    Write-Host "Escolha uma opcao (1-3): " -NoNewline
}

while ($true) {
    Show-Header
    $opt = Read-Host
    switch ($opt) {
        "1" {
            Clear-Host
            $localScript = if ($PSScriptRoot) { Join-Path $PSScriptRoot "1_Otimizar_Windows.ps1" } else { "" }
            if ($localScript -and (Test-Path $localScript)) {
                & $localScript
            } else {
                Write-Host "Baixando e iniciando Etapa 1..." -ForegroundColor Yellow
                $scriptCode = (Invoke-WebRequest -Uri "$RawBase/1_Otimizar_Windows.ps1" -UseBasicParsing).Content
                Invoke-Expression $scriptCode
            }
            return
        }
        "2" {
            Clear-Host
            $localScript = if ($PSScriptRoot) { Join-Path $PSScriptRoot "2_Instalar_Drivers_GPU.ps1" } else { "" }
            if ($localScript -and (Test-Path $localScript)) {
                & $localScript
            } else {
                Write-Host "Baixando e iniciando Etapa 2..." -ForegroundColor Yellow
                $scriptCode = (Invoke-WebRequest -Uri "$RawBase/2_Instalar_Drivers_GPU.ps1" -UseBasicParsing).Content
                Invoke-Expression $scriptCode
            }
            return
        }
        "3" {
            Clear-Host
            Write-Host "Saindo... Nenhuma alteracao foi feita.`n" -ForegroundColor Yellow
            return
        }
        default {
            Write-Host "`nOpcao invalida. Digite 1, 2 ou 3." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
