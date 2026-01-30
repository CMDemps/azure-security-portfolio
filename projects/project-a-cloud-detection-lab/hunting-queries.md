# 🔍 Threat Hunting Queries

## Overview
Developed 5 hypothesis-driven threat hunting queries to proactively identify suspicious activity in the environment. These queries use advanced KQL techniques including time binning, risk scoring, and correlation analysis.

All queries are saved in Sentinel's Hunting blade and integrated into the Threat Hunting Dashboard workbook for regular execution.

## Hunting Methodology

**Hypothesis-Driven Approach:**
1. Formulate hypothesis about attacker behavior
2. Identify relevant data sources
3. Write KQL query to test hypothesis
4. Execute and analyze results
5. Refine query based on findings
6. Promote to analytics rule if consistent threat detected

![Hunting Queries](hunting-queries.png)  
`Shows all 5 queries saved in Hunting blade`

---

## Hunt 1: Off-Hours Administrative Activity

### Hypothesis
Compromised administrator accounts are more likely to be used outside normal business hours (12 AM - 6 AM, weekends) when legitimate admins are typically inactive.

### MITRE ATT&CK
- **Tactic:** Persistence, Defense Evasion
- **Technique:** T1562.001 - Impair Defenses

### Data Source
`AuditLogs` - Entra ID administrative operations

### KQL Query
```kql
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName has_any ("Add member to role", "Remove member from role", "Add user", "Delete user", "Reset password", "Update user")
| where Result == "success"
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend LocalTime = TimeGenerated - 5h  // Adjust for timezone
| extend HourOfDay = hourofday(LocalTime)
| extend DayOfWeek = dayofweek(LocalTime)
| extend IsOffHours = iff(HourOfDay >= 0 and HourOfDay < 6, "Late Night", 
                       iff(DayOfWeek == 0d or DayOfWeek == 6d, "Weekend", "Business Hours"))
| where IsOffHours != "Business Hours"
| project TimeGenerated, LocalTime, IsOffHours, HourOfDay, Actor, SourceIP, OperationName, TargetUser, Result
| order by TimeGenerated desc
```

### Analysis Approach

**Look for:**
- Administrative actions at 12 AM - 6 AM
- Weekend administrative activity
- Accounts that typically work 9-5 suddenly active at night
- Multiple operations from same account in off-hours window

**Investigation questions:**
- Does the account holder typically work these hours?
- Is the IP address consistent with user's known locations?
- Are the operations consistent with legitimate admin tasks?

---

## Hunt 2: Rapid Privilege Escalation Chains

### Hypothesis
Attackers who compromise an initial account often rapidly escalate privileges by assigning themselves multiple roles in quick succession.

### MITRE ATT&CK
- **Tactic:** Privilege Escalation
- **Technique:** T1098.003 - Account Manipulation: Additional Cloud Roles

### Data Source
`AuditLogs` - Role assignment operations

### KQL Query
```kql
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName == "Add member to role"
| where Result == "success"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend RoleNameRaw = tostring(TargetResources[0].modifiedProperties[1].newValue)
| extend RoleName = trim('"', RoleNameRaw)
| extend AssignedBy = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| summarize 
    RoleCount = count(),
    Roles = make_list(RoleName),
    AssignedBy = any(AssignedBy),
    SourceIPs = make_set(SourceIP),
    FirstAssignment = min(TimeGenerated),
    LastAssignment = max(TimeGenerated)
    by TargetUser, bin(TimeGenerated, 15m)
| where RoleCount >= 2
| extend TimeSpan = datetime_diff('minute', LastAssignment, FirstAssignment)
| extend RiskScore = case(
    RoleCount >= 5, 9,
    RoleCount >= 3, 7,
    TimeSpan < 5, 8,
    5
)
| project TimeGenerated, TargetUser, RoleCount, Roles, TimeSpan, RiskScore, AssignedBy, SourceIPs, FirstAssignment, LastAssignment
| order by RiskScore desc, RoleCount desc
```

### Analysis Approach

