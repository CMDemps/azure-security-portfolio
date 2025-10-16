# Data Collection Rule (DCR) and Log Analytics Integration

**Resource Group:** `rg-sentinel-lab`  
**Region:** `West US 2`  
**DCR Name:** `dcr-westus2-sentinel`  
**Workspace:** `law-westus-sentinel`  
**Endpoint:** `dce-westus2-sentinel`  
**Virtual Machine:** `win-soc-vm`

---

## Objective
Configure a complete telemetry pipeline from an Azure Virtual Machine into Microsoft Sentinel using the Azure Monitor Agent (AMA), Data Collection Rule (DCR), and Data Collection Endpoint (DCE).

---

## Configuration Summary

1. **Created DCE:** `dce-westus2-sentinel`  
   - Region: West US 2  
   - Linked to Log Analytics workspace `law-westus-sentinel`.

2. **Created DCR:** `dcr-westus2-sentinel`  
   - Data Sources:
     - Windows Event Logs (Security, System, Application)
     - Performance Counters (CPU, Memory, Disk)
   - Destination: DCE `dce-westus2-sentinel` → `law-westus-sentinel`
   - Assigned Resource: `win-soc-vm`

3. **Installed Azure Monitor Agent (AMA)** on the VM  
   - Verified data flow via KQL `Heartbeat` and `Event` tables.

---

## Verification

**KQL Queries:**
```kql
Heartbeat
| where Computer == "win-soc-vm"
| sort by TimeGenerated desc

Event
| summarize Count = count() by EventLog
| sort by Count desc
