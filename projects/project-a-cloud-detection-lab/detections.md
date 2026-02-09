# 🔍 Cloud Detection Pack — Azure Security Portfolio

*KQL Detections • MITRE ATT&CK Mapping • Log Analytics / Sentinel*

This detection pack contains my KQL-based detections created for Azure Log Analytics and Microsoft Sentinel.  
All detections are mapped to MITRE ATT&CK techniques and aligned with cloud threat detection best practices.

Each detection includes:

- Purpose  
- Description & threat behavior  
- Log sources  
- KQL query  
- MITRE mapping  
- False positives / tuning guidance  
- Deployment notes (optional Sentinel rule configs)

---

## 📚 Table of Contents

- [Credential Access (TA0006)](credential-access-ta0006)
- [Execution (TA0002)](execution-ta0002)
- [AWS Threat Detection](aws-threat-detection)
- [Behavioral Analytics (TA0009)](behavior-analytics-ta0009)
- [Discovery (TA0007)](discovery-ta0007)
- [Lateral Movement (TA0008)](lateral-movement-ta0008)
- [Defense Evasion (TA0005)](defense-evasion-ta0005)
- [Persistence (TA0003)](persistence-ta0003)
- [Exfiltration (TA0010)](exfiltration-ta0010)  --> Coming Soon
- [Impact (TA0040)](impact-ta0040)              --> Coming Soon

---

## Credential Access (TA0006)

### **T1110 — Brute Force (RDP / Network Logon)**

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-01-bruteforce-detection.md`

#### Purpose

Detect repeated failed RDP or network logon attempts from a single IP in a
short time window.

#### Log Sources

- `Event` (AMA — Windows Security Events)  
- Event ID: **4625**  

#### KQL

```kusto
Event
| where EventLog == "Security"
| where EventID == 4625
| extend ParamList = extract_all(@'<Param>(.*?)</Param>', tostring(ParameterXml))
| extend 
    TargetUser = tostring(ParamList[5]),
    LogonType  = tostring(ParamList[10]),
    Workstation = tostring(ParamList[13]),
    SourceIp   = tostring(ParamList[18])
| where LogonType == "3" or LogonType == "10"
| where SourceIp != "0.0.0.0" and SourceIp != ""
| summarize FailedCount = count() by 
    SourceIp, 
    TargetUser, 
    Computer, 
    bin(TimeGenerated, 5m)
| where FailedCount >= 5
```

#### MITRE Mapping

- **Tactic:** Credential Access
- **Technique:** T1110 — Brute Force

#### Notes / False Positives

- Users forgetting passwords
- Misconfigured scripts / services  
- Admin testing credentials

---

### **High-Risk Role Assignment Detection**

**Status:** Implemented as Sentinel Analytics Rule  
**Data Source:** AuditLogs

#### Purpose

Detect when privileged roles (Global Administrator, Security Administrator, etc.) are assigned to user accounts, which could indicate privilege escalation or insider threat activity.

#### Log Sources

- `AuditLogs` (Entra ID Audit Logs via data connector)
- Operation: "Add member to role"

#### KQL
```kql
AuditLogs
| where TimeGenerated > ago(1h)
| where OperationName == "Add member to role"
| where Result == "success"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend RoleNameRaw = tostring(TargetResources[0].modifiedProperties[1].newValue)
| extend RoleName = trim('"', RoleNameRaw)
| extend AssignedBy = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| where RoleName in ("Global Administrator", "Security Administrator", "User Administrator", 
    "Privileged Role Administrator", "Application Administrator")
