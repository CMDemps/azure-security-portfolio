# SC-200 Detections & Hunts

This file collects KQL hunts and detection queries you can promote to **Analytics Rules** in Microsoft Sentinel.

---

## 1) Brute Force – Excessive Failed Logons (Hunt → Detection)
```kql
SecurityEvent
| where EventID == 4625
| summarize attempts=count(), ip=tostring(IpAddress) by Account=tostring(TargetUserName), bin(TimeGenerated, 15m)
| where attempts > 10
| order by attempts desc
```
### Detection notes
* Schedule: Every 5 min, lookback 15 min
* Grouping: by ip
* Severity: Medium
* Tuning: Exclude known admin scanners

---

## 2) Suspicious Parent -> Child (LOLBAS)
```kql
Sysmon
| where EventID == 1
| where ParentImage has_any ("regsvr32.exe","rundll32.exe","mshta.exe","powershell.exe")
| project TimeGenerated, Computer, ParentImage, Image, CommandLine, User
```

---

## 3) Unusual Outbound Volume by Process
```kql
DeviceNetworkEvents
| summarize conn=count() by InitiatingProcessFileName, RemoteIP, bin(TimeGenerated, 1h)
| where conn > 100
| order by conn desc
```

---

## 4) Rare New Services (Persistance)
```kql
Sysmon
| where EventID in (7045, 13)
| project TimeGenerated, Computer, User, Image=ProcessName, CommandLine
```

---

## 5) Quick Verification Queries
```kql
SecurityEvent | take 10
Sysmon | take 10
```
