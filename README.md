# Azure Security Portfolio – SC-200 + AZ-900

This portfolio showcases hands-on projects and labs completed while preparing for the **Microsoft Certified: Security Operations Analyst (SC-200)** and **Azure Fundamentals (AZ-900)** certifications.

Each section demonstrates applied skills across Microsoft Sentinel, Defender XDR, Defender for Cloud, Purview, and Azure core services.  
All work was built and validated within a live Azure tenant and documented using real data (redacted where necessary).

---

## Overview

| Certification | Focus Areas | Status |
|----------------|-------------|---------|
| **SC-200: Security Operations Analyst** | Sentinel, Defender XDR, Defender for Cloud, Purview | In Progress |
| **AZ-900: Azure Fundamentals** | Core Cloud Concepts, Architecture, Governance, Cost Mgmt | In Progress |

---

## Environment Overview

All resources are deployed under:
- **Resource Group:** `rg-sentinel-lab`
- **Region:** West US 2
- **Main VM:** `linux-lab-vm` (Ubuntu)
- **Monitoring Stack:** Azure Monitor Agent (AMA), Data Collection Rule (DCR), Log Analytics Workspace (LAW), Microsoft Sentinel, Defender for Cloud

---

## Resource Topology
![Azure SOC Topology](images/topology.png)

### Resource Tree
rg-sentinel-lab
├─ linux-lab-vm (Ubuntu SOC VM)
│ ├─ linux-vm-nic
│ │ ├─ linux-vm-pip (Public IP)
│ │ ├─ linux-lab-vm-nsg (Network Security Group)
│ │ └─ sentinel-lab-vnet (Virtual Network)
│ ├─ linux-lab-vm_ssh (SSH Key)
│ ├─ linux-lab-vm_disk0 / _DataDisk_0 (Managed Disks)
│ └─ Monitoring
│ ├─ MSVMI-westus2-linux-lab-vm (VM Insights Rule)
│ ├─ dcr-westus2-linux-lab-vm (Custom Data Collection Rule)
│ │ ├─ Syslog: auth, authpriv, syslog, daemon, kern, cron, user
│ │ ├─ Perf Counters: CPU, Memory, Disk
│ │ └─ Destination → dce-westus2-sentinel
│ └─ dce-westus2-sentinel (Data Collection Endpoint)
│
├─ law-westus-sentinel (Log Analytics Workspace)
│ ├─ Connected Solutions:
│ │ ├─ SecurityInsights(law-westus-sentinel) – Microsoft Sentinel
│ │ └─ SecurityCenterFree(law-westus-sentinel) – Microsoft Defender for Cloud
│
├─ rgsentinellabperfdiag233 (Diagnostic Storage Account)
├─ vault8634 (Recovery Services Vault)
└─ sentinel-lab-db101325 (Shared Sentinel Dashboard)

---

## Repository Structure

| Folder | Description |
|--------|-------------|
| `/AZ-900/` | Azure Fundamentals labs and architecture exercises |
| `/SC-200/` | Microsoft Sentinel, Defender, and Purview security operations labs |
| `/trackers/` | Certification progress tracking CSVs |
| `/images/` | Diagrams, screenshots, KQL results |

---

## Technologies Used
**Azure Services:** Microsoft Sentinel, Log Analytics, Defender for Cloud, Purview, App Services, Azure Monitor  
**Security Focus:** Incident Detection, Threat Hunting, Automation Rules, SOC Monitoring  
**Languages/Tools:** KQL, Bash, PowerShell, Python, Azure CLI, ARM Templates  

---

## Key Learning Outcomes
- Configure Azure Monitor Agent and DCR for Linux Syslog ingestion  
- Integrate Microsoft Sentinel with Defender for Cloud  
- Develop and validate detection queries using KQL  
- Automate alert triage and response with Sentinel playbooks  

---

## Connect
**LinkedIn:** [linkedin.com/in/claytondemps](https://linkedin.com/in/claytondemps)  
**GitHub:** [github.com/CMDemps](https://github.com/CMDemps)
**Created and maintained by Clayton Demps**  
*Aspiring Security Operations Analyst | Azure & Microsoft Security Enthusiast*
