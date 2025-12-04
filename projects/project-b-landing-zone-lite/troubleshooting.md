# Troubleshooting — Landing Zone Lite

Common issues surfaced during Landing Zone deployment and operation.

---

## Linux DNS Failure

Symptoms:
- sudo: unable to resolve host  
- Package installs failing  

Fix:
- `sudo systemctl disable systemd-resolved`
- `sudo systemctl stop systemd-resolved`
- `sudo rm /etc/resolv.conf`
- `echo "nameserver 168.63.129.16" | sudo tee /etc/resolv.conf`
- `sudo chattr +i /etc/resolv.conf`

---

## AMA Not Sending Logs

Checklist:
- VM attached to correct DCR  
- AMA extension present  
- Outbound internet reachable via NAT  
- LAW ingestion not throttled  

---

## Bastion Connectivity Issues

Verify:
- NSG on mgmt subnet allows Bastion traffic  
- VM has no public IP  
- Bastion host deployed successfully  

---

## No Flow Logs in LAW

Ensure:
- Flow logs enabled at **VNet**, not NSG  
- Storage account available  
- Traffic analytics enabled
