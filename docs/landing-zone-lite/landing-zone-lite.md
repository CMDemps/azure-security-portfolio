# Landing Zone Lite — Project B: Azure Secure Foundation Lab  
This project establishes a lightweight but secure Azure landing zone designed for hands-on learning, SOC workflows, and future DevSecOps expansion. It implements Azure-native security patterns including subnet isolation, Bastion-only access, NAT-controlled outbound traffic, and centralized logging via AMA + DCRs.

The goal is to create a foundational environment that prepares for more advanced workloads and detection engineering in Project C.

---

## Goals
- Build a segmented virtual network with isolated management, application, and logging subnets  
- Deploy Windows and Linux management hosts with no public exposure  
- Use Bastion for all administrative access (RDP/SSH over TLS)  
- Implement NAT Gateway–controlled outbound traffic  
- Centralize telemetry into Log Analytics (`law-sec-lz-core`)  
- Enable Microsoft Sentinel for threat detection and investigation  
- Deploy flow logs, Activity Logs, and diagnostics for full visibility  
- Prepare the structure needed for future projects (application tier, private endpoints, Defender integration)

---

## Core Components

### Resource Group  
`rg-sec-lz-lite`  
Scoped resource container for all Landing Zone Lite assets.

---

### Virtual Network: `vnet-sec-lz-core`  
Primary network for the environment.  
CIDR: `10.10.0.0/16`

Subnets:
- **Management Subnet** — `snet-sec-lz-mgmt`  <!-- (`10.10.1.0/24`) -->  
  Used for Windows and Linux admin hosts  
- **Application Subnet** — `snet-sec-lz-app` <!-- (`10.10.2.0/24`) -->  
  Reserved for Project C workloads  
- **Logging Subnet** — `snet-sec-lz-logging` <!-- (`10.10.3.0/24`) -->  
  Optional logging appliances or secure endpoints

Each subnet is protected by its own NSG to maintain separation of duties and enforce a predictable network boundary.

---

### Bastion  
`bas-sec-lz-core`  
Provides secure remote access (RDP/SSH over TLS) without exposing VMs to the public internet.

---

### NAT Gateway  
`nat-sec-lz-core`  
Provides secure, consistent outbound internet access for the management subnet.  
Outbound public IP is redacted.

Eliminates “default outbound access” warnings and aligns with Azure’s guidance for secure egress.

---

### Management VMs
- **Windows Host**: `vm-sec-mgmt-win01`  
  Used for administrative tasks, log validation, detection testing  
- **Linux Host**: `vm-sec-mgmt-linux01`  
  Supports syslog, security tooling, and Linux-based administration

Both VMs:
- Reside in the management subnet  
- Have **no public IPs**  
- Are accessed exclusively through Bastion  
- Send SecurityEvents, Syslog, and Heartbeat to LAW  
- Use AMA via Data Collection Rules

(Private IPs redacted)

---

### Log Analytics Workspace  
`law-sec-lz-core`  
Central telemetry hub for:
- Windows SecurityEvents  
- Linux Syslog  
- Heartbeat  
- Virtual Network Flow Logs  
- Activity Logs  
- Storage Diagnostics  
- Sentinel Analytics

---

### Data Collection Rules  
- **Windows DCR:** `dcr-sec-lz-windows-events`  
  Collects SecurityEvents, System, and Application logs  
- **Linux DCR:** `dcr-sec-lz-linux`  
  Collects syslog (auth, daemon, syslog, user, etc.)

These DCRs are attached directly to the VM resources for AMA ingestion.

---

### Monitoring & Security
- **Microsoft Sentinel enabled** on `law-sec-lz-core`  
- **Traffic Analytics** enabled for flow logs  
- **Activity Logs** exported to LAW  
- **Diagnostic settings** applied to key resources

This provides the visibility foundation used in Project C for correlation, hunting, and detection engineering.

---

## Logical Architecture Diagram  
See:  
`docs/landing-zone-lite/images/lz-lite-network.png`

---

## Data Flow Overview

1. **User → Bastion**  
   RDP/SSH over TLS through Bastion’s secure entry point  

2. **Bastion → Management VMs**  
   No public IPs required  
   Private, isolated access  

3. **Management VMs → AMA/DCR**  
   Event logs, Syslog, and Heartbeat sent to LAW  

4. **Virtual Network → Flow Logs**  
   Flow metadata → Storage → Traffic Analytics → LAW  

5. **Log Analytics → Sentinel**  
   Enables analytics rules, incidents, hunting queries, and workbooks  

---

## Planned Enhancements (Project C and onward)
- Add app-tier workloads in the application subnet  
- Introduce private endpoints + secured storage  
- Expand logs with auditd (Linux) + Windows Defender logs  
- Implement Defender for Cloud recommendations  
- Add automation with Logic Apps and SOAR playbooks  
- Develop custom Sentinel detections built on Landing Zone telemetry  

---

## Summary
Landing Zone Lite provides the core security, networking, and monitoring components needed for real Azure-focused security engineering work. It sets the stage for Project C, which builds on this foundation to introduce application-tier workloads, advanced logging, and deeper detection engineering.

This project demonstrates both practical Azure skills and an understanding of cloud security design patterns.