| project TimeGenerated, TargetUser, RoleName, AssignedBy, SourceIP, Result
| extend ThreatLevel = "High"
```

#### MITRE Mapping

- **Tactic:** Persistence, Privilege Escalation
- **Technique:** T1098.003 - Account Manipulation: Additional Cloud Roles

#### Alert Enrichment

**Custom Details:**
- ThreatLevel: High
- RoleName: Assigned privileged role
- AssignedBy: Account that performed the assignment
- SourceIP: IP address of assignment action

**Entity Mapping:**
- Account: TargetUser (who received the role)
- Account: AssignedBy (who assigned the role)
- IP: SourceIP

#### Notes / False Positives

- Legitimate IT admin role assignments
- Onboarding new administrators
- Scheduled access reviews

**Tuning:** Exclude known admin accounts, add time-of-day filtering for after-hours assignments

---

### **Bulk User Creation Detection**

**Status:** Implemented as Sentinel Analytics Rule  
**Data Source:** AuditLogs

#### Purpose

Detect when 3 or more user accounts are created within a short time window, potentially indicating unauthorized account provisioning or preparation for attack.

#### Log Sources

- `AuditLogs` (Entra ID Audit Logs)
- Operation: "Add user"

#### KQL
```kql
AuditLogs
| where OperationName == "Add user"
| where Result == "success"
| extend CreatedBy = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| extend CreatedUser = tostring(TargetResources[0].userPrincipalName)
| summarize 
    UserCount = count(), 
    CreatedUsers = make_list(CreatedUser),
    UniqueIPs = dcount(SourceIP),
    SourceIPs = make_set(SourceIP),
    StartTime = min(TimeGenerated),
    EndTime = max(TimeGenerated)
    by CreatedBy, bin(TimeGenerated, 10m)
| where UserCount >= 3 or UniqueIPs >= 2
| extend Severity = iff(UniqueIPs >= 2, "High", "Medium")
| project TimeGenerated, CreatedBy, UserCount, UniqueIPs, CreatedUsers, SourceIPs, Severity, StartTime, EndTime
```

#### MITRE Mapping

- **Tactic:** Persistence, Initial Access
- **Technique:** T1136.003 - Create Account: Cloud Account

#### Alert Enrichment

**Custom Details:**
- UserCount: Number of accounts created
- CreatedUsers: List of new accounts
- UniqueIPs: Count of source IPs (multiple IPs = higher threat)
- Severity: Dynamic severity based on indicators

**Entity Mapping:**
- Account: CreatedBy (who created the accounts)
- IP: SourceIPs

#### Notes / False Positives

- Legitimate bulk onboarding of new employees
- Automated user provisioning systems
- HR/IT scheduled processes

**Tuning:** Exclude service accounts, increase threshold during known onboarding periods

---

### **User Modification Detection with Alert Enrichment**

**Status:** Implemented as Sentinel Analytics Rule  
**Data Source:** AuditLogs

#### Purpose

Detect suspicious modifications to user accounts (role changes, password resets, MFA changes) with detailed alert enrichment for investigation.

#### Log Sources

- `AuditLogs` (Entra ID Audit Logs)
- Operations: Update user, Reset password, Add member to role, Remove member from role

#### KQL
```kql
AuditLogs
| where TimeGenerated > ago(1h)
| where OperationName has_any ("Update user", "Reset password", "Add member to role", "Remove member from role")
| where Result == "success"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| summarize 
    ChangeCount = count(),
    Operations = make_set(OperationName),
    UniqueIPs = dcount(SourceIP),
    SourceIPs = make_set(SourceIP),
    StartTime = min(TimeGenerated),
    EndTime = max(TimeGenerated)
    by TargetUser, Actor, bin(TimeGenerated, 10m)
| where ChangeCount >= 2
| extend ThreatLevel = case(
    ChangeCount >= 5, "High",
    UniqueIPs >= 2, "High",
    "Medium"
)
| project TimeGenerated, TargetUser, Actor, ChangeCount, Operations, UniqueIPs, SourceIPs, ThreatLevel, StartTime, EndTime
```

#### MITRE Mapping

- **Tactic:** Persistence, Defense Evasion
- **Technique:** T1098 - Account Manipulation

#### Alert Enrichment

**Custom Details:**
- ThreatLevel: High/Medium based on activity volume
- ChangeCount: Number of modifications
- Operations: Types of changes made
- UniqueIPs: Source IP diversity (indicates potential compromise)

**Entity Mapping:**
- Account: TargetUser (account being modified)
- Account: Actor (who made the changes)
- IP: SourceIPs

#### Notes / False Positives

- IT help desk password resets
- Legitimate admin account management
- Automated account lifecycle processes

**Tuning:** Exclude service accounts, filter for after-hours activity only

---

## Execution (TA0002)

### Suspicious PowerShell Downloader / Stager (PS-LOLBAS / Payload Delivery)

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-02-process-creation.md`

#### Purpose

