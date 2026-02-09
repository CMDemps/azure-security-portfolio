# 🧪 Lab 03 — AWS-Sentinel Multi-Cloud Threat Detection

## Cloud Threat Detection Case Study — Azure Security Portfolio

---

## Overview

This case study demonstrates how to build a multi-cloud threat detection pipeline integrating AWS CloudTrail with Microsoft Sentinel for cross-cloud security operations. The lab covers:

- AWS CloudTrail integration with Sentinel via S3 and SQS
- 4 custom analytics rules targeting AWS-specific attack patterns
- Cross-cloud threat correlation joining AWS and Azure sign-in data
- SOAR automation with Logic Apps for Slack incident notification
- Cloud Security Posture Management with Defender for Cloud
- KQL detection engineering with JSON parsing, cross-table joins, and threshold tuning
- MITRE ATT&CK mapping across Persistence, Impact, Collection, and Initial Access tactics

The goal is to demonstrate real-world multi-cloud SOC capabilities: detecting threats that span AWS and Azure, building detection rules from raw CloudTrail telemetry, and automating incident response workflows.

---

## Lab Environment

| Component | Purpose |
|----------|---------|
| AWS CloudTrail | API activity logging across all AWS services |
| S3 Bucket | CloudTrail log storage (<YOUR_CLOUDTRAIL_S3_BUCKET>) |
| SQS Queue | Event notification relay to Sentinel (SentinelCloudTrailQueue, us-east-2) |
| IAM Role | Cross-account authentication for Sentinel (SentinelCloudTrailRole) |
| EC2 Instance | Lab workload for security monitoring (SC200-Lab-Web01, t3.micro) |
| Microsoft Sentinel | SIEM/SOAR layer querying AWSCloudTrail table |
| Defender for Cloud | CSPM recommendations for AWS resources |
| Logic App | Automated Slack notifications for new incidents |
| Azure SigninLogs | Azure AD authentication data for cross-cloud correlation |

### Data Flow Architecture

```
AWS CloudTrail (Event Logging)
        |
        v
S3 Bucket (<YOUR_CLOUDTRAIL_S3_BUCKET>)
        |
        v
S3 Event Notification (Sentinel-CloudTrail-Notification)
        |
        v
SQS Queue (SentinelCloudTrailQueue, us-east-2)
        |
        v
Microsoft Sentinel (Polls SQS every 5-10 min)
        |
        v
AWSCloudTrail Table (Log Analytics Workspace)
        |
        +---> Analytics Rules (4 Custom Detections)
        +---> Incidents (Auto-created)
        +---> Logic App Playbook (Slack Notification)
        +---> Defender for Cloud (CSPM Recommendations)
```

**Data Flow Latency:**
- CloudTrail writes to S3: 5-15 minutes
- S3 notification to SQS: Instant
- Sentinel polls SQS: Every 5-10 minutes
- Total end-to-end: 20-30 minutes from event occurrence to Sentinel ingestion

---

## Attack Scenarios

This lab implements four detection scenarios targeting common AWS attack patterns observed in real-world incidents.

### Scenario 1: IAM Privilege Escalation

**Why it matters:** IAM privilege escalation is the first action attackers take after compromising AWS credentials. A single policy attachment may be legitimate. Three or more within 5 minutes indicates automated or malicious behavior.

| Field | Value |
|-------|-------|
| **MITRE Tactic** | Persistence |
| **MITRE Technique** | T1098 — Account Manipulation |
| **Severity** | High |
| **Data Source** | AWSCloudTrail (iam.amazonaws.com) |
| **Threshold** | 3+ privilege changes in 5-minute window |

### Scenario 2: Cryptojacking via GPU Instance Launch

**Why it matters:** Cryptojacking is one of the most common outcomes of compromised AWS credentials. Attackers don't steal data; they use the account to mine cryptocurrency. A single p3.16xlarge costs ~$24/hour, and attackers launch dozens across multiple regions.

| Field | Value |
|-------|-------|
| **MITRE Tactic** | Impact |
| **MITRE Technique** | T1496 — Resource Hijacking |
| **Severity** | High |
| **Data Source** | AWSCloudTrail (ec2.amazonaws.com) |
| **Threshold** | Single event (GPU launches have near-zero legitimate base rate) |

### Scenario 3: S3 Bucket Public Exposure

**Why it matters:** Public S3 buckets are one of the most common causes of cloud data breaches. Capital One, Twitch, and US military data were all leaked through misconfigured S3 buckets. Detecting the configuration change within minutes shrinks the attack window dramatically.

| Field | Value |
|-------|-------|
| **MITRE Tactic** | Collection |
| **MITRE Technique** | T1530 — Data from Cloud Storage |
| **Severity** | High |
| **Data Source** | AWSCloudTrail (s3.amazonaws.com) |
| **Threshold** | Single event (protection removal) |

