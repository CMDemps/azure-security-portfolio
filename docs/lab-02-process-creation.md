
# 🛡️ Case Study 2 — Suspicious Process Creation  
## **Suspicious PowerShell Downloader (Security 4688)**  
**File:** `lab-02-process-creation.md`  
**Status:** Completed  

---

## Executive Summary
A behavioral detection rule identified **PowerShell execution with downloader/stager characteristics** on the Windows lab VM (`vm-win-sc200-la`). The activity resembled common attacker techniques used during initial access and payload staging, such as retrieving a remote script via `Invoke-WebRequest`.

This case study simulates how a SOC analyst would investigate, contain, and document such an alert in a real-world environment while leveraging Azure Sentinel.

---

## Event Overview

| Field | Value |
|-------|-------|
| **Host** | `vm-win-sc200-la` |
| **User** | `labadmin` |
| **Detection Name** | Suspicious PowerShell Downloader / Stager |
| **Technique** | Execution (T1059.001 – PowerShell) |
| **Data Source** | Windows Security Event ID 4688 |
| **Initial Indicator** | powershell.exe launched with potential downloader syntax |

---

## Detection Details

This alert triggered when `powershell.exe` was launched with command-line activity suggesting remote content retrieval using PowerShell as a **LOLBAS (Living-Off-the-Land Binary and Script)**.

Examples of suspicious behavior:
- `Invoke-WebRequest`
- `DownloadString`, `DownloadFile`
- `IEX` for in-memory execution
- BITS usage (`Start-BitsTransfer`)
- Encoded commands (`-EncodedCommand`)
- HTTP/HTTPS URLs for payload retrieval

The detection logic inspects **Security 4688** events and extracts:
- New process name  
- Command-line arguments  
- Indicators of downloader behavior  

---

## Investigation Steps

### **1. Validate the Alert**
Open Sentinel → **Incidents**, locate the alert, and verify:
- Host entity = `vm-win-sc200-la`
- Process entity = `powershell.exe`
- CommandLine shows downloader-like behavior

### **2. Pull Raw Security 4688 Logs**

```kusto
Event
| where EventLog == "Security"
| where EventID == 4688
| where RenderedDescription contains "powershell.exe"
| project TimeGenerated, Computer, RenderedDescription
```

Purpose:
- Confirm process initiation
- Review parent-child relationships
- Validate the command-line execution

---

### **3. Identify Process Lineage**

Key fields:
- **Creator Process Name:** origin of execution  
- **NewProcessName:** launched process  
- **Process Command Line:** behavioral evidence  

Analyst looks for:
- Bypass flags (`-ExecutionPolicy Bypass`)
- In-memory execution (`IEX`)
- URLs (e.g., `http://<IP>/payload.ps1`)
- Encoded command patterns

---

### **4. Determine Scope**

#### Search for payload evidence:
```kusto
search "payload.ps1"
```

#### Search for all PowerShell executions:
```kusto
Event
| where EventLog == "Security"
| where EventID == 4688
| where RenderedDescription contains "powershell"
```

Purpose:
- Identify whether the payload executed  
- Check for follow‑on commands or multiple downloader attempts  

---

### **5. Network Indicator Review**
If flows or NSG logs are available:
- Validate outbound HTTP traffic to attacker IP (`Kali`)
- Check for repeated retrieval attempts

---

### **6. Confirm User Attribution**
Based on 4688:
- `TargetUserName` and `TargetDomainName`
- Logon session ID

In this lab:
- User `labadmin` initiated the downloader command.

---

## Containment (Simulated)

In a real SOC:
- Terminate PowerShell process
- Block attacker IP in NSG/firewall
- Apply host isolation if needed
- Reset compromised credentials
- Restrict PowerShell via Execution Policy or Constrained Language Mode

For this lab:
- Containment actions are **simulated** only.

---

## 🔧 Eradication & Recovery (Simulated)
- Remove downloaded payload
- Clear scheduled tasks or autoruns (if created)
- Reinforce PowerShell logging (Script Block, Module Logging)
- Validate machine baseline integrity

---

## Lessons Learned

- Behavioral detections outperform signature-based ones for PS abuse  
- 4688 visibility depends on proper command-line logging  
- PowerShell remains one of the most abused attack surfaces  
- Proper auditing (4688 + command line, Script Block Logging, AMSI) improves detection capability  

---

## MITRE ATT&CK Mapping

| Tactic | Technique |
|--------|-----------|
| **Execution (TA0002)** | T1059 – Command Interpreter |
| **Execution** | T1059.001 – PowerShell |

---

## Conclusion
This incident demonstrates:
- How Sentinel detects malicious PowerShell downloader activity  
- How analysts triage process creation telemetry  
- How to perform full IR workflow from alert → investigation → containment  

