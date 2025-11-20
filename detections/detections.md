# 🔍 Cloud Detection Pack — Azure Security Portfolio  
### *KQL Detections • MITRE ATT&CK Mapping • Log Analytics / Sentinel*

This detection pack contains my KQL-based detections created for Azure Log Analytics and Microsoft Sentinel.  
All detections are mapped to MITRE ATT&CK techniques and aligned with cloud threat detection best practices.

Each detection includes:

- 🎯 Purpose  
- 🧠 Description & threat behavior  
- 🗂 Log sources  
- 📘 KQL query  
- 🧩 MITRE mapping  
- ⚠️ False positives / tuning guidance  
- 🔧 Deployment notes (optional Sentinel rule configs)

---

# 📚 Table of Contents

- [Credential Access (TA0006)](#credential-access-ta0006)
- [Execution (TA0002)](#execution-ta0002)
- [Discovery (TA0007)](#discovery-ta0007)
- [Lateral Movement (TA0008)](#lateral-movement-ta0008)
- [Defense Evasion (TA0005)](#defense-evasion-ta0005)
- [Persistence (TA0003)](#persistence-ta0003)
- [Exfiltration (TA0010)](#exfiltration-ta0010)
- [Impact (TA0040)](#impact-ta0040)

---

# 🔐 Credential Access (TA0006)

## **T1110 — Brute Force (RDP / Network Logon)**  
**Status:** ✔ Implemented as Sentinel Analytics Rule  
**File:** `lab-01-bruteforce-detection.md`

### 🎯 Purpose  
Detect repeated failed RDP or network logon attempts from a single IP in a short time window.

### 🗂 Log Sources  
- `Event` (AMA — Windows Security Events)  
- Event ID: **4625**  

### 📘 KQL  
```kusto
Event
| where EventLog == "Security"
| where EventID == 4625
| extend ParamList = extract_all(@'<Param>(.*?)</Param>', tostring(ParameterXml))
| extend 
    TargetUser = tostring(ParamList[5]),
    LogonType  = tostring(ParamList[10]),
    Workstation = tostring(ParamList[13]),
    SourceIp   = tostring(ParamList[18])
| where LogonType == "3" or LogonType == "10"
| where SourceIp != "0.0.0.0" and SourceIp != ""
| summarize FailedCount = count() by 
    SourceIp, 
    TargetUser, 
    Computer, 
    bin(TimeGenerated, 5m)
| where FailedCount >= 5
```
### 🧩 MITRE Mapping

- **Tactic:** Credential Access
- **Technique:** T1110 — Brute Force
    
### ⚠️ Notes / False Positives

- Users forgetting passwords
- Misconfigured scripts / services  
- Admin testing credentials

---    

# ⚙ Execution (TA0002)

## Suspicious PowerShell Execution (PS-LOLBAS / Recon Tooling)
**Status:** ⏳ Pending Case Study 2

### 🎯 Purpose
Detect suspicious PowerShell usage consistent with recon, LOLBAS abuse, or malicious script execution.

### 🗂 Log Sources
- ```Event``` (PowerShell Operational logs if enabled)
- ```Sysmon``` Event ID 1

### 📘 KQL (Template)
```kql
Sysmon
| where EventID == 1
| where Process has "powershell.exe"
| extend Cmd = CommandLine
| where Cmd matches regex @"(DownloadString|Invoke-WebRequest|IEX|Hidden|Bypass)"
| project TimeGenerated, Computer, User, Process, Cmd
```

### 🧩 MITRE Mapping

- **Technique:** T1059 — Command and Scripting Interpreter
- **Sub-technique:** PowerShell (T1059.001)
  
### ⚠️ Notes / False Positives

- Legitimate admin automation
- Monitoring scripts  
- Scheduled tasks

---

# 🔍 Discovery (TA0007)

## Network Scanning Activity (High Volume Connection Attempts)
**Status:** Template

### 🎯 Purpose
Detect scanning behavior via repeated outbound connections to many ports/IPs.

### 🗂 Log Sources

- ```Sysmon``` Event ID 3 (Network Connection)
    
### 📘 KQL (Template)
```kql
Sysmon
| where EventID == 3
| summarize ConnCount = count() by SourceIp = Computer, DestinationIp, bin(TimeGenerated, 5m)
| where ConnCount > 50
| sort by ConnCount desc
```

### 🧩 MITRE Mapping

- **Technique:** T1046 — Network Service Discovery

---    

# 🔄 Lateral Movement (TA0008)

## Pass-the-Hash/Pass-the-Ticket Indicators
**Status:** Template

### 🎯 Purpose

Identify lateral movement attempts using stolen tokens or credentials.

### 🗂 Log Sources

- ```SecurityEvent``` / ```Event```
- Event ID: 4624, 4625  
- ```Sysmon```
    
### 📘 KQL (Template)
```kql
Event
| where EventID == 4624
| where LogonType == "9" or LogonType == "3"
| extend IpAddress = tostring(AdditionalFields["IpAddress"])
| summarize LogonCount = count() by TargetUser, IpAddress, bin(TimeGenerated, 30m)
| where LogonCount > 10
```

### 🧩 MITRE Mapping

- **Technique:** T1550 — Use of Alternate Authentication Material

---

# 🛡 Defense Evasion (TA0005)

## Execution of LOLBAS Binaries (e.g., certutil, mshta, bitsadmin)
**Status:** Pending Case Study 2

### 🗂 Log Sources

- ```Sysmon``` Event ID 1

---    

### 📘 KQL (Template)
```kql
Sysmon
| where EventID == 1
| where Process in~ ("certutil.exe", "mshta.exe", "bitsadmin.exe", "rundll32.exe")
| project TimeGenerated, Computer, User, Process, CommandLine
```

### 🧩 MITRE Mapping

*   **Technique:** T1218 — Signed Binary Proxy Execution (LOLBAS)
    
---

# ⏳ Persistence (TA0003)

## New Service Installations

### 🎯 Purpose

Detect potential persistence via malicious service creation.

### 📘 KQL (Template)
```kql
Sysmon
| where EventID == 13
| where TargetObject contains "Services"
```

### 🧩 MITRE Mapping

- **Technique:** T1543 - Create or Modify System Process

---

# 🧠 Notes

This detection pack evolves over time as I add new detections from:
- New labs
- Threat simulations
- Purple-team exercises
- Attack emulations
- Cloud-specific threat models

Each detection supports either:
- Threat hunting,
- Analytics rule creation, or
- Behavior anomaly detection

---
