# 📘 Azure Security Portfolio — Project Index

*DevSecOps • Cloud Security Engineering • Threat Detection*

This page serves as a central index for all major projects within my **Azure Cloud Security Portfolio**.  
Each project demonstrates hands-on skills aligned with **Azure Security Engineer (AZ-500)**, **Cybersecurity Architect (SC-100)**, **Security Operations Analyst (SC-200)**, and **real cloud detection engineering** practices.

> 📌 **Navigation**: [Main README](README.md) | [Architecture Docs](docs/architecture/) | [Scripts](scripts/)

---

## 📊 Project Overview

| Project | Focus Area | Skills | Status |
|--------|------------|--------|--------|
| **[Project A](#project-a--cloud-threat-detection-lab)** | Cloud Threat Detection Lab | KQL detections, Sysmon, Sentinel, MITRE ATT&CK | 🟩 Complete |
| **[Project B](#project-b--azure-landing-zone-lite)** | Azure Landing Zone Lite | Secure cloud architecture (IaC: Bicep/Terraform) | 🟩 Complete |
| **[Project C](#project-c--devsecops-pipelines)** | DevSecOps Pipelines | CI/CD security, OIDC, Checkov, tfsec, CodeQL | 🟦 Planned |

**Legend:**
- 🟩 Complete — Fully implemented and documented
- 🟨 In Progress — Active development
- 🟦 Planned — Scoped and ready for implementation

---

## 📁 Project A — Cloud Threat Detection Lab

**📂 Folder:** [`/projects/project-a-cloud-detection-lab`](projects/project-a-cloud-detection-lab/)  
**📚 Documentation:** [`/docs/architecture/ctd-lab-architecture.md`](docs/architecture/ctd-lab-architecture.md)

### Overview

A complete cloud detection engineering environment using:

- **Azure Log Analytics Workspace** — Centralized log aggregation
- **Azure Monitor Agent (AMA)** — Modern telemetry collection
- **Windows Security Event Logs** — Core event monitoring (Event Table)
- **Sysmon** (optional) — Enhanced process and network telemetry
- **KQL-based detections** — Custom analytics for threat hunting
- **MITRE ATT&CK mapping** — Framework-aligned detection coverage
- **Investigation case studies** — Real-world incident response scenarios

### 🔍 Detection Coverage

| MITRE Tactic | Techniques Covered | Detection Count |
|--------------|-------------------|-----------------|
| Credential Access (TA0006) | T1110 - Brute Force, T1003 - Credential Dumping | 2 Sentinel + 1 MDE |
| Execution (TA0002) | T1059.001 - PowerShell | 1 Sentinel + 1 MDE |
| Persistence (TA0003) | T1098 - Account Manipulation, T1547 - Registry Run Keys, T1543 - Service Creation, T1098 - AWS IAM Privilege Escalation | 4 Sentinel + 1 MDE |
| Privilege Escalation (TA0004) | T1098.003 - Additional Cloud Roles | 2 Sentinel |
| Lateral Movement (TA0008) | T1021.002 - SMB/Windows Admin Shares | 1 MDE |
| Discovery (TA0007) | T1087 - Account Discovery | 1 MDE |
| Behavioral Analytics (TA0009) | Multi-source detection, UEBA | 2 Sentinel |
| Impact (TA0040) | T1496 - Resource Hijacking (Cryptojacking) | 1 Sentinel |
| Collection (TA0009) | T1530 - Data from Cloud Storage (S3 Exposure) | 1 Sentinel |
| Initial Access (TA0001) | T1078 - Valid Accounts (Cross-Cloud Correlation) | 1 Sentinel |
| **Total Active Detections** | | **11 Sentinel + 5 MDE + 5 Hunts** |

### 📖 Key Files & Documentation

| Document | Description | Status |
|----------|-------------|--------|
| **[Lab 01 — RDP Brute Force Detection](projects/project-a-cloud-detection-lab/labs/lab-01-bruteforce-detection.md)** | Credential access attack detection case study | ✅ Complete |
| **[Lab 02 — Suspicious Process Creation](projects/project-a-cloud-detection-lab/labs/lab-02-process-creation.md)** | PowerShell execution detection and investigation | ✅ Complete |
| **[Lab 03 — AWS-Sentinel Multi-Cloud Detection](projects/project-a-cloud-detection-lab/labs/lab-03-aws-sentinel-integration.md)** | AWS CloudTrail integration, 4 cross-cloud detections | ✅ Complete |
| **[Defender for Endpoint](projects/project-a-cloud-detection-lab/defender-for-endpoint.md)** | 3 devices, 5 custom detection rules, testing validation | ✅ Complete |
| **[Automation Playbooks](projects/project-a-cloud-detection-lab/automation-playbooks.md)** | 5 Logic Apps SOAR workflows overview | ✅ Complete |
| **[Playbook Case Studies](projects/project-a-cloud-detection-lab/playbooks/)** | 3 detailed automation implementations | ✅ Complete |
| **[Analytics Rules](projects/project-a-cloud-detection-lab/detections.md)** | 7+ Sentinel detection rules with MITRE mapping | ✅ Complete |
| **[Workbooks](projects/project-a-cloud-detection-lab/workbooks.md)** | 4 investigation and hunting dashboards | ✅ Complete |
| **[Threat Hunting Queries](projects/project-a-cloud-detection-lab/hunting-queries.md)** | 5 hypothesis-driven threat hunts | ✅ Complete |
| **[Architecture Diagram](docs/architecture/ctd-lab-architecture.md)** | Technical architecture and data flow | ✅ Complete |

### 🎯 Lab Scenarios Implemented

#### Lab 01: RDP Brute Force Detection
**MITRE Technique:** T1110 - Brute Force  
**Log Source:** Windows Security Event 4625  
**Status:** Operational Sentinel rule  

**Key Metrics:**
- Threshold: 5+ failed logons in 5 minutes
- LogonType: 3 (Network) or 10 (RDP)
- Severity: High
- Investigation: Full IP attribution, timeline analysis, lateral movement checks

#### Lab 02: Suspicious PowerShell Execution
**MITRE Technique:** T1059.001 - PowerShell  
**Log Source:** Windows Security Event 4688  
**Status:** Operational Sentinel rule  

**Detection Indicators:**
- `Invoke-WebRequest`, `DownloadString`, `DownloadFile`
- `New-Object Net.WebClient`
- `Start-BitsTransfer`, `bitsadmin`
- Base64 encoding, `-EncodedCommand`
- In-memory execution patterns (`IEX`)

#### Lab 03: AWS-Sentinel Multi-Cloud Threat Detection
**MITRE Techniques:** T1098 - Account Manipulation, T1496 - Resource Hijacking, T1530 - Data from Cloud Storage, T1078 - Valid Accounts
**Log Source:** AWSCloudTrail (via S3/SQS), SigninLogs
**Status:** 4 Operational Sentinel rules

**Detection Capabilities:**
- IAM privilege escalation (3+ changes in 5-minute window)
- Cryptojacking GPU instance launches (single-event alerting)
- S3 bucket public access protection removal (filtered for dangerous state changes)
- Cross-cloud correlation joining AWS CloudTrail and Azure SigninLogs on source IP

### 🛠 Skills Demonstrated

**Detection & Analytics:**
- ✅ Cloud threat detection engineering (Sentinel + Defender for Endpoint)
- ✅ KQL analytics and query optimization
- ✅ MITRE ATT&CK framework application
- ✅ Multi-source correlation with ASIM
- ✅ UEBA behavioral analytics
- ✅ Custom detection rule development (MDE + Sentinel)

**Multi-Cloud Detection:**
- ✅ AWS CloudTrail integration via S3/SQS pipeline
- ✅ Cross-cloud threat correlation (AWS + Azure)
- ✅ CloudTrail JSON parsing with parse_json() and nested field extraction
- ✅ Cross-table joins using let subqueries and join kind=inner
- ✅ SOAR Slack notification with alert-level data extraction
- ✅ Cloud Security Posture Management (Defender for Cloud CSPM)

**Security Automation:**
- ✅ SOAR workflow design and implementation (Logic Apps)
- ✅ Automated incident containment
- ✅ Content Hub solution deployment
- ✅ Managed identity configuration

**Threat Hunting & Investigation:**
- ✅ Hypothesis-driven threat hunting methodology
- ✅ Workbook development for operational efficiency
- ✅ Hunt-to-rule promotion workflows
- ✅ Incident investigation and triage
- ✅ Attack simulation and validation
- ✅ Sysmon + AMA log analysis

### 🔮 Planned Enhancements

- [x] Additional MITRE-aligned detections (Key Vault, VM Metadata)
- [x] Behavioral analytics
- [x] Automated threat hunting queries
- [ ] Sentinel-as-Code export (YAML rules)
- [x] Integration with SOAR playbooks
- [x] Custom workbooks for detection coverage

---

## 📁 Project B — Azure Landing Zone Lite

**📂 Folder:** [`/projects/project-b-landing-zone-lite`](projects/project-b-landing-zone-lite/)  
**📚 Documentation:** [`/docs/architecture/lzl-architecture.md`](docs/architecture/lzl-architecture.md)

### Overview

A secure, minimal Azure Landing Zone deployable in a student subscription using **Infrastructure-as-Code**.

This landing zone implements Azure security best practices while remaining cost-effective and suitable for learning environments. It establishes the foundation for running production-like workloads with proper security controls.

### 🏗 Core Components

| Component | Purpose | Security Feature |
|-----------|---------|------------------|
| **Virtual Network** | Network segmentation | Isolated subnets for app/mgmt/logging |
| **Subnets** | Workload isolation | 3 subnets with dedicated NSGs |
| **Azure Bastion** | Secure admin access | Zero public IPs on VMs |
| **NAT Gateway** | Controlled egress | Predictable outbound routing |
| **Network Security Groups** | Traffic filtering | Least-privilege rules |
| **Key Vault** | Secrets management | Centralized credential storage |
| **Log Analytics Workspace** | Centralized logging | Single pane of glass |
| **Data Collection Rules** | Telemetry config | AMA-based log collection |
| **Microsoft Sentinel** | SIEM/SOAR | Threat detection and response |
| **Flow Logs** | Network visibility | Traffic analytics enabled |

### 📐 Network Architecture

**VNet:** `vnet-sec-lz-core` (10.10.0.0/16)

| Subnet | CIDR | Purpose | NSG |
|--------|------|---------|-----|
| `snet-sec-lz-mgmt` | 10.10.1.0/24 | Management hosts | nsg-sec-lz-mgmt |
| `snet-sec-lz-app` | 10.10.2.0/24 | Application workloads | nsg-sec-lz-app |
| `snet-sec-lz-logging` | 10.10.3.0/24 | Security tooling | nsg-sec-lz-logging |

### 📚 Documentation

| Document | Description | Status |
|----------|-------------|--------|
| **[Landing Zone Overview](projects/project-b-landing-zone-lite/landing-zone-lite.md)** | Architecture principles and components | ✅ Complete |
| **[Networking Deep Dive](projects/project-b-landing-zone-lite/networking.md)** | Detailed network configuration | ✅ Complete |
| **[Troubleshooting Guide](projects/project-b-landing-zone-lite/troubleshooting.md)** | Common issues and resolutions | ✅ Complete |
| **[Hybrid AD Setup](projects/project-b-landing-zone-lite/hybrid-ad-setup.md)** | On-premises DC with Entra Connect sync | ✅ Complete |
| **[Architecture Diagram](docs/architecture/lzl-architecture.md)** | Visual architecture with Mermaid | ✅ Complete |

### 🔧 IaC Implementations

| Technology | Location | Status |
|------------|----------|--------|
| **Bicep Modules** | [`/infra/bicep/`](infra/bicep/) | ✅ Core Networking Module Complete |
| **Terraform** | [`/infra/terraform/`](infra/terraform/) | 🟦 Planned |

### 🛡 Security Features

**Zero Trust Principles:**
- ✅ No public IPs on management VMs
- ✅ Azure Bastion for all administrative access
- ✅ Network segmentation by workload type
- ✅ NSGs with default-deny posture
- ✅ Centralized key management

**Visibility & Monitoring:**
- ✅ Flow logs with Traffic Analytics
- ✅ Activity Log integration
- ✅ Diagnostic settings on all resources
- ✅ AMA-based log collection
- ✅ Microsoft Sentinel enabled

**Compliance Ready:**
- ✅ Audit-ready logging
- ✅ Encryption at rest
- ✅ Network traffic inspection capability
- ✅ Identity-based access controls

### 🛠 Skills Demonstrated

- ✅ Azure network design and implementation
- ✅ Zero Trust architecture patterns
- ✅ Infrastructure-as-Code development (planned)
- ✅ Secure VM deployment strategies
- ✅ Azure Bastion configuration
- ✅ NAT Gateway implementation
- ✅ Log Analytics integration
- ✅ Data Collection Rules (DCRs)
- ✅ Cloud architecture documentation
- ✅ Defender for Cloud enablement

### 🔮 Planned Enhancements

- [ ] Terraform IaC deployment
- [ ] Private endpoints for PaaS services
- [ ] Application Gateway integration
- [ ] Azure Policy implementation
- [ ] Automated compliance reporting
- [ ] Multi-region expansion pattern

---

## 📁 Project C — DevSecOps Pipelines

**📂 Folder:** [`/projects/project-c-devsecops-pipelines/`](projects/project-c-devsecops-pipelines/)  
**📊 Status:** 🟦 Planned

### Overview

Security-integrated CI/CD pipelines using GitHub Actions + Azure OIDC for automated, secure infrastructure deployment and validation.

### 🎯 Pipeline Features

**Security Scanning:**
- IaC linting and validation (terraform validate, bicep build)
- IaC security scanning (Checkov / tfsec)
- Static application security testing (CodeQL)
- Secret scanning (GitGuardian, GitHub Secret Scanning)
- Container image scanning (Trivy)
- Dependency vulnerability scanning (Dependabot)

**Deployment Automation:**
- GitHub OIDC → Azure (no stored credentials)
- Automated Bicep/Terraform deployments
- Multi-environment promotion (Dev → Staging → Prod)
- Rollback capabilities
- Drift detection and remediation

**Governance & Compliance:**
- Policy-as-Code enforcement (Azure Policy)
- Compliance scanning and reporting
- Automated documentation generation
- Change tracking and audit logs

### 📋 Planned Pipelines

| Pipeline | Purpose | Security Gates | Status |
|----------|---------|----------------|--------|
| **IaC Validation** | Lint and validate infrastructure code | tfsec, Checkov, Trivy | 🟦 Planned |
| **Security Scan** | SAST, secret scanning, dependency checks | CodeQL, GitGuardian | 🟦 Planned |
| **Infrastructure Deploy** | Deploy Landing Zone Lite | Policy validation, compliance check | 🟦 Planned |
| **Sentinel Deploy** | Deploy analytics rules and workbooks | Rule validation, KQL syntax check | 🟦 Planned |
| **Drift Detection** | Detect and report configuration drift | Policy compliance, resource inventory | 🟦 Planned |

### 🔧 Technology Stack

**CI/CD Platform:**
- GitHub Actions (primary)
- Azure DevOps (alternative consideration)

**Security Tools:**
- Checkov (IaC scanning)
- tfsec (Terraform security)
- CodeQL (SAST)
- Trivy (container/IaC scanning)
- GitGuardian (secret detection)

**IaC Tools:**
- Bicep (primary for Azure)
- Terraform (alternative/comparison)

**Authentication:**
- GitHub OIDC → Azure
- Workload Identity Federation
- No stored secrets or service principals

### 📊 Pipeline Architecture (Planned)

```mermaid
flowchart TD
    A[Git Push/PR] --> B{Trigger Type}
    
    B -->|Pull Request| C[Pre-Merge Checks]
    B -->|Main Branch| D[Deploy Pipeline]
    
    C --> C1[Linting]
    C --> C2[Security Scan]
    C --> C3[Unit Tests]
    C --> C4{All Pass?}
    C4 -->|No| C5[Block Merge]
    C4 -->|Yes| C6[Approve Merge]
    
    D --> D1[Security Gates]
    D1 --> D2[OIDC Auth]
    D2 --> D3[Deploy to Dev]
    D3 --> D4[Integration Tests]
    D4 --> D5{Tests Pass?}
    D5 -->|No| D6[Rollback]
    D5 -->|Yes| D7[Deploy to Prod]
    D7 --> D8[Post-Deploy Validation]
    D8 --> D9[Update Documentation]
```

### 🛠 Skills to be Demonstrated

- [ ] CI/CD pipeline design and implementation
- [ ] Security gates and quality controls
- [ ] Infrastructure-as-Code automation
- [ ] GitHub Actions workflows
- [ ] OIDC authentication patterns
- [ ] Policy-as-Code enforcement
- [ ] Automated security scanning
- [ ] Deployment validation and testing
- [ ] GitOps principles

### 📝 Documentation (Planned)

| Document | Description | Status |
|----------|-------------|--------|
| **Pipeline Architecture** | End-to-end pipeline design | 🟦 Planned |
| **Security Gates Guide** | How security checks are enforced | 🟦 Planned |
| **OIDC Setup Guide** | GitHub to Azure authentication | 🟦 Planned |
| **Deployment Runbook** | Step-by-step deployment process | 🟦 Planned |

### 🔮 Future Enhancements

- [ ] Drift detection & compliance pipeline
- [ ] Azure Policy-as-Code
- [ ] Automated workbook deployment
- [ ] Logic App playbook automation
- [ ] Multi-region deployment
- [ ] Blue-green deployment strategy
- [ ] Automated rollback triggers

---

## 🎓 Learning Path

This portfolio follows a progressive learning journey:

```mermaid
flowchart LR
    A[Project A<br/>Detection Engineering] --> B[Project B<br/>Secure Infrastructure]
    B --> C[Project C<br/>DevSecOps Automation]
    
    A -.->|Provides telemetry| C
    B -.->|Provides foundation| C
    C -.->|Deploys & validates| B
    C -.->|Automates rules| A
```

**Skill Progression:**
1. **Project A** — Understand what to detect and how to respond
2. **Project B** — Build secure foundations that support detection
3. **Project C** — Automate deployment and validation of both

---

## 📈 Portfolio Metrics

### Current Status

| Metric | Count |
|--------|-------|
| Completed Projects | 2/3 |
| Active Detections | 11 Sentinel + 5 MDE + 5 Hunts |
| Automation Playbooks | 6 operational Logic Apps |
| Documentation Pages | 22 |
| Architecture Diagrams | 2 |
| Scripts | 2 |
| Lab Case Studies | 3 initial + 3 playbook case studies |
| Workbooks | 4 operational dashboards |


### Certification Alignment

| Certification | Coverage | Projects |
|--------------|----------|----------|
| **SC-200** (Security Operations) | 90% | Projects A, B |
| **AZ-500** (Security Engineer) | 70% | Projects B, C |
| **SC-100** (Cybersecurity Architect) | 60% | Projects B, C |

---

## 🔄 Project Roadmap

### Current Focus (Q4 2025)
- [x] Complete Project A detection lab
- [x] Document Project A case studies
- [x] Complete Project B infrastructure
- [x] Document Project B architecture

### Next Steps (Q1 2026)
- [x] Develop Project C pipeline architecture
- [x] Implement IaC modules (Bicep)
- [ ] Create CI/CD workflows
- [x] Add additional Project A detections
- [ ] Implement Policy-as-Code

### Future Vision (Q2 2026+)
- [ ] Multi-region architecture
- [x] Advanced SOAR playbooks
- [ ] ML-based anomaly detection
- [ ] Compliance automation
- [ ] Public speaking/blog series

---

## 📚 Related Documentation

### Architecture
- [Cloud Detection Lab Architecture](docs/architecture/ctd-lab-architecture.md) — Technical design for Project A
- [Landing Zone Lite Architecture](docs/architecture/lzl-architecture.md) — Technical design for Project B

### Implementation Guides
- [Lab 01: RDP Brute Force](projects/project-a-cloud-detection-lab/labs/lab-01-bruteforce-detection.md)
- [Lab 02: Process Creation](projects/project-a-cloud-detection-lab/labs/lab-02-process-creation.md)
- [Lab 03: AWS Sentinel Integration](projects/project-a-cloud-detection-lab/labs/lab-03-aws-sentinel-integration.md)
- [Detection Pack](projects/project-a-cloud-detection-lab/detections.md)
- [Landing Zone Overview](projects/project-b-landing-zone-lite/landing-zone-lite.md)
- [Networking Guide](projects/project-b-landing-zone-lite/networking.md)
- [Troubleshooting](projects/project-b-landing-zone-lite/troubleshooting.md)

### Scripts & Automation
- [AMA Installation Script](scripts/install-ama.ps1)
- [Sysmon Installation Script](scripts/install-sysmon.ps1)

---

## 💡 Key Takeaways

This portfolio demonstrates:

1. **End-to-End Security Engineering** — From detection to infrastructure to automation
2. **Cloud-Native Expertise** — Azure-specific tools and best practices
3. **Practical Application** — Real labs, real alerts, real investigations
4. **Security-First Mindset** — Zero Trust, least privilege, defense in depth
5. **Continuous Learning** — Progressive skill development across projects

---

## 📫 Contact

If you'd like to discuss cloud security engineering, DevSecOps, or detection engineering:

**LinkedIn:** [linkedin.com/in/claytondemps](https://linkedin.com/in/claytondemps)

**GitHub:** This repository

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Last Updated: January 2026*  
*Portfolio Version: 1.0*
