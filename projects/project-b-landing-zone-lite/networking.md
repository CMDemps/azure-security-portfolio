# Networking — Landing Zone Lite

The networking layer provides segmentation, boundary enforcement, routing governance, and secure access controls for the Landing Zone Lite environment.

---

## Virtual Network  
`vnet-sec-lz-core`  
- Address space: `10.10.0.0/16`  
- Core hub for all workloads  

---

## Subnets (Full Detail)

| Subnet | CIDR | Purpose |
|--------|------|---------|
| `snet-sec-lz-mgmt` | 10.10.1.0/24 | Management plane (Windows & Linux VMs, Bastion connectivity) |
| `snet-sec-lz-app` | 10.10.2.0/24 | Application workloads for Project C |
| `snet-sec-lz-logging` | 10.10.3.0/24 | Optional logging or monitoring services |

Each subnet is associated with a dedicated NSG.

---

## Network Security Groups

### `nsg-sec-lz-mgmt`
- Allows Bastion inbound  
- Blocks public inbound  
- Allows outbound internet only through NAT  
- Admin IPs used during deployment are redacted  

### `nsg-sec-lz-app`
Reserved for future application-tier NSG rules.

### `nsg-sec-lz-logging`
Reserved for future logging appliances.

---

## Bastion Access  
Azure Bastion provides hardened access for:
- RDP into Windows hosts  
- SSH into Linux hosts  

Bastion communicates privately with the management subnet.

---

## NAT Gateway  
`nat-sec-lz-core`  
Attached to the management subnet to provide secure outbound connectivity.

Key points:
- Public IP is redacted  
- Routing preference uses Microsoft’s backbone (recommended)  
- Ensures consistent egress identity  
- Required for AMA, package updates, and general VM operations  

---

## DNS Behavior (Linux)  
- Ubuntu defaults to systemd-resolved (`127.0.0.53`).  
- We replaced the resolver with Azure DNS (`168.63.129.16`) and locked the file: ```sudo chattr +i /etc/resolv.conf```  
- Fix documented due to common networking issues with AMA and Linux package installs.

---

## Flow Logs  
Virtual Network Flow Logs are enabled:
- Version 2 flow logs  
- Data stored in a storage account (name redacted)  
- Traffic Analytics enabled, sending enriched network data to LAW  

---

## Summary
This networking model enforces a clean separation of concerns, secure administrative access patterns, and the telemetry needed for detection engineering and automation in Project C.
