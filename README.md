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

## Repository Structure
```
.
├─ SC-200/                → Security Operations Analyst labs
│  ├─ DefenderXDR/
│  ├─ DefenderForCloud/
│  ├─ Purview/
│  └─ Sentinel/
├─ AZ-900/                → Azure Fundamentals labs
│  ├─ Cloud Concepts/
│  ├─ Architecture & Services/
│  └─ Management & Governance/
└─ trackers/              → CSV progress trackers
```

---

## Skills Demonstrated

- **Security Operations:** Analytic rule creation, incident investigation, playbook automation  
- **Cloud Defense:** Defender for Cloud CSPM & workload protection, Purview compliance workflows  
- **Threat Hunting:** KQL queries, UEBA, ASIM normalization, Sentinel notebooks  
- **Azure Administration:** VM deployment, networking, storage redundancy, cost and policy governance  
- **Monitoring & Governance:** Azure Monitor, Workbooks, Budgets, and Policy enforcement

---

## Documentation Approach
Each module folder includes:
- A concise **README.md** describing the lab’s goal and results  
- Relevant **KQL queries**, **JSON exports**, and **screenshots**  
- Any **metrics** or **reports** generated during the lab

---

## Trackers
You can monitor certification progress here:

- [SC-200 Tracker](trackers/SC-200-Tracker.csv)  
- [AZ-900 Tracker](trackers/AZ-900-Tracker.csv)

---

## Notes
- All sensitive tenant data has been sanitized.  
- JSON templates and scripts are provided for reproducibility.  
- Content will evolve as new labs and security tools are added.

---

**Created and maintained by Clayton Demps**  
*Aspiring Security Operations Analyst | Azure & Microsoft Security Enthusiast*