Detect malicious or suspicious use of PowerShell as a downloader or stager, including retrieval of remote payloads, execution of downloaded content, abuse of `Invoke-WebRequest`, WebClient methods, BITS, encoded commands, or in-memory execution techniques often used during initial access and hands-on-keyboard activity.

This detection is built on `Windows Security Event ID 4688` collected through AMA.

#### Log Sources

- ```Event``` (Security Log — EventID 4688: Process Creation)

#### KQL (Security 4688 - AMA)

```kql
Event
| where EventLog == "Security"
| where EventID == 4688   // Process creation
// Extract process + command line from Security 4688
| extend NewProcessName =
    extract(@"New Process Name:\s*([^\r\n]+)", 1, RenderedDescription),
         ProcessCommandLine =
    extract(@"Process Command Line:\s*([^\r\n]*)", 1, RenderedDescription)
// Normalize
| extend NewProcessNameLower = tolower(NewProcessName),
         CmdLower            = tolower(ProcessCommandLine)
// Focus on PowerShell
| where NewProcessNameLower has @"\powershell.exe"
// Behavioral indicators of download/staging
| where CmdLower has_any (
    "http://", "https://",
    "invoke-webrequest", "iwr",
    "downloadstring", "downloadfile",
    "new-object net.webclient",
    "start-bitstransfer", "bitsadmin",
    "frombase64string", "-encodedcommand",
    "iex "
)
// Final projection
| project
    TimeGenerated,
    Computer,
    NewProcessName,
    ProcessCommandLine
| order by TimeGenerated desc
```

#### MITRE Mapping

- **Technique:** T1059 — Command and Scripting Interpreter
- **Sub-technique:** PowerShell (T1059.001)
- **Related:**
  - T1105 — Ingress Tool Transfer
  - T1059.001 — Encoded or Obfuscated PowerShell
  - T1027 — Obfuscated Execution

#### Notes / False Positives

- Legitimate scripts using Invoke-WebRequest (updates, internal automation)
- DevOps pipelines or software installers pulling content from URLs
- Admin activities using BITS or WebClient APIs
- Base64/Encoded commands used for benign automation (rare)

---

## AWS Threat Detection

### **T1098 — AWS IAM Rapid Privilege Escalation**

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-03-aws-sentinel-integration.md`

#### Purpose

Detect 3 or more IAM privilege modification events from the same identity within a 5-minute window, indicating potential credential compromise followed by privilege escalation.

#### Log Sources

- `AWSCloudTrail` (CloudTrail via S3/SQS connector)
- EventSource: `iam.amazonaws.com`

#### KQL

```kql
// Purpose: Detect rapid IAM privilege changes indicating credential compromise
// MITRE ATT&CK: T1098 - Account Manipulation (Persistence)
let PrivilegeChangeEvents = dynamic([
    "AttachUserPolicy", "AttachRolePolicy", "AttachGroupPolicy",
    "PutUserPolicy", "PutRolePolicy", "PutGroupPolicy",
    "CreatePolicyVersion", "AddUserToGroup", "CreateUser",
    "DetachUserPolicy", "DetachRolePolicy", "DeleteUser"
]);
AWSCloudTrail
| where EventSource == "iam.amazonaws.com"
| where EventName in (PrivilegeChangeEvents)
| where isempty(ErrorCode)
| summarize 
    ChangeCount = count(),
    ActionsPerformed = make_set(EventName),
    FirstChange = min(TimeGenerated),
    LastChange = max(TimeGenerated)
    by UserIdentityArn, SourceIpAddress, bin(TimeGenerated, 5m)
| where ChangeCount >= 3
```

#### MITRE Mapping

- **Tactic:** Persistence
- **Technique:** T1098 — Account Manipulation

#### Notes / False Positives

- Legitimate admin onboarding new team members
- Automated provisioning (Terraform, CloudFormation)
- Scheduled access reviews

**Tuning:** Exclude known automation IAM roles, adjust threshold during onboarding periods

---

### **T1496 — Cryptojacking GPU Instance Launch**

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-03-aws-sentinel-integration.md`

#### Purpose

Detect launch of GPU, ML-accelerator, or high-compute EC2 instance types commonly abused for cryptocurrency mining. Single-event threshold because legitimate GPU launches have a near-zero base rate.

#### Log Sources

- `AWSCloudTrail` (CloudTrail via S3/SQS connector)
- EventSource: `ec2.amazonaws.com`