**Red flags:**
- 3+ role assignments within 15 minutes
- Escalation to Global Admin after initial lower-privileged role
- Multiple roles assigned by non-standard admin account
- High RiskScore (7-9)

**Risk Scoring Logic:**
- 5+ roles in 15 min = Score 9 (Critical)
- 3-4 roles = Score 7 (High)
- 2 roles in <5 minutes = Score 8 (High)
- Default = Score 5 (Medium)

---

## Hunt 3: Mass User Modifications

### Hypothesis
Attackers performing reconnaissance or preparing for attack may modify multiple user accounts (password resets, MFA changes) in rapid succession.

### MITRE ATT&CK
- **Tactic:** Impact, Defense Evasion
- **Technique:** T1098 - Account Manipulation

### Data Source
`AuditLogs` - User modification operations

### KQL Query
```kql
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName has_any ("Update user", "Reset password", "Update user authentication methods")
| where Result == "success"
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend SourceIP = tostring(InitiatedBy.user.ipAddress)
| summarize 
    ModificationCount = count(),
    AffectedUsers = make_set(TargetUser),
    Operations = make_set(OperationName),
    SourceIPs = make_set(SourceIP),
    FirstMod = min(TimeGenerated),
    LastMod = max(TimeGenerated)
    by Actor, bin(TimeGenerated, 30m)
| where ModificationCount >= 5
| extend TimeWindow = datetime_diff('minute', LastMod, FirstMod)
| extend RiskScore = case(
    ModificationCount >= 10, 9,
    ModificationCount >= 7, 7,
    TimeWindow < 10, 8,
    5
)
| project TimeGenerated, Actor, ModificationCount, AffectedUsers, TimeWindow, RiskScore, Operations, SourceIPs, FirstMod, LastMod
| order by RiskScore desc
```

### Analysis Approach

**Indicators of compromise:**
- 10+ user modifications in 30 minutes
- Password resets for multiple privileged accounts
- Modifications from unusual IP address
- Operations outside normal help desk patterns

**Legitimate vs malicious:**
- Legitimate: Help desk performing scheduled resets
- Malicious: Attacker locking out users, preparing for persistence

---

## Hunt 4: Suspicious IP Patterns

### Hypothesis
Authentication attempts from known bad IP ranges, cloud hosting providers, or impossible travel scenarios indicate compromised credentials.

### MITRE ATT&CK
- **Tactic:** Initial Access
- **Technique:** T1078 - Valid Accounts

### Data Source
`SigninLogs` or `AuditLogs`

### KQL Query
```kql
SigninLogs
| where TimeGenerated > ago(7d)
| extend SourceIP = IPAddress
| extend Country = LocationDetails.countryOrRegion
| extend City = LocationDetails.city
| summarize 
    AuthCount = count(),
    SuccessCount = countif(ResultType == 0),
    FailureCount = countif(ResultType != 0),
    Countries = make_set(Country),
    Cities = make_set(City),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated)
    by SourceIP, UserPrincipalName
| extend CountryCount = array_length(Countries)
| where CountryCount >= 2 or FailureCount >= 5
| extend RiskScore = case(
    CountryCount >= 3, 9,  // Multiple countries
    FailureCount >= 10, 8,  // Many failures
    CountryCount == 2 and SuccessCount > 0, 7,  // Impossible travel with success
    5
)
| project SourceIP, UserPrincipalName, AuthCount, SuccessCount, FailureCount, CountryCount, Countries, Cities, RiskScore, FirstSeen, LastSeen
| order by RiskScore desc
```

### Analysis Approach

**High-risk patterns:**
- Same user from 2+ countries in short timeframe (impossible travel)
- Many authentication failures from single IP
- Success after many failures (credential stuffing)
- Known VPN/Tor exit node IPs

---

## Hunt 5: Failed Login Spikes (Brute Force Patterns)

### Hypothesis
Significant spikes in failed authentication attempts indicate automated brute force or password spraying attacks.

### MITRE ATT&CK
- **Tactic:** Credential Access
- **Technique:** T1110 - Brute Force

### Data Source
`SigninLogs` - Entra ID sign-in attempts