### Scenario 4: Cross-Cloud Threat Correlation

**Why it matters:** Attackers who compromise credentials often have access to more than one environment. Most SOCs monitor each cloud in isolation, meaning a coordinated attack looks like two separate low-severity events. Correlated together, it becomes a high-severity incident.

| Field | Value |
|-------|-------|
| **MITRE Tactic** | Initial Access |
| **MITRE Technique** | T1078 — Valid Accounts |
| **Severity** | High |
| **Data Source** | AWSCloudTrail + SigninLogs (cross-table join) |
| **Threshold** | Any IP with suspicious AWS writes AND failed Azure logins within 1 hour |

---

## Simulation Steps

### Scenario 1: IAM Privilege Escalation

1. Created IAM user `test-intruder-sc200` in AWS Console
2. Attached 3 policies in rapid succession during user creation:
   - `ReadOnlyAccess`
   - `IAMFullAccess`
   - `PowerUserAccess`
3. Waited 25 minutes for CloudTrail ingestion
4. Validated detection query returned results
5. Deleted test user after validation

### Scenario 2: Cryptojacking Detection

1. Launched t3.micro instance in us-east-2 (free tier, simulating GPU launch)
2. Terminated instance immediately after launch
3. Temporarily added `t3.` to detection instance type list for testing
4. Waited 25 minutes for CloudTrail ingestion
5. Validated detection captured instance type, source IP, region, and full request parameters
6. Removed `t3.` from production rule (only GPU/ML instance families monitored)

### Scenario 3: S3 Bucket Exposure

1. Navigated to S3 bucket → Permissions → Block public access
2. Unchecked "Block all public access" and saved
3. Immediately re-enabled "Block all public access" and saved
4. Waited 25 minutes for CloudTrail ingestion
5. Validated detection fired only on the removal event (all protections set to false)
6. Confirmed re-enablement event (all set to true) was correctly filtered out

### Scenario 4: Cross-Cloud Correlation

1. Ran exploration query joining AWSCloudTrail and SigninLogs on source IP
2. Confirmed IP `<YOUR_IP_ADDRESS>` appeared in both AWS and Azure datasets
3. Built production detection targeting suspicious AWS writes + failed Azure logins
4. No test data generated (would require simulating failed Azure logins from same IP)
5. Detection logic validated against schema and confirmed correct join behavior

---

## Detection Rules

### Detection 1: AWS — Rapid IAM Privilege Escalation

```kql
// Purpose: Detect rapid IAM privilege changes indicating credential compromise
// MITRE ATT&CK: T1098 - Account Manipulation (Persistence)
// Threshold: 3+ privilege modification events from same identity within 5 minutes
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

**Entity Mapping:**
- Account: UserIdentityArn
- IP: SourceIpAddress

**Test Result:** Detection fired with ChangeCount=4 (1x CreateUser + 3x AttachUserPolicy) from `arn:aws:iam::<AWS_ACCOUNT_ID>:user/<YOUR_IAM_USER>` within a single 5-minute bin.

**Threshold Rationale:** Individual IAM policy changes are routine admin activity. Multiple changes within a tight window indicate automated or malicious behavior. Threshold of 3 balances sensitivity with false positive reduction.

---

### Detection 2: AWS — Potential Cryptojacking GPU Instance Launch

```kql
// Purpose: Detect launch of GPU/ML instance types commonly used for crypto mining
// MITRE ATT&CK: T1496 - Resource Hijacking (Impact)
// Threshold: Single event (GPU launches have near-zero legitimate base rate)
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

**Entity Mapping:**
- Account: UserIdentityArn
- IP: SourceIpAddress

**Test Result:** Validated with t3.micro launch (temporarily added to list). Detection captured instance type, AMI ID, security group, and full request parameters. Production rule monitors only GPU/ML instance families.

**Threshold Rationale:** Single-event alerting because legitimate GPU instance launches have a near-zero base rate in most organizations. Any occurrence warrants investigation.

---

### Detection 3: AWS — S3 Bucket Public Access Protections Removed

```kql
// Purpose: Detect removal of S3 public access block protections
// MITRE ATT&CK: T1530 - Data from Cloud Storage (Collection)
// Filters to only alert when protections are disabled, not re-enabled
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

**Entity Mapping:**
- Account: UserIdentityArn
- IP: SourceIpAddress
- Custom Details: BucketName

**Test Result:** Detection correctly fired on the protection removal event (all four booleans set to false) and filtered out the re-enablement event (all set to true). Only the dangerous state change generates an alert.

**Key Discovery:** The CloudTrail API event name is `PutBucketPublicAccessBlock`, not `PutPublicAccessBlock` as some documentation suggests. Always validate event names against actual CloudTrail data before building production rules.

---

### Detection 4: Multi-Cloud — Suspicious AWS Activity Correlated with Azure Failed Logins

```kql
// Purpose: Correlate suspicious AWS IAM/S3 modifications with failed Azure sign-ins
// MITRE ATT&CK: T1078 - Valid Accounts (Initial Access)
// Joins AWS and Azure data on source IP within 1-hour window
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