#### KQL

```kql
// Purpose: Detect GPU/ML instance launches commonly used for crypto mining
// MITRE ATT&CK: T1496 - Resource Hijacking (Impact)
let CryptoMiningInstanceTypes = dynamic([
    "p3.", "p4.", "p4d.", "p5.", 
    "g4dn.", "g4ad.", "g5.", "g5g.", "g6.",
    "dl1.", "inf1.", "inf2.", "trn1."
]);
AWSCloudTrail
| where EventSource == "ec2.amazonaws.com"
| where EventName == "RunInstances"
| where isempty(ErrorCode)
| extend InstanceType = tostring(parse_json(RequestParameters).instanceType)
| where InstanceType has_any (CryptoMiningInstanceTypes)
| project 
    TimeGenerated,
    UserIdentityArn,
    SourceIpAddress,
    InstanceType,
    AWSRegion,
    RequestParameters
```

#### MITRE Mapping

- **Tactic:** Impact
- **Technique:** T1496 — Resource Hijacking

#### Notes / False Positives

- Legitimate ML/AI workloads using GPU instances
- Approved data science teams

**Tuning:** Maintain allowlist of approved GPU users, add custom detail for team validation

---

### **T1530 — S3 Bucket Public Access Protections Removed**

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-03-aws-sentinel-integration.md`

#### Purpose

Detect when S3 bucket public access block protections are disabled or when bucket ACL/policy changes could expose data publicly. Filters to only alert when protections are removed (boolean values set to false), ignoring re-enablement events.

#### Log Sources

- `AWSCloudTrail` (CloudTrail via S3/SQS connector)
- EventSource: `s3.amazonaws.com`

#### KQL

```kql
// Purpose: Detect removal of S3 public access block protections
// MITRE ATT&CK: T1530 - Data from Cloud Storage (Collection)
let S3ExposureEvents = dynamic([
    "PutBucketAcl", "PutBucketPolicy", 
    "PutBucketPublicAccessBlock", "DeleteBucketPublicAccessBlock",
    "PutBucketCors"
]);
AWSCloudTrail
| where EventSource == "s3.amazonaws.com"
| where EventName in (S3ExposureEvents)
| where isempty(ErrorCode)
| extend BucketName = tostring(parse_json(RequestParameters).bucketName)
| extend PublicAccessConfig = parse_json(RequestParameters).PublicAccessBlockConfiguration
| extend BlockPublicAcls = tostring(PublicAccessConfig.BlockPublicAcls)
| extend BlockPublicPolicy = tostring(PublicAccessConfig.BlockPublicPolicy)
| extend RestrictPublicBuckets = tostring(PublicAccessConfig.RestrictPublicBuckets)
| extend IgnorePublicAcls = tostring(PublicAccessConfig.IgnorePublicAcls)
| where BlockPublicAcls == "false" 
    or BlockPublicPolicy == "false" 
    or RestrictPublicBuckets == "false" 
    or IgnorePublicAcls == "false"
    or EventName in ("PutBucketAcl", "PutBucketPolicy", "DeleteBucketPublicAccessBlock")
| project 
    TimeGenerated,
    EventName,
    UserIdentityArn,
    SourceIpAddress,
    BucketName,
    BlockPublicAcls,
    BlockPublicPolicy,
    RestrictPublicBuckets,
    IgnorePublicAcls,
    AWSRegion
