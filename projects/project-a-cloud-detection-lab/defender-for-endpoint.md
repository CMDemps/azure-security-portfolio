# Microsoft Defender for Endpoint Configuration

## Overview
Deployed and configured Microsoft Defender for Endpoint across a hybrid environment with 3 devices, demonstrating enterprise endpoint detection and response capabilities.

## Environment

| Device | Type | Role | Status |
|--------|------|------|--------|
| ws01.corp.local | Windows 11 VM (VMware) | Workstation | ✅ Onboarded |
| dc01.corp.local | Windows Server 2022 VM (VMware) | Domain Controller | ✅ Onboarded |
| mdemps-thinkpad | Physical laptop | Testing device | ✅ Onboarded |

**Screenshot:** [Device inventory showing all 3 devices]

## Custom Detection Rules

![DetectionRules](images/DetectionRules.png) `Full list of all detection & analytics rules created.`  

* These rules generated real incidents during testing, validating detection logic and entity mapping.  
* I created 5 custom detection rules using Advanced Hunting (KQL) to detect real-world attack techniques:

### Detection Rule 1: Encoded PowerShell Execution
**MITRE ATT&CK:** T1059.001 - PowerShell  
**Severity:** High  
**Frequency:** Every 1 hour

**Detection Logic:**
Identifies PowerShell executed with encoded commands, commonly used by attackers to evade detection.

**KQL Query:**
```kql
DeviceProcessEvents
| where Timestamp > ago(1h)
| where FileName =~ "powershell.exe"
| where ProcessCommandLine has_any ("-enc", "-encodedcommand", "FromBase64String")
| project Timestamp, DeviceName, DeviceId, AccountName, ProcessCommandLine, InitiatingProcessFileName, ReportId
```

**Entity Mapping:**
- Account: AccountName
- Host: DeviceName
- Process: ProcessCommandLine
- File: FileName

**Testing:** Generated encoded PowerShell command on ws01.corp.local - detection triggered successfully.

---

### Detection Rule 2: Credential Dumping Attempts
**MITRE ATT&CK:** T1003 - Credential Dumping  
**Severity:** High  
**Frequency:** Every 1 hour

**Detection Logic:**
Detects execution of known credential dumping tools and techniques (mimikatz, procdump targeting lsass).

**KQL Query:**
```kql
DeviceProcessEvents
| where Timestamp > ago(1h)
| where (FileName in~ ("mimikatz.exe", "procdump.exe", "procdump64.exe") 
    or ProcessCommandLine has_any ("sekurlsa", "lsadump", "lsass.exe", "lsass.dmp"))
| project Timestamp, DeviceName, DeviceId, AccountName, ProcessCommandLine, InitiatingProcessFileName, ReportId
```

**Entity Mapping:**
- Account: AccountName
- Host: DeviceName
- Process: ProcessCommandLine

---

### Detection Rule 3: Lateral Movement via PsExec
**MITRE ATT&CK:** T1021.002 - SMB/Windows Admin Shares  
**Severity:** High  
**Frequency:** Every 1 hour

**Detection Logic:**
Identifies PsExec usage, a common tool for lateral movement in enterprise environments.

**KQL Query:**
```kql
DeviceProcessEvents
| where Timestamp > ago(1h)
| where FileName in~ ("psexec.exe", "psexec64.exe", "paexec.exe")
    or ProcessCommandLine has_any ("psexec", "\\\\", "-accepteula")
| project Timestamp, DeviceName, DeviceId, AccountName, ProcessCommandLine, InitiatingProcessFileName, ReportId
```

**Entity Mapping:**
- Account: AccountName
- Host: DeviceName
- Process: ProcessCommandLine

---

### Detection Rule 4: Persistence via Registry Run Keys
**MITRE ATT&CK:** T1547.001 - Registry Run Keys  
**Severity:** Medium  
**Frequency:** Every 1 hour

**Detection Logic:**
Detects modifications to registry Run keys, a common persistence mechanism.

**KQL Query:**
```kql
DeviceProcessEvents
| where Timestamp > ago(1h)
| where FileName =~ "reg.exe"
| where ProcessCommandLine has "CurrentVersion\\Run"
| project Timestamp, DeviceName, DeviceId, AccountName, ProcessCommandLine, InitiatingProcessFileName, ReportId
```

**Entity Mapping:**
- Account: AccountName
- Host: DeviceName
- Process: ProcessCommandLine

**Testing:** Added test registry key on ws01.corp.local - detection triggered successfully.

---

### Detection Rule 5: Network Reconnaissance Commands
**MITRE ATT&CK:** T1087 - Account Discovery  
**Severity:** Medium  
**Frequency:** Every 1 hour

**Detection Logic:**
Identifies enumeration commands (net user, net group, net share) often used during reconnaissance.

**KQL Query:**
```kql
DeviceProcessEvents
| where Timestamp > ago(1h)
| where FileName in~ ("net.exe", "net1.exe")
| where ProcessCommandLine has_any ("user", "group", "localgroup", "share", "view")
| summarize CommandCount = count(), Commands = make_set(ProcessCommandLine) 
    by DeviceName, DeviceId, AccountName, bin(Timestamp, 5m)
| where CommandCount >= 3
| project Timestamp, DeviceName, DeviceId, AccountName, CommandCount, Commands
```

**Entity Mapping:**
- Account: AccountName
- Host: DeviceName

**Testing:** Ran multiple net commands on ws01.corp.local within 5 minutes - detection triggered successfully.

---

## Key Learnings

**Defender for Endpoint Provisioning:**
- MDE requires separate provisioning step beyond just having the license
- Navigate to Assets → Devices to trigger initial service setup
- Can take 24-48 hours for full provisioning after license assignment

**Data Flow Timeline:**
- Device Timeline: Shows events within 30-60 minutes of onboarding
- Advanced Hunting tables: Populate within 1-4 hours after onboarding
- Full historical data: Available after 24 hours

**Detection Rule Testing:**
- Use Advanced Hunting to test queries before creating detection rules
- Entity mapping is critical for incident correlation
- Frequency can be adjusted for testing (5 minutes) vs production (1 hour)

## Skills Demonstrated
- ✅ Endpoint onboarding across multiple device types
- ✅ KQL query development for threat detection
- ✅ MITRE ATT&CK framework mapping
- ✅ Custom detection rule creation with entity mapping
- ✅ Attack simulation and validation
- ✅ Hybrid environment security monitoring