**Entity Mapping:**
- IP: SourceIpAddress
- Custom Details: AWSActions, TargetedUsers

**KQL Techniques Demonstrated:**
- `let` subqueries staging data from separate tables before joining
- `join kind=inner` returning only IPs present in both datasets
- `$left/$right` syntax for joining on differently-named columns
- `make_set()` with size limits to collect distinct values

**Threshold Rationale:** AWS side filters to suspicious write operations only (not reconnaissance). Azure side filters to failed logins specifically. The combination catches attackers brute-forcing Azure AD while simultaneously using compromised AWS credentials from the same infrastructure.

---

## Investigation Workflow

### Triage Steps for IAM Privilege Escalation Incident

When the IAM detection fires, follow the NIST Incident Response lifecycle: **Investigate → Contain → Eradicate → Recover**.

**Step 1: Scope the blast radius.** Before touching anything, query CloudTrail for everything that identity did in the last 24-72 hours. What resources did they access? Did they create other users or access keys? Did they launch EC2 instances?

```kql
AWSCloudTrail
| where UserIdentityArn == "<compromised_arn>"
| where TimeGenerated > ago(72h)
| summarize count() by EventSource, EventName
| order by count_ desc
```

**Step 2: Contain without destroying evidence.** Instead of deleting the user (which destroys the audit trail), attach a deny-all inline policy and deactivate any access keys. This stops the bleeding while preserving investigation data.

**Step 3: Document and escalate.** Capture source IP, geolocation, timeline of actions, and affected resources. Escalate to the team with a structured incident summary.

### Why Not Delete the User Immediately?