```

#### MITRE Mapping

- **Tactic:** Collection
- **Technique:** T1530 — Data from Cloud Storage

#### Notes / False Positives

- Intentional public buckets for static website hosting
- CDN origin configurations
- Honeypot deployments

**Tuning:** Implement bucket allowlist, start with alert-only before enabling auto-remediation

**Key Discovery:** CloudTrail logs this as `PutBucketPublicAccessBlock`, not `PutPublicAccessBlock`. Always validate event names against live data.

---

### **T1078 — Multi-Cloud Suspicious AWS Activity with Azure Failed Logins**

**Status:** Implemented as Sentinel Analytics Rule  
**File:** `lab-03-aws-sentinel-integration.md`

#### Purpose

Correlate IP addresses across AWS CloudTrail and Azure SigninLogs to detect attackers operating in both cloud environments simultaneously. Joins suspicious AWS write operations with failed Azure sign-in attempts from the same source IP within a 1-hour window.

#### Log Sources

- `AWSCloudTrail` (CloudTrail via S3/SQS connector)
- `SigninLogs` (Entra ID sign-in logs)

#### KQL

```kql
// Purpose: Cross-cloud correlation of suspicious AWS activity with Azure failed logins
// MITRE ATT&CK: T1078 - Valid Accounts (Initial Access)
let timewindow = 1h;
let SuspiciousAWSEvents = dynamic([
    "AttachUserPolicy", "AttachRolePolicy", "CreateUser",
    "RunInstances", "PutBucketPublicAccessBlock", "DeleteBucketPublicAccessBlock",
    "PutBucketPolicy", "PutBucketAcl", "CreateAccessKey",
    "PutRolePolicy", "CreatePolicyVersion"
]);
let AWSSuspicious = 
    AWSCloudTrail
    | where TimeGenerated > ago(timewindow)
    | where EventName in (SuspiciousAWSEvents)
    | where isempty(ErrorCode)
    | summarize 
        AWSEventCount = count(),
        AWSActions = make_set(EventName, 10),
        AWSFirstSeen = min(TimeGenerated),
        AWSLastSeen = max(TimeGenerated)
        by SourceIpAddress;
let AzureFailedLogins =
    SigninLogs
    | where TimeGenerated > ago(timewindow)
    | where ResultType != "0"
    | summarize
        FailedLoginCount = count(),
        TargetedUsers = make_set(UserPrincipalName, 5),
        AzureApps = make_set(AppDisplayName, 5),
        AzureFirstSeen = min(TimeGenerated),
        AzureLastSeen = max(TimeGenerated)
        by IPAddress;
AWSSuspicious
| join kind=inner AzureFailedLogins on $left.SourceIpAddress == $right.IPAddress
| project
    SourceIpAddress,
    AWSEventCount,
    AWSActions,
    AWSFirstSeen,
    AWSLastSeen,
    FailedLoginCount,
    TargetedUsers,
    AzureApps,
    AzureFirstSeen,
    AzureLastSeen
```

#### MITRE Mapping

- **Tactic:** Initial Access
- **Technique:** T1078 — Valid Accounts

#### Alert Enrichment

**Custom Details:**
- AWSActions: List of suspicious AWS operations performed
- TargetedUsers: Azure accounts targeted with failed logins

**Entity Mapping:**
- IP: SourceIpAddress

#### Notes / False Positives

- Legitimate users working in both clouds from same corporate IP
- VPN exit nodes shared across teams

**Tuning:** Filter to only suspicious AWS write operations (not reads), narrow time window, exclude known corporate IP ranges

---

## Behavioral Analytics (TA0009)

### **ASIM - Multi-Source Brute Force Detection**

**Status:** Implemented as Sentinel Analytics Rule  
**Data Source:** BehaviorAnalytics, ASIM Authentication Parser

#### Purpose

Detect brute force authentication attempts across ALL authentication sources using ASIM normalization - works with Defender for Identity, Windows Security Events, and Entra ID simultaneously.

#### Log Sources

- `_Im_Authentication` (ASIM normalized authentication events)
- Sources: Entra ID, Windows Security Events, Defender for Identity

#### KQL
```kql
_Im_Authentication
| where TimeGenerated > ago(1h)
| where EventResult == "Failure"
| summarize 
    FailureCount = count(),
    SourceIPs = make_set(SrcIpAddr),
    FirstFailure = min(TimeGenerated),
    LastFailure = max(TimeGenerated)
    by TargetUsername, DvcHostname
| where FailureCount >= 5
| project 
    LastFailure,
    TargetUsername, 
    DvcHostname,
    FailureCount, 
    SourceIPs,
    FirstFailure
