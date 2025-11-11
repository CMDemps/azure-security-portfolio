<#
.SYNOPSIS
  Installs Azure Monitor Agent (AMA) on a Windows client and connects it to a Log Analytics Workspace.

.USAGE
  Run in elevated PowerShell on the Windows victim VM:
    .\install-ama.ps1 -WorkspaceId "<YOUR-LAW-WORKSPACE-ID>" -WorkspaceKey "<YOUR-LAW-PRIMARY-KEY>"

.NOTES
  For production and modern management, prefer onboarding the machine via **Azure Arc** and associating a **Data Collection Rule (DCR)**.
  This script exists for quick lab/demo scenarios where Arc is unavailable.
#>
param(
  [Parameter(Mandatory=$true)] [string]$WorkspaceId,
  [Parameter(Mandatory=$true)] [string]$WorkspaceKey
)
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

Write-Host "[*] Downloading Azure Monitor Agent (AMA) installer..."
$dl = "$env:TEMP\AzureMonitorAgent.msi"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2191337" -OutFile $dl

Write-Host "[*] Installing AMA silently..."
Start-Process msiexec.exe -ArgumentList "/i `"$dl`" /qn" -Wait

# Depending on tenant policy, you may not have the legacy MMA helper present.
# If present, we can leverage it to pair the workspace ID/Key quickly for lab use.
$mmaHelper = "$env:ProgramFiles\Microsoft Monitoring Agent\Agent\PowerShell\InstallAgent.ps1"
if (Test-Path $mmaHelper) {
  Write-Host "[*] Pairing workspace via legacy helper..."
  & powershell -ExecutionPolicy Bypass -File $mmaHelper -WorkspaceId $WorkspaceId -WorkspaceKey $WorkspaceKey -AcceptEndUserLicenseAgreement
} else {
  Write-Warning "Legacy MMA helper not found. If this fails to onboard, use Azure Arc + DCR to associate AMA with your LAW."
}

Write-Host "[✓] AMA install complete. Verify ingestion in Sentinel:"
Write-Host "    - SecurityEvent | take 10"
Write-Host "    - Sysmon | take 10"
