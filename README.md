# Azure Security Portfolio — SC-200 / SOC Analyst Lab

This repository is my hands-on Azure Security / SOC portfolio built to practice Microsoft Sentinel, KQL hunting, incident triage, and endpoint telemetry collection. It contains reproducible lab artifacts (scripts, KQL detections, exported workbooks, and sanitized screenshots) that demonstrate real SOC workflows you can run in a local VirtualBox + Azure environment.

**Credits**  
*Sysmon baseline config: SwiftOnSecurity (used as baseline in scripts)*  

---

## Why This Repo?
* Demonstrates end-to-end security operations: log collection → detection → investigation → response.
* Targets skills measured by Microsoft SC-200 (Microsoft Sentinel, KQL, investigations).
* Reproducible: scripts and step-by-step notes let you recreate the lab in your Azure subscription and on local VMs.

**Note**  
*Actively updating repo with new files and tools to allow for practice with a variety of defensive tools in a Microsoft Azure environment.*

---

## Architecture
```rust
Windows Host (Azure Portal) → Windows Victim VM (Sysmon + AMA) → Log Analytics Workspace → Microsoft Sentinel → Investigator (host or Azure Portal).

[Azure Portal Host]
  ├─ Windows Victim VM  -> Sysmon + Azure Monitor Agent -> Log Analytics Workspace -> Microsoft Sentinel
  └─ Kali Attacker VM    -> Simulates attacks (brute-force, LOLBAS, lateral movement)
```

---

## Repository Structure
```javascript
azure-security-portfolio/
├─ docs/                   → KQL detections, playbooks, notes
├─ scripts/                → install-sysmon.ps1, install-ama.ps1 (lab helpers)
├─ screenshots/            → dated, sanitized screenshots of experiments
├─ workbooks/              → exported Sentinel Workbook JSON
└─ README.md               → this file
```
---

## Quick Start — reproduce the core lab (minimal steps)
_Important: Do not commit workspace keys or tenant secrets to the repo. Use placeholders and pass secrets to scripts at runtime._
1. **Create** a Log Analytics Workspace (LAW) in your Azure subscription.
2. **Enable** Microsoft Sentinel on the LAW.
3. On the **Windows Victim VM** (running in VirtualBox on your host):
   - Copy `scripts/install-sysmon.ps1` to the VM and run as Administrator:
   
     ```powershell
     Set-ExecutionPolicy Bypass -Scope Process -Force
     .\install-sysmon.ps1
     ```
     
   - Then install the Azure Monitor Agent (AMA) and associate the VM with your LAW (run as **Administrator** and pass your workspace details):
     ```powershell
     Set-ExecutionPolicy Bypass -Scope Process -Force
     .\install-ama.ps1 -WorkspaceId "<YOUR-LAW-ID>" -WorkspaceKey "<YOUR-LAW-PRIMARY-KEY>"
     ```
     
   - If your tenant supports Azure Arc, prefer onboarding via Azure Arc + Data Collection Rule (DCR) instead of the legacy workspace key flow.

4. **Verify Ingestion** in Sentinel (Logs):
   
    ```kql
    SecurityEvent | take 10
    Sysmon | take 10
    ```

5. Use the KQL hunts in `docs/detections.md` to build Analytics rules, workbooks, and incidents.

---

## Useful KQL Hunts (examples)

_See `docs/detections.md` for the complete pack._

### Failed logon brute-force (sample)

```kql
SecurityEvent
| where EventID == 4625
| summarize Attempts=count(), IP=tostring(IpAddress) by TargetAccount=tostring(TargetUserName), bin(TimeGenerated, 15m)
| where Attempts > 10
| order by Attempts desc
```

### Suspicious parent→child (LOLBAS)

```kql
Sysmon
| where EventID == 1
| where ParentImage has_any ("regsvr32.exe","rundll32.exe","mshta.exe","powershell.exe")
| project TimeGenerated, Computer, ParentImage, Image, CommandLine, Account
```

---

## Demonstrated Skills

* Log collection & telemetry: Sysmon, Windows Event collection, AMA, Arc (optional).
* KQL hunting: detection queries, triage, and pivoting.
* SOAR basics: scheduled analytics rules and simple playbooks (workbook examples included).
* Investigation workflow: evidence timelines, entity enrichment and containment strategy.
* Documentation discipline: reproducible scripts, sanitized screenshots, exported workbooks.

---

## Security & Privacy Notes

* All screenshots in screenshots/ are sanitized. Do not commit tenant IDs, keys, or PII.
* VM images, VHDs, or other large binary artifacts are excluded (.gitignore contains VM patterns). Use Git LFS only for recordings if necessary.

---

## Next Steps / Roadmap

* Add SOAR playbooks for automated containment & ticketing.
* Add Active Directory attack lab (offline BloodHound export and AD detection rules).
* Publish a GitHub Pages gallery for sanitized screenshots and workbook walk-throughs.

---

## Connect
**LinkedIn:** [linkedin.com/in/clayton-demps-19a894171](https://www.linkedin.com/in/clayton-demps-19a894171/)  
**GitHub:** [github.com/CMDemps](https://github.com/CMDemps)

**Created and Maintained by Clayton Demps**  
*Aspiring Security Operations Analyst | Azure & Microsoft Security Enthusiast*