```

#### MITRE Mapping

- **Tactic:** Credential Access
- **Technique:** T1110 - Brute Force

#### Key Feature: ASIM Normalization

This detection works across multiple data sources simultaneously because ASIM normalizes field names:
- **TargetUsername** works for Windows `TargetUserName`, Entra `UserPrincipalName`, Defender `AccountName`
- **SrcIpAddr** works across all source IP fields
- **EventResult** normalized from Success/Failure/0x0/etc.

**Benefit:** One query detects brute force from any authentication source - add new sources, detection continues working without modification.

#### Notes / False Positives

- Users forgetting passwords
- Misconfigured applications
- Legacy systems with authentication issues

**Tuning:** Adjust threshold based on environment, exclude service accounts

---

### **High Risk User Activity - UEBA**

**Status:** Implemented as Sentinel Analytics Rule  
**Data Source:** BehaviorAnalytics

#### Purpose

Detect users with high Investigation Priority scores from UEBA machine learning analysis, indicating anomalous behavior patterns.

#### Log Sources

- `BehaviorAnalytics` (UEBA-generated behavioral analysis)

#### KQL
```kql
BehaviorAnalytics
| where TimeGenerated > ago(1h)
| where InvestigationPriority > 7
| where ActivityInsights has "True"
| project TimeGenerated, UserPrincipalName, InvestigationPriority, ActivityType, ActivityInsights
```

#### MITRE Mapping

- **Tactic:** Multiple (behavioral anomalies)
- **Technique:** N/A (ML-based detection, not specific technique)

#### Key Feature: Machine Learning Detection

**Investigation Priority Score (0-10):**
- 0-3: Normal behavior
- 4-6: Minor anomalies
- 7-8: Significant deviation - **triggers this rule**
- 9-10: Critical anomaly

**What UEBA Detects:**
- Unusual login locations
- Access to resources user normally doesn't touch
- Peer group behavioral deviation
- Time-of-day anomalies
- Privilege escalation patterns

**Complements rule-based detections** - catches insider threats and compromised accounts that evade signature-based rules.

#### Notes / False Positives

- New employees establishing baseline behavior
- Role changes (promotion, department transfer)
- Legitimate business travel
- Remote work pattern changes

**Tuning:** UEBA requires 24-72 hours to establish baselines, expect higher false positives initially

---
## Discovery (TA0007)

### Network Scanning Activity (High Volume Connection Attempts)

**Status:** Template

#### Purpose

Detect scanning behavior via repeated outbound connections to many ports/IPs.

#### Log Sources

- ```Sysmon``` Event ID 3 (Network Connection)

#### KQL (Template)

```kql
Sysmon
| where EventID == 3
| summarize ConnCount = count() by SourceIp = Computer,
    DestinationIp, bin(TimeGenerated, 5m)
| where ConnCount > 50
| sort by ConnCount desc
```

#### MITRE Mapping

- **Technique:** T1046 — Network Service Discovery

---

## Lateral Movement (TA0008)

### Pass-the-Hash/Pass-the-Ticket Indicators

**Status:** Template

#### Purpose

Identify lateral movement attempts using stolen tokens or credentials.

#### Log Sources

- ```SecurityEvent``` / ```Event```
- Event ID: 4624, 4625  
- ```Sysmon```

#### KQL (Template)

```kql
Event
| where EventID == 4624
| where LogonType == "9" or LogonType == "3"
| extend IpAddress = tostring(AdditionalFields["IpAddress"])
| summarize LogonCount = count() by TargetUser, IpAddress, bin(TimeGenerated, 30m)
| where LogonCount > 10
```

#### MITRE Mapping

- **Technique:** T1550 — Use of Alternate Authentication Material

---

## Defense Evasion (TA0005)

### Execution of LOLBAS Binaries (e.g., certutil, mshta, bitsadmin)

**Status:** Template

#### Log Sources

- ```Sysmon``` Event ID 1

---

#### KQL (Template)

```kql
Sysmon
| where EventID == 1
| where Process in~ ("certutil.exe", "mshta.exe", "bitsadmin.exe",
    "rundll32.exe")
| project TimeGenerated, Computer, User, Process, CommandLine
```

#### MITRE Mapping

- **Technique:** T1218 — Signed Binary Proxy Execution (LOLBAS)

---

## Persistence (TA0003)

### New Service Installations

#### Purpose

Detect potential persistence via malicious service creation.

#### KQL (Template)

```kql
Sysmon
| where EventID == 13
| where TargetObject contains "Services"
```

#### MITRE Mapping

- **Technique:** T1543 - Create or Modify System Process

---

## Notes

This detection pack evolves over time as I add new detections from:

- New labs
- Threat simulations
- Purple-team exercises
- Attack emulations
- Cloud-specific threat models

Each detection supports either:

- Threat hunting,
- Analytics rule creation, or
- Behavior anomaly detection

---
