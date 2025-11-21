# Cloud Threat Detection Lab Architecture
This document provides a complete architectural overview of my Azure-based Cloud Threate Detection home lab.  
It is designed to demonstrate real-world SOC-like workflows, including data collection, threat detection, attack simulation, KQL hunting, incident response, and SOAR automation.

---

# 1. Lab Purpose & Goals
The purpose of this lab is to build an end-to-end Azure Cloud Threat Detection environment using only:
- A **student subscription** (with limited Entra ID permissions)
- A **single Windows VM** as a monitored endpoint
- **Microsoft Sentinel**, **Log Analytics**, **Sysmon**, and **Azure Monitor Agent**
- No admin-level identity permissions required

### Core Learning Objectives
This environment allows me to:
- Practice Threat Detection skills without needing full Azure AD (Entra ID) rights
- Generate **real telemetry** (Sysmon, Windows Events, Security Events)
- Configure **custom Sentinel analytics rules**
- Perform **attack simulations** on my VM
- Write and run **KQL hunting queries**
- Build **playbooks (SOAR)**
- Investigate alerts end-to-end like a Security Analyst

---

# 2. High-Level Architecture Diagram

Below is the topology of my Cloud Threat Detection lab environment:

![SC-200 Lab Topology](../../images/rg-sc200-lab-topology.png)

---

# 3. Azure Resource Overview

All resources are deployed inside a dedicated resource group:

**Resource Group:** `rg-sc200-lab`  
**Region:** North Central US  
**Subscription:** *Azure for Students (University Tenant)*

### Compute
| Resource | Name | Purpose |
|----------|------|---------|
| Windows VM | **VM-WIN-SC200-LAB** | Primary monitored endpoint for threat simulations and telemetry ingestion |

### Networking
| Resource | Name | Purpose |
|----------|------|---------|
| Virtual Network | `vnet-northcentralus-sc200-lab` | Hosts the Windows VM |
| Subnet | `vm` subnet | Internal network for VM |
| Network Security Group | `vm-win-sc200-lab-nsg` | Controls inbound/outbound rules |
| Public IP | Assigned to VM | Allows controlled RDP for brute-force simulation |

### Monitoring & Analytics
| Resource | Name | Purpose |
|----------|------|---------|
| Log Analytics Workspace | `law-sc200-lab` | Central log store for Sentinel |
| Data Collection Rule (DCR) | `MSVMI-northcentralus-vm-win-sc200-lab` | Routes Windows + Sysmon logs to LAW |
| Azure Monitor Agent (AMA) | Installed on VM | Collects event logs & Sysmon logs |
| Microsoft Sentinel | Enabled on `law-sc200-lab` | SIEM/SOAR platform for detection & response |

---

# 4. Telemetry Pipeline (How Logs Flow Through the System)

### **Sysmon** generates detailed host-based telemetry  
- Process creation  
- Network connections  
- Image loads  
- File writes  
- Registry modifications  
- Suspicious parent/child chains  
- LOLBAS activity  

### **Windows Event Logs** provide:
- Authentication events (4624/4625)  
- RDP heuristics  
- PowerShell operational logs

### **Azure Monitor Agent (AMA)** collects:
- Sysmon logs  
- Windows Event Logs  
- Security Events  

### **Data Collection Rule (DCR)** aligns the ingestion pipeline:
- Defines what tables to collect  
- Defines what event streams map to what schema  
- Sends logs to Log Analytics Workspace

### **Log Analytics Workspace (LAW)** acts as:
- A data lake for Sentinel  
- KQL query engine  
- Investigations portal  

### **Microsoft Sentinel** layers on top:
- Analytics rules  
- Threat detection  
- Automation (SOAR)  
- Incident management  
- Hunting queries  
- Workbooks (dashboards)

This creates a **full SIEM pipeline** exactly like a production SOC.

---

# 5. Data Sources Ingested

The following tables are currently active in Log Analytics:

| Table | Source | Description |
|-------|--------|-------------|
| **SysmonEvent** | Sysmon + AMA | Deep endpoint telemetry, ideal for SC-200 detections |
| **SecurityEvent** | Windows Security Logs | Authentication, RDP, policy changes |
| **Event** | Windows Event Logs | Application/System logs |
| **Heartbeat** | AMA | Confirms VM health & agent connectivity |
| **UpdateSummary** | Windows Update | Patch detection |
| **AzureActivity** (optional) | Subscription logs | Admin operations (if allowed by tenant) |

---

# 6. Limitations of Azure for Students (and How the Lab Works Around Them)

Since this lab uses Azure for Students inside a university tenant, I cannot:
- Create Azure AD users  
- Modify directory roles  
- Create service principals or app registrations  
- Enable Defender for Identity (requires domain controllers)  
- Onboard multiple endpoints without extra cost  

**Workarounds:**
- Use a single Windows VM as the “victim machine”
- Focus on Sysmon + Windows logs (very SC-200 relevant)
- Perform attack simulations locally on the VM
- Use Sentinel for custom analytics rules
- Leverage Threat Intelligence feeds (public TI)

---

# 7. Skills This Architecture Supports

### Configure Microsoft Sentinel  
- Connect data sources  
- Create analytics rules  
- Build workbooks  
- Investigations & incidents  

### Perform Threat Detection & Investigation  
- Detect brute-force attempts  
- Detect suspicious PowerShell  
- Detect LOLBAS (Living off the Land) activity  
- Detect port scanning via NSG logs (future)  

### Use KQL for Hunting  
- Sysmon sequences  
- Parent-child anomalies  
- Rare process hunts  
- Threat intel matching    

### Unavailable Topics (due to Student Subscription)  
- Defender for Identity  
- Multi-user identity risk investigations  
- Identity Governance / PIM  
- MDE onboarding for multiple hosts  
- Multi-cloud connectors (AWS/GCP)

The lab compensates for this with deeper **endpoint + SIEM + KQL** focus.

---

# 9. Diagram: Data Flow Summary

```text
[Attacker Actions]
        ↓
[Windows VM: VM-WIN-SC200-LAB]
    - Sysmon
    - Windows Security Logs
        ↓
[Azure Monitor Agent (AMA)]
        ↓
[Data Collection Rule (DCR)]
        ↓
[Log Analytics Workspace]
        ↓
[Microsoft Sentinel]
    - Analytics Rules
    - Incidents
    - Hunting
```

---

# 10. Conclusion

It enables me to practice and demonstrate:  
- Detection engineering  
- Attack simulation  
- KQL analytics  
- End-to-end Sentinel investigations

---
