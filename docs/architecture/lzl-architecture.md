# Landing Zone Lite — Project B Architecture  

This document describes the logical and technical architecture of the Landing Zone Lite environment. It captures subnet design, security controls, data flows, and the foundational components that support management, monitoring, and future workloads.

---

## Architecture Objectives

- Enforce **network segmentation** through isolated subnets  
- Create a **secure management plane** for Windows and Linux administration  
- Remove all **public VM exposure** via Bastion-only access  
- Implement **centralized telemetry** using Log Analytics + AMA + DCRs  
- Establish **controlled outbound egress** using NAT Gateway  
- Support **Sentinel analytics and detection engineering**  
- Keep the design lightweight, reproducible, and aligned with Azure best practices  

---

## Core Network Design

### Virtual Network: `vnet-sec-lz-core`

This virtual network provides the foundation for all connectivity in the environment.

- **Address Space:** `10.10.0.0/16`  
- **Purpose:** Provide subnet isolation, NSG boundaries, and future expansion capacity  

---

### Subnets

| Subnet Name           | CIDR           | Purpose |
|----------------------|----------------|---------|
| `snet-sec-lz-mgmt`   | 10.10.1.0/24   | Management VMs, Bastion connectivity, administrative workloads |
| `snet-sec-lz-app`    | 10.10.2.0/24   | Application workloads (used in Project C) |
| `snet-sec-lz-logging`| 10.10.3.0/24   | Optional logging appliances or future security components |

**Key Principles**

- Subnets are designed to contain specific resource types  
- NSGs enforce east-west and north-south segmentation  
- Subnet assignment provides predictable IP boundaries without exposing specific host IPs  

---

## Network Security Groups (NSGs)

Each subnet has a dedicated NSG for clarity and boundary enforcement:

- `nsg-sec-lz-mgmt`
- `nsg-sec-lz-app`
- `nsg-sec-lz-logging`

**Management NSG Highlights**

- Inbound: Allows Bastion traffic only  
- Outbound: Internet allowed via NAT Gateway (default outbound disabled)  
- Admin IPs are redacted for security  

This replicates enterprise patterns where the management plane is the most restricted component.

---

## Secure Access Layer — Bastion

### Bastion Host: `bas-sec-lz-core`

Provides encrypted RDP and SSH access without assigning public IPs to VMs.

**Why Bastion Matters**
- Eliminates VM public exposure  
- Reduces attack surface dramatically  
- Ensures all administrative access traverses Azure’s backbone  
- Works consistently across Windows and Linux hosts  

Bastion sits in its own mandatory `AzureBastionSubnet` and interacts directly with the management subnet.

---

## Outbound Access Layer — NAT Gateway

### NAT Gateway: `nat-sec-lz-core`

Controls and standardizes outbound traffic for resources in the management subnet.

- Public IP is redacted for security  
- Routing preference: **MicrosoftNetwork** (Azure backbone optimized)  
- Eliminates “default outbound access” on VMs  
- Ensures consistent egress identity for logging, updates, package repos, etc.

This is the correct pattern for any environment transitioning toward Zero Trust.

---

## Management Plane — Windows & Linux Hosts

### Windows VM: `vm-sec-mgmt-win01`

- Administrative host for Windows-based tooling  
- AMA installed  
- Collects SecurityEvents, System, Application logs  
- No public exposure  

### Linux VM: `vm-sec-mgmt-linux01`

- Administrative host for Linux-based tooling  
- AMA installed via DCR  
- Syslog collection (auth, authpriv, daemon, syslog, user)  
- DNS issue resolved by configuring Azure resolver  
- No public exposure  

These VMs serve as your operational touchpoints for the landing zone and your telemetry sources for detection engineering.

---

## Monitoring & Telemetry

### Log Analytics Workspace: `law-sec-lz-core`

The central collection point for:

- Windows event logs  
- Linux syslog  
- Heartbeat  
- Activity Logs  
- Storage diagnostic logs  
- Virtual network flow logs  
- Traffic analytics  

### Microsoft Sentinel  

Activated on `law-sec-lz-core` and provides:

- Analytics rules  
- Incident generation  
- Entity mapping  
- Hunting queries  
- Workbooks  

This transforms your landing zone into a detection-ready platform.

---

## Logging Pipelines — AMA + DCR Architecture

### Windows DCR  

`dcr-sec-lz-windows-events`  
- Collects SecurityEvents, System, Application

### Linux DCR  

`dcr-sec-lz-linux`  
- Collects syslog using minimal level “info”  
- Covers auth, authpriv, daemon, syslog, user facilities  

**Why AMA/DCR Instead of MMA?**  
- AMA is the long-term replacement  
- Performs better at scale  
- Supports granular, rule-based log targeting  
- Compatible with unified agent initiatives  

---

## Flow Logs & Traffic Analytics  

Flow logs capture NSG-level traffic metadata.

Configured for:
- Virtual Network `vnet-sec-lz-core`  
- Storage-based log delivery  
- Traffic Analytics → LAW  

This provides visibility into allowed/denied flows across the landing zone.

---

## Logical Architecture Diagram  

See:
`docs/landing-zone-lite/images/lz-lite-network.png`

The diagram visualizes:
- Subnet layout  
- Bastion and NAT positioning  
- VM placement  
- Logging and telemetry flow  
- Connectivity boundaries  

---

## High-Level Data Flow

1. **User → Bastion**  
   Secure RDP/SSH into the environment  

2. **Bastion → Management VMs**  
   Encrypted session into Windows/Linux hosts  

3. **VM → AMA/DCR → LAW**  
   Telemetry is normalized and stored  

4. **Flow Logs → Storage → Traffic Analytics → LAW**  
   Networking visibility is added to the dataset  

5. **LAW → Sentinel**  
   Detection, investigation, and threat hunting  

---

## Architectural Rationale

### Why this design works:
- Enforces segmentation from day one  
- Establishes a clean management plane  
- Removes all unnecessary exposure  
- Builds logging pipelines that scale into future workloads  
- Keeps the architecture small enough for Azure for Students limits  
- Sets the stage for Project C’s application-tier expansion  

---

## Summary

The Landing Zone Lite architecture follows secure-by-default Azure patterns while remaining approachable for hands-on learning. It demonstrates your ability to design, deploy, and operate a real cloud security foundation — a valuable skill set for SOC, SecOps, and Security Engineer roles.
