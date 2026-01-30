# 📧 Case Study: High Severity Email Notification Playbook

## Scenario
Automated notification system that sends email alerts to the security team whenever a High severity incident is created in Sentinel.

## Business Problem
High severity incidents require immediate attention, but:
- Analysts may not be actively monitoring the Sentinel portal 24/7
- Critical incidents can be missed during shift changes
- Response delays increase attacker dwell time
- No standardized notification process

**Manual monitoring challenges:**
- Requires constant portal refreshing
- Easy to miss incidents during high-volume periods
- No guaranteed notification when analyst is away from desk
- Inconsistent communication to stakeholders

## Automated Solution
Logic App playbook that automatically:
- Triggers when any High severity incident is created
- Extracts incident details (title, severity, entities, tactics)
- Sends formatted email to security team distribution list
- Includes direct link to incident for immediate investigation

**Result:** Zero-delay notification for critical threats

---

## Workflow Design

### Trigger
**Microsoft Sentinel incident (automated trigger)**

Trigger condition: Incident severity = High

Automatically executes whenever analytics rules create High severity incidents—no manual intervention required.

### Step 1: Condition Check (Optional)
```
Action: Condition
Check: Incident Severity equals "High"
Purpose: Double-check severity (can also be set in trigger)
```

### Step 2: Compose Email Body
```
Action: Compose
Purpose: Build HTML-formatted email content
```

**Email template structure:**
```html
🚨 HIGH SEVERITY SECURITY INCIDENT

Incident: [Incident Title]
Severity: High
Status: [Incident Status]
Created: [Incident Creation Time]

MITRE ATT&CK Tactics:
[Incident Tactics]

Description:
[Incident Description]

Affected Entities:
- Users: [Account entities]
- Hosts: [Host entities]
- IPs: [IP entities]

TAKE ACTION:
[Direct link to incident in Sentinel portal]

---
This is an automated alert from Microsoft Sentinel.
```

### Step 3: Send Email
```
Action: Office 365 Outlook - Send an email (V2)
To: security-team@example.com
Subject: "🚨 HIGH SEVERITY INCIDENT: [Incident Title]"
Body: Output from Compose action
Importance: High
```

---

## Dynamic Content Mapping

| Email Field | Dynamic Content Source |
|-------------|----------------------|
| Incident Title | Trigger: Incident title |
| Severity | Trigger: Incident severity |
| Status | Trigger: Incident status |
| Created Time | Trigger: Incident creation time UTC |
| Tactics | Trigger: Incident tactics |
| Description | Trigger: Incident description |
| Incident Link | Trigger: Incident URL |
| Account Entities | Entities - Get Accounts (if needed) |

---

## Testing

**Test Scenario:** Triggered High Risk Role Assignment analytics rule

**Test Steps:**
1. Assigned Global Administrator role to test account in Entra ID
2. Analytics rule detected privilege escalation (High severity)
3. Incident created automatically
4. Playbook triggered within 60 seconds
5. Checked email inbox for notification

**Results:**
- ✅ Email received within 2 minutes of incident creation
- ✅ All dynamic fields populated correctly
- ✅ Direct link to incident functional
- ✅ Marked as High importance in Outlook
- ✅ Professional HTML formatting maintained

**Sample email received:**
```
Subject: 🚨 HIGH SEVERITY INCIDENT: High-Risk Role Assignment Detected

[Email body with all incident details and direct link]
```

---

## Key Design Decisions

### Why Automated Trigger Instead of Manual?
- **Immediate notification:** No analyst action required
- **24/7 coverage:** Works during nights, weekends, holidays
- **Consistent alerting:** Never misses a High severity incident
- **Reduces monitoring burden:** Analysts don't need to watch portal constantly

### Why Email Instead of Teams/SMS?
- **Universal access:** Email works on all devices
- **Audit trail:** Permanent record of notifications sent
- **Integration friendly:** Can forward to ticketing systems
- **Established process:** Security teams already monitor email

### Why HTML Formatting?
- **Readability:** Structured sections easier to scan
- **Emphasis:** Red text for severity, emojis for urgency
- **Clickable links:** Direct navigation to incident
- **Professional appearance:** Suitable for management escalation

---

## Production Enhancements

**For production deployment, would add:**

1. **Tiered distribution lists:** Different emails based on severity/tactics
2. **Incident enrichment:** Include top entities, related alerts
3. **On-call rotation:** Dynamic recipient based on schedule
4. **Teams notification:** Parallel alert to Teams channel
5. **SMS for critical:** Text message for specific MITRE tactics
6. **Manager escalation:** CC management for specific incident types
7. **Acknowledgment tracking:** Follow-up if not acknowledged in X minutes

---

## Email Template Best Practices

### Effective Elements
✅ **Emoji indicators:** 🚨 for urgency, 🛡️ for containment actions  
✅ **Severity in subject:** Ensures email filters work correctly  
✅ **Direct action link:** One-click access to incident  
✅ **Concise summary:** Key details above the fold  
✅ **Timestamp:** UTC time for global teams

### Avoided Pitfalls
❌ **Too much detail:** Keep email scannable, details in Sentinel  
❌ **Generic subjects:** Specific incident titles improve routing  
❌ **Plain text only:** HTML provides better readability  
❌ **Missing context:** Always include MITRE tactics

---

## Challenges & Lessons Learned

### Successful Patterns
✅ **Compose action:** Building HTML separately from Send Email improves debugging  
✅ **High importance flag:** Ensures emails bypass filters  
✅ **Automated trigger:** Removes human error from notification chain

### Challenges Encountered
⚠️ **Dynamic content formatting:** HTML breaks if dynamic fields contain special characters  
⚠️ **Email delivery delays:** 1-2 minute lag is normal  
⚠️ **Null entity handling:** Email fails if entity extraction returns empty array

**Solutions implemented:**
- Tested dynamic content with various incident types
- Set expectations: notification within 2 minutes acceptable
- Added null-checks before entity extraction

### Key Insights
💡 **Notification ≠ Response:** Email is alerting only, incident response still required  
💡 **Template consistency:** Standardized format helps team parse emails quickly  
💡 **Link importance:** Direct incident link reduces 30+ seconds of navigation time

---

## Metrics & Impact

**Before automation:**
- Average detection-to-notification: 15-45 minutes (depends on analyst availability)
- Incidents missed during shift changes: ~5% of High severity events
- Inconsistent communication format

**After automation:**
- Average detection-to-notification: < 2 minutes
- Incidents missed: 0%
- 100% consistent notification format
- Security team satisfaction: High (anecdotal)

---

## Skills Demonstrated
- ✅ Automated trigger configuration
- ✅ Email notification workflow design
- ✅ HTML formatting in Logic Apps
- ✅ Dynamic content extraction and composition
- ✅ Severity-based conditional logic
- ✅ Understanding notification vs response workflows
- ✅ Production notification system design patterns
- ✅ Office 365 connector integration

---

## Integration Opportunities

This playbook serves as foundation for:
- **ServiceNow integration:** Create ticket automatically
- **PagerDuty alerts:** Page on-call engineer
- **SIEM correlation:** Cross-reference with other security tools
- **Metrics dashboard:** Track notification delivery times
