# 📘 Azure Security Portfolio — Project Index

*DevSecOps • Cloud Security Engineering • Threat Detection*

This page serves as a central index for all major projects within my **Azure Cloud Security Portfolio**.  
Each project demonstrates hands-on skills aligned with **Azure Security Engineer (AZ-500)**, **Cybersecurity Architect (SC-100)**, and **real cloud detection engineering** practices.

---

## 🧭 Project Overview

| Project | Focus Area | Status |
|--------|------------|--------|
| **Project A — Cloud Threat Detection Lab** | KQL detections, Sysmon, Sentinel, MITRE ATT&CK | 🟩 Active |
| **Project B — Azure Landing Zone Lite** | Secure cloud architecture (IaC: Bicep/Terraform) | 🟨 In Progress |
| **Project C — DevSecOps Pipelines** | CI/CD security, OIDC, Checkov, tfsec, CodeQL | 🟨 In Progress |

---

## 🚨 Project A — Cloud Threat Detection Lab

**Folder:** [`/detections`](detections/) & [`/docs`](docs/)

A complete cloud detection engineering environment using:

- Azure Log Analytics Workspace  
- Azure Monitor Agent (AMA)  
- Windows Security Event Logs (Event Table)  
- Sysmon (optional)  
- KQL-based detections  
- MITRE ATT&CK mapping  
- Investigation case studies  

### 🔗 Key Files

- **Case Study 01:** [RDP Brute Force Detection](docs/lab-01-bruteforce-detection.md)  
- **Case Study 02:** [Suspicious Process Creation](docs/labs-01-process-creation.md)  
- **Detection Pack:** [`detections.md`](detections/detections.md)
- **Architecture:** [`ctd-lab-architecture.md`](docs/architecture/ctd-lab-architecture.md)

### 🧠 Skills Demonstrated

- Cloud threat detection engineering  
- KQL analytics  
- Sysmon + AMA log analysis  
- MITRE ATT&CK alignment  
- Sentinel analytics rule creation  
- Investigation & triage workflow  

---

## 🏗️ Project B — Azure Landing Zone Lite

**Folder:** [`/infra`](infra/)

A secure, minimal Azure Landing Zone that can be deployed in an Azure Student Subscription using **Infrastructure-as-Code**.

### 🔐 Components

- Resource Groups  
- VNet + Subnets (App / Mgmt / Logging)  
- NSGs with least privilege rules  
- Key Vault  
- Log Analytics Workspace  
- Diagnostic settings  
- Hardened Windows/Linux VMs  

### 📦 IaC Implementations

- [`/infra/bicep`](infra/bicep/) — Bicep Modules  
- [`/infra/terraform`](infra/terraform/) — Terraform (optional)  

### 📘 Documentation

- [`landing-zone-architecture.md`](docs/architecture/landing-zone-architecture.md)  

### 🧠 Skills Demonstrated

- Azure network design  
- Zero Trust segmentation (Lite model)  
- Resources-as-Code  
- Secure VM deployment  
- Cloud architecture diagramming  

---

## ⚙️ Project C — DevSecOps Pipelines

**Folder:** [`/pipelines`](pipelines/)

Security-integrated CI/CD pipelines using GitHub Actions + Azure OIDC.

### 🔧 Pipeline Features

- IaC linting  
- IaC security scanning (Checkov / tfsec)  
- CodeQL static analysis  
- Secret scanning  
- Container image scanning (Trivy)  
- GitHub OIDC → Azure (No secrets)  
- Automated Bicep/Terraform deployments  

### 📘 Documentation

- [`infra-deploy-pipeline.md`](docs/architecture/infra-deploy-pipeline.md)  

### 🧠 Skills Demonstrated

- DevSecOps workflow design  
- GitHub Actions automation  
- Security gates in CI/CD  
- Scanning: IaC, code, containers  
- Secure cloud deployment automation  

---

## 🧩 Future Enhancements

### 🔄 For Detection Lab

- Additional MITRE-aligned detections  
- Behavioral analytics Notebook  
- Sentinel-as-Code export (if tenant permits)

### 🛡 For Landing Zone

- Azure Firewall / NSG Flow Logs  
- Azure Bastion integration  
- DCR (Data Collection Rule) automation  

### 🔧 For DevSecOps

- Drift detection & compliance pipeline  
- Azure Policy-as-Code  
- Automated workbook deployment  

---

## 📫 Contact

If you'd like to discuss cloud security engineering, DevSecOps, or detection engineering:

**LinkedIn:** <linkedin.com/in/claytondemps>

---
