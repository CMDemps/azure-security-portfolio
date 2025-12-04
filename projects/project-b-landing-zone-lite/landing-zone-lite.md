# 📁 Landing Zone Lite — Project B: Azure Secure Foundation Lab  
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

- **Virtual Network:** Core network for management, application, and logging workloads  
- **Management Plane:** Windows and Linux admin hosts with no public exposure  
- **Bastion:** Secure entry point for RDP/SSH over TLS  
- **NAT Gateway:** Governs outbound traffic  
- **Log Analytics + Sentinel:** Central monitoring and SIEM capability  
- **Data Collection Rules:** Configure AMA ingestion for Windows and Linux  

These components together form the minimum secure architecture for expanding into more advanced cloud and SOC use cases.

---

## How This Project Integrates Into The Portfolio

- **Project A** demonstrates cloud detection engineering  
- **Project B** builds the secure landing zone that future workloads run on  
- **Project C** introduces DevSecOps automation, deploying and validating this infrastructure  

---

## Monitoring & Security

- **Microsoft Sentinel enabled** on `law-sec-lz-core`  
- **Traffic Analytics** enabled for flow logs  
- **Activity Logs** exported to LAW  
- **Diagnostic settings** applied to key resources

This provides the visibility foundation used in Project C for correlation, hunting, and detection engineering.

---

## Logical Architecture Diagram  

![Landing Zone PNG](images/lz-lite-network.png)

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
