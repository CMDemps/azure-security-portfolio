<#
.SYNOPSIS
  Installs Sysmon with a community baseline config suitable for SC-200 lab telemetry.
  
.USAGE
  Run in elevated PowerShell on the Windows victim VM:
    .\install-sysmon.ps1
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# 1) Temp workspace
$temp = Join-Path $env:TEMP "sysmon"
if (!(Test-Path $temp)) { New-Item -ItemType Directory -Path $temp | Out-Null }

# 2) Download Sysmon
$sysmonZip = Join-Path $temp "Sysmon.zip"
Write-Host "[*] Downloading Sysmon..."
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile $sysmonZip

# 3) Extract
Write-Host "[*] Extracting Sysmon..."
Expand-Archive -Path $sysmonZip -DestinationPath $temp -Force

# 4) Get community config (SwiftOnSecurity baseline)
$configUrl  = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$configPath = Join-Path $temp "sysmonconfig-export.xml"
Write-Host "[*] Downloading Sysmon config..."
Invoke-WebRequest -Uri $configUrl -OutFile $configPath

# 5) Install / Update Sysmon with config
$sysmonExe = Get-ChildItem $temp -Filter "Sysmon64.exe" -Recurse | Select-Object -First 1
if (-not $sysmonExe) { throw "Sysmon64.exe not found after extraction." }

Write-Host "[*] Installing Sysmon with provided config..."
& $sysmonExe.FullName -accepteula -i $configPath

Write-Host "[✓] Sysmon installed or updated successfully with $configPath"
Write-Host "    Validate events in Sentinel using the 'Sysmon' table."
