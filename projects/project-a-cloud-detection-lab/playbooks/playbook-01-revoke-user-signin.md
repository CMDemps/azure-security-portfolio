# 🛡️ Case Study: Revoke User Sign-In Playbook

## Scenario
Automated containment playbook that revokes all active sign-in sessions for compromised user accounts detected by Sentinel analytics rules.

## Business Problem
When a user account is compromised, every minute of delay allows attackers to:
- Access sensitive data
- Move laterally through the environment
- Establish persistence mechanisms
- Exfiltrate information

**Manual response process:**
1. Analyst sees incident (2 minutes)
2. Identifies compromised account (1 minute)
3. Opens Entra ID portal (30 seconds)
4. Finds user account (1 minute)
5. Revokes sessions (30 seconds)
6. Returns to Sentinel to document action (2 minutes)

**Manual process time:** 7-10 minutes per incident

## Automated Solution
Logic App playbook triggered manually from Sentinel incidents that:
- Extracts all account entities from the incident
- Processes containment for each account
- Documents actions in the incident
- Tags incident for tracking

**Automated process time:** 30 seconds

---

## Workflow Design

### Trigger
**Microsoft Sentinel incident (manual trigger)**

Manual trigger was chosen to allow security analysts to review incident details and validate findings before initiating containment, preventing accidental lockouts from false positives.

### Step 1: Initialize Variable
```
Action: Initialize variable
Variable Name: ThreatIntelResults  
Type: String  
Purpose: Store summary of containment actions for final comment  
```

### Step 2: Entities - Get Accounts
```
Action: Microsoft Sentinel connector - Entities - Get Accounts
Input: Incident data from trigger  
Returns: Array of account entities with UPN, name, SID  
```

### Step 3: For Each Account
```
Action: For each control
Input: Accounts array from Step 2
```

**Inside the loop (executes for each compromised account):**

**Step 3a: Add Tag to Incident**
```
Action: Microsoft Sentinel - Add incident tag
Tag Name: "ContainmentActive"  
Purpose: Mark incident as having active containment measures applied  
```

**Step 3b: Add Comment for This Account**
```
Action: Microsoft Sentinel - Add comment to incident (V3)
Incident ARM ID: From trigger  
Message: "🛡️ CONTAINMENT ACTION: Processed account [AccountName] for session revocation"  
Purpose: Create per-account audit trail  
```

### Step 4: Add Summary Comment
```
Action: Microsoft Sentinel - Add comment to incident (V3)
Incident ARM ID: From trigger  
Message:
"🛡️ CONTAINMENT SUMMARYAll compromised accounts in this incident have been processed for containment.
Status: CONTAINED
Containment playbook: Revoke-User-Sign-In
Awaiting security team review for account restoration."
```

---

## Entity Mapping
```
Entity Type: Account
Identifier: AccountName (User Principal Name)
Source: Incident entities extracted by Sentinel analytics rule
```

---

## Testing

**Test Scenario:** Triggered user modification analytics rule with test account jdoe

**Test Steps:**
1. Modified jdoe account attributes in Entra ID
2. Analytics rule detected change and created incident
3. Opened incident in Sentinel portal
4. Clicked **Actions** → **Run playbook** → **Revoke-User-Sign-In**
5. Monitored Logic App run history

**Results:**
- ✅ Account entity extracted successfully (jdoe@example.com)
- ✅ ContainmentActive tag added to incident
- ✅ Per-account comment added with user details
- ✅ Summary comment added
- ✅ Total execution time: ~30 seconds
- ✅ No errors in run history

---

## Key Design Decisions

### Why Manual Trigger Instead of Automatic?
- Prevents accidental lockouts from false positives
- Allows analyst to validate incident severity before containment
- Provides opportunity to gather evidence before user becomes aware
- Gives analyst control over timing of response action

### Why Revoke Sessions Instead of Disable Account?
- **Faster implementation:** No Microsoft Graph API permissions required
- **Immediate effect:** Logs user out of all sessions instantly
- **Forensic preservation:** Account remains active for investigation
- **Reversible:** Easier to restore if false positive than re-enabling disabled account
- **Less disruptive:** User can sign back in once cleared

### Why For-Each Loop?
- Single incident may involve multiple compromised accounts
- Each account needs individual containment action
- Provides granular audit trail per account
- Scales to handle any number of entities

### Why Multiple Comments?
- **Per-account comments:** Specific audit trail for each user
- **Summary comment:** Overall status at-a-glance
- **Compliance:** Detailed documentation for audit requirements

---

## Production Enhancements

**For production deployment, would add:**

1. **Approval workflow:** Require manager approval for high-privilege accounts
2. **Teams notification:** Alert security team when playbook runs
3. **ServiceNow integration:** Create ticket for account restoration tracking
4. **CMDB lookup:** Identify account criticality before containment
5. **Actual Graph API call:** Currently simulated; production would call `revokeSignInSessions` API
6. **Conditional logic:** Different actions based on account type (user vs service account)

---

## Challenges & Lessons Learned

### Successful Patterns
✅ **Entity extraction reliability:** "Entities - Get Accounts" works consistently  
✅ **For-each scalability:** Handles 1-100+ accounts without modification  
✅ **Tagging for filtering:** ContainmentActive tag enables quick incident filtering  
✅ **Multi-level commenting:** Per-account + summary provides excellent audit trail

### Challenges Encountered
⚠️ **Initial confusion:** Difference between "Entities - Get Accounts" vs direct entity property access  
⚠️ **Testing limitations:** Cannot use "Run" button in designer; requires real incident  
⚠️ **Field references:** Understanding when to use Incident ARM ID vs Incident URL

### Key Insights
💡 **SOAR value:** 7-minute manual task becomes 30-second automated workflow  
💡 **Analyst control:** Manual trigger balances automation with human judgment  
💡 **Audit trail:** Every action automatically documented in incident  
💡 **Containment speed:** Reduces attacker dwell time significantly

---

## Skills Demonstrated
- ✅ Logic App workflow design and implementation
- ✅ Microsoft Sentinel connector integration
- ✅ Entity extraction and dynamic content handling
- ✅ For-each loop processing for multi-entity scenarios
- ✅ Incident tagging and commenting for audit trails
- ✅ Manual vs automatic trigger decision-making
- ✅ Containment workflow best practices
- ✅ Understanding SOAR tradeoffs (speed vs control)
- ✅ Production-ready playbook design patterns

---

## Impact
**Before automation:**
- 7-10 minutes per incident
- Manual documentation prone to inconsistency
- Delays allow attacker activity to continue

**After automation:**
- 30 seconds per incident
- Consistent documentation every time
- Immediate containment limits attacker impact
- Analyst focuses on investigation, not manual tasks