### KQL Query
```kql
SigninLogs
| where TimeGenerated > ago(7d)
| where ResultType != 0  // Failed logins
| extend FailureReason = ResultDescription
| summarize 
    FailCount = count(),
    UniqueUsers = dcount(UserPrincipalName),
    TargetedUsers = make_set(UserPrincipalName),
    FailureReasons = make_set(FailureReason)
    by IPAddress, bin(TimeGenerated, 5m)
| where FailCount >= 10
| extend RiskScore = case(
    FailCount >= 50, 9,
    FailCount >= 25, 7,
    UniqueUsers >= 5, 8,  // Password spraying
    5
)
| project TimeGenerated, IPAddress, FailCount, UniqueUsers, TargetedUsers, RiskScore, FailureReasons
| order by RiskScore desc, FailCount desc
```

### Analysis Approach

**Attack patterns:**
- **Brute force:** Many attempts against single user
- **Password spraying:** Few attempts against many users
- **Credential stuffing:** Moderate attempts, known usernames

**This hunt was promoted to an analytics rule** due to consistent threat detection value.

---

## Hunt Execution Workflow

### Regular Hunting Schedule

**Daily hunts:**
- Failed Login Spikes (automated attacks common)
- Suspicious IP Patterns

**Weekly hunts:**
- Off-Hours Administrative Activity
- Rapid Privilege Escalation
- Mass User Modifications

### Integration with Threat Hunting Dashboard

All 5 queries integrated into workbook for one-click execution:
1. Open Threat Hunting Dashboard
2. Select time range (typically last 24 hours)
3. Review all 5 hunt results simultaneously
4. Investigate high RiskScore findings
5. Create incidents for confirmed threats

**Time saved:** 15 minutes of manual querying → 30 seconds of dashboard review

---

## Hunt Promotion Criteria

**When to promote hunting query to analytics rule:**

✅ **Consistent findings** - Query regularly identifies threats  
✅ **Low false positives** - Results are actionable, not noise  
✅ **Clear investigation path** - Findings lead to obvious next steps  
✅ **Automation value** - Automated detection adds value over periodic hunting

**Promoted queries:**
- Failed Login Spikes → Became "RDP Brute Force Detection" analytics rule

**Remaining as hunts:**
- Other 4 queries - valuable for periodic review but don't need 24/7 automation

---

## Skills Demonstrated

- ✅ Hypothesis-driven threat hunting methodology
- ✅ Advanced KQL techniques (time binning, aggregation, risk scoring)
- ✅ MITRE ATT&CK framework mapping
- ✅ Data source selection and correlation
- ✅ Risk scoring algorithm development
- ✅ Hunt-to-rule promotion workflow
- ✅ Integration with workbooks for operational efficiency
- ✅ Understanding hunting vs detection tradeoffs

---

## Key Learnings

### Effective Hunting Practices

**Start with hypothesis:** Random querying wastes time - always have specific threat scenario in mind

**Use risk scoring:** Helps prioritize findings - investigate Score 7-9 first

**Time binning matters:** 5-minute windows for brute force, 30-minute for privilege escalation

**Correlation is key:** Single events rarely tell the story - aggregate and correlate

### Common Pitfalls Avoided

❌ **Overly broad queries** - Too many results to analyze  
✅ **Solution:** Added thresholds and filters (RoleCount >= 2, ModificationCount >= 5)

❌ **No prioritization** - All findings treated equally  
✅ **Solution:** Implemented RiskScore to focus analyst attention

❌ **Hunting isolation** - Results not shared or acted on  
✅ **Solution:** Integrated into workbook, promoted high-value hunts to rules

---

## Production Hunting Program Recommendations

**For enterprise hunting program:**

1. **Scheduled execution** - Daily/weekly cadence for each hunt
2. **Results tracking** - Document findings and outcomes
3. **Continuous refinement** - Update queries based on findings
4. **Threat intelligence integration** - Incorporate IOCs into hunts
5. **Team collaboration** - Share successful hunts across analysts
6. **Metrics collection** - Track hunt effectiveness over time
