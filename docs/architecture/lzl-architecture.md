# 📁 Landing Zone Lite — Project B Architecture  

This document describes the logical and technical architecture of the Landing Zone Lite environment. It captures subnet design, security controls, data flows, and the foundational components that support management, monitoring, and future workloads.

---

## High-Level Components

### Virtual Network  

`vnet-sec-lz-core` hosts three functional subnets:
- **Management Subnet** — Used for admin VMs and Bastion connectivity  
- **Application Subnet** — Reserved for future workloads  
- **Logging Subnet** — Reserved for optional monitoring or security appliances  

Only the *names* of the subnets are included here; deep technical details are in `networking.md`.

---

### Bastion Access Layer  

Bastion provides a secure entry point into the environment, replacing VM-level public access with encrypted, browser-based RDP/SSH.

This aligns with Azure’s guidance for administrative access in production and lab environments.

---

### Outbound Access Pattern  

A NAT Gateway provides controlled outbound routing from the management subnet.  

Benefits include:  
- Predictable outbound IP identity  
- Removal of "default outbound access"  
- Secure egress for updates, package installs, and AMA traffic  

Detailed routing logic is documented in `networking.md`.

---

### Management Plane  

Two core VMs implement the administrative and operational surface:
- Windows management host  
- Linux management host  

Both feed security logs into Log Analytics and are used for testing detections, tooling, and automation.

---

### Monitoring & Analytics  

A dedicated Log Analytics Workspace (`law-sec-lz-core`) acts as the single aggregation point for telemetry:
- Windows events  
- Linux syslog  
- Flow logs  
- Resource diagnostics  
- Control-plane Activity Logs  

Microsoft Sentinel is enabled on LAW to support:
- Analytics rules  
- Incident management  
- Threat hunting  
- Operational dashboards  

---

## Architectural Diagram

See: `projects/project-b-landing-zone-lite/images/lz-lite-network.png`

---

## Summary

The architecture provides a minimal but realistic representation of a secure Azure landing zone. It emphasizes isolation, visibility, and maintainability, and establishes the patterns required for expanding into DevSecOps automation in Project C.