Deleting or disabling the compromised identity loses visibility. Active sessions may still be valid (AWS access keys don't expire when you disable a user unless you explicitly revoke them). The attacker may switch to a different compromised identity if they detect you're onto them.

---

## SOAR Automation: Slack Incident Notification

### Architecture

Sentinel Incident Trigger → Parse JSON → Compose (Description) → Compose (Timestamp) → Slack Message

### Key Implementation Details

**Alert Description Extraction:** The Sentinel incident trigger payload does not include a `description` field at the incident level. The description lives in the alerts array at `object.properties.alerts[0].properties.description`. Extracted using a Compose action expression:

```
first(body('Parse_JSON')?['object']?['properties']?['alerts'])?['properties']?['description']
```

**Timestamp Formatting:** Incident timestamps arrive in UTC. Converted to Eastern Time with 12-hour format:

```
formatDateTime(convertTimeZone(body('Parse_JSON')?['object']?['properties']?['createdTimeUtc'], 'UTC', 'Eastern Standard Time'), 'MM-dd-yyyy hh:mm tt')
```

**Slack Bold Formatting:** Slack uses single asterisks for bold: `*New Incident Created: 02-06-2026 02:10 PM*`

---

## Cloud Security Posture Management

**Defender for Cloud AWS Connector** provides continuous security assessment of AWS resources.

**Findings:**
- 272 total recommendations (269 Low, 1 Medium, 2 High)
- High severity: "Eliminate use of the root user for administrative and daily tasks"
- EC2 recommendation: "Amazon EC2 should be configured to use VPC endpoints"

**CSPM vs CWP:**
- **CSPM** assesses configuration and provides recommendations. Answers "Is this configured securely?" Free at the foundational tier.
- **CWP** provides runtime threat detection on workloads. Answers "Is this being attacked right now?" Requires paid Defender plans.

**Exam relevance:** A question about "which feature identifies that an EC2 instance has unrestricted SSH access" is CSPM. A question about "which Defender plan detects malware on an EC2 instance" is CWP (Defender for Servers).

---

## Results

**Detection Rule Validation:**

| Detection | Test Activity | Result | ChangeCount/Details |
|-----------|--------------|--------|---------------------|
| IAM Privilege Escalation | Created user + 3 policy attachments | ✅ Triggered | 4 events in 5-min window |
| Cryptojacking GPU Launch | Launched t3.micro (test substitute) | ✅ Triggered | Captured instance type, region, parameters |
| S3 Bucket Exposure | Toggled public access block off/on | ✅ Triggered | Fired only on removal, filtered re-enablement |
| Cross-Cloud Correlation | Exploration query on existing data | ✅ Validated | IP <YOUR_IP_ADDRESS> found in both AWS and Azure |

**SOAR Validation:**
- Slack notification received within 2 minutes of incident creation
- Alert description successfully extracted from alerts array
- Timestamp correctly formatted in Eastern Time with AM/PM

---

## False Positive Considerations

### IAM Privilege Escalation
- Legitimate admin onboarding new team members
- Automated provisioning systems (Terraform, CloudFormation)
- **Tuning:** Exclude known automation IAM roles, adjust threshold during onboarding periods

### Cryptojacking Detection
- Legitimate ML/AI workloads using GPU instances
- **Tuning:** Maintain allowlist of approved GPU users, add custom detail for team validation

### S3 Bucket Exposure
- Intentional public buckets for static website hosting or CDN origins
- Honeypot configurations
- **Tuning:** Implement bucket allowlist, start with alert-only before enabling auto-remediation

### Cross-Cloud Correlation
- Legitimate users working in both clouds from same IP
- **Tuning:** Filter to only suspicious AWS write operations, narrow time window

---

## Lessons Learned

### CloudTrail Event Name Validation
Always validate actual CloudTrail event names against live data before building detection rules. The API documentation said `PutPublicAccessBlock` but CloudTrail logs it as `PutBucketPublicAccessBlock`. This mismatch causes silent detection gaps in production.

### Detection Threshold Design
Alert thresholds should match the base rate of legitimate activity:
- **High base rate** (IAM policy changes): Require volume/velocity thresholds (3+ events in 5 minutes)
- **Low base rate** (GPU instance launches): Single event alerting is appropriate

### Incident Response Ordering
Follow the NIST lifecycle: Investigate → Contain → Eradicate → Recover. Scope the blast radius before taking containment actions. Containment should preserve evidence (deny-all policy, deactivate keys) rather than destroy it (delete user).

### Sentinel Incident Schema
The incident trigger payload structures description at the alert level, not the incident level. Auto-generated Parse JSON schemas may miss fields that are null or empty in the sample payload. Always inspect raw trigger payloads when troubleshooting Logic App data extraction.

### Region Consistency
All AWS resources must reside in the same region (us-east-2). SQS queue, S3 bucket, and IAM role resource ARNs must match. Region mismatch is the most common AWS-Sentinel integration failure.

### Auto-Remediation Strategy
Automation confidence should match detection confidence:
- **Low confidence:** Notify only (Slack/email)
- **High confidence:** Contain (isolate, revoke)
- **Very high confidence with defined scope:** Remediate (re-enable protections, block IP)

Always implement allowlists for known exceptions before enabling auto-remediation.

### Analytics Rules vs Custom Detection Rules
Analytics rules query Log Analytics workspace tables (AWSCloudTrail, SigninLogs, etc.) and belong in Sentinel. Custom detection rules query Advanced Hunting tables (DeviceEvents, DeviceLogonEvents, etc.) and belong in Defender for Endpoint. AWS CloudTrail data only exists in the Sentinel workspace, so these detections must be analytics rules.

---

## Budget Impact

| Resource | Monthly Cost |
|----------|-------------|
| EC2 t3.micro | $0 (free tier) |
| CloudTrail | $0 (first trail free) |
| S3 storage | ~$0.10 |
| SQS requests | $0 (first 1M free) |
| Sentinel CloudTrail ingestion | ~$2-3 |
| Defender CSPM | $0 (foundational tier) |
| **Total** | **~$2-3/month** |

---

## Skills Demonstrated

**Detection Engineering:**
- ✅ Multi-cloud SIEM integration (AWS CloudTrail + Azure Sentinel)
- ✅ KQL detection development (summarize, bin, parse_json, join, make_set, has_any, let subqueries)
- ✅ Cross-cloud threat correlation using inner joins across disparate data sources
- ✅ Threshold tuning based on legitimate activity base rates
- ✅ MITRE ATT&CK mapping (T1098, T1496, T1530, T1078)

**Security Automation:**
- ✅ Logic App SOAR workflow for Slack notification
- ✅ Alert-level data extraction from Sentinel incident payloads
- ✅ Timestamp formatting and timezone conversion in Logic Apps
- ✅ Auto-remediation design with allowlist considerations

**Cloud Security Posture:**
- ✅ Defender for Cloud CSPM assessment of AWS resources
- ✅ CSPM vs CWP distinction for exam preparation
- ✅ Security recommendation evaluation and documentation

**Infrastructure:**
- ✅ AWS-Azure cross-cloud authentication (IAM trust policies with ExternalId)
- ✅ CloudTrail → S3 → SQS → Sentinel data pipeline
- ✅ CloudFormation StackSet deployment for Defender for Cloud

**Incident Response:**
- ✅ NIST Incident Response lifecycle application
- ✅ Evidence-preserving containment strategies
- ✅ Blast radius scoping before containment actions
