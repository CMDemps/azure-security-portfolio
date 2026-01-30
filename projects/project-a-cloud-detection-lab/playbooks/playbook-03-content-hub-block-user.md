# 🔒 Case Study: Block Entra ID User (Content Hub Deployment)

## Scenario
Pre-built playbook deployed from Content Hub that fully disables compromised Entra ID user accounts using Microsoft Graph API.

## Business Problem
When a user account is definitively compromised, revoking sessions alone is insufficient:
- User can sign back in immediately
- Attacker may have set up persistence (MFA bypass, OAuth tokens)
- Complete account lockdown required for containment
- Manual account disable process is slow and error-prone

**Manual account disable process:**
1. Identify compromised account (2 minutes)
2. Navigate to Entra ID portal (30 seconds)
3. Search for user (1 minute)
4. Disable account (30 seconds)
5. Document action in incident (2 minutes)
6. Notify stakeholders (3 minutes)

**Manual process time:** 9-12 minutes

## Content Hub Solution
Rather than building from scratch, deployed pre-built playbook from Microsoft Sentinel Content Hub that:
- Includes production-ready Microsoft Graph API integration
- Has pre-configured permissions and authentication
- Provides proven workflow logic
- Maintained and updated by Microsoft

**Deployment time:** 10 minutes  
**Automated execution time:** 30 seconds

---

## Why Content Hub?

### Build vs Deploy Decision

**Building from scratch would require:**
- ❌ Azure App Registration creation
- ❌ Microsoft Graph API permission configuration
- ❌ Client secret or certificate management
- ❌ Key Vault integration for secret storage
- ❌ Error handling for API rate limits
- ❌ Testing across various scenarios
- ⏱️ **Estimated time:** 2-3 hours

**Deploying from Content Hub:**
- ✅ Pre-configured Graph API integration
- ✅ Managed identity authentication (no secrets)
- ✅ Production-tested workflow
- ✅ Microsoft support and updates
- ✅ Best practices built-in
- ⏱️ **Deployment time:** 10 minutes

**Decision:** Deploy from Content Hub to save development time and leverage Microsoft's expertise.

---

## Deployment Process

### Step 1: Content Hub Discovery
1. Navigate to Sentinel → **Content Hub**
2. Search for: "Entra ID" or "Disable user"
3. Located solution containing Block-EntraIDUser playbook

### Step 2: Solution Installation
1. Clicked **Install** on Content Hub solution
2. Selected resource group: SC200-Study-RG
3. Reviewed components being deployed
4. Confirmed installation

**Components deployed:**
- Logic App (Block-EntraIDUser-Incident)
- Managed identity configuration
- Required API connections
- Sample documentation

### Step 3: Permission Configuration
1. Navigated to Logic App → **Identity** → **System assigned**
2. Verified managed identity enabled
3. Granted permissions:
   - **Microsoft Sentinel Responder:** For incident comments
   - **User Administrator:** For disabling accounts (requires elevated permissions)

### Step 4: Testing
1. Created test incident with compromised account entity
2. Ran playbook manually from incident
3. Verified account disabled in Entra ID
4. Confirmed comment added to incident

---

## Workflow Design (Pre-Built)

### Trigger
**Microsoft Sentinel incident (manual trigger)**

Manual trigger ensures analyst approval before permanent account lockdown.

### Workflow Steps (Microsoft-Built)

**Step 1: Entities - Get Accounts**
```
Extracts all account entities from incident
Returns: Array of user accounts
```

**Step 2: For Each Account**
```
Loops through each compromised account
```

**Step 3: Disable User via Graph API**
```
Action: HTTP request to Microsoft Graph API
Endpoint: PATCH /users/{userPrincipalName}
Body: { "accountEnabled": false }
Authentication: Managed identity
```

**Step 4: Add Comment to Incident**
```
Documents which accounts were disabled
Includes timestamp and playbook name
```

**Step 5: Update Incident Status** (Optional)
```
Changes incident status to "Closed - True Positive"
```

---

## Microsoft Graph API Integration

**What Content Hub Handled Automatically:**

### Authentication
- ✅ Managed identity pre-configured
- ✅ No client secrets to manage
- ✅ No certificates to rotate
- ✅ Azure RBAC integration

### API Permissions
- ✅ `User.ReadWrite.All` granted to managed identity
- ✅ Delegated vs Application permissions correctly configured
- ✅ Admin consent obtained during deployment

### Error Handling
- ✅ Retry logic for API rate limits
- ✅ Null-checks for missing entities
- ✅ Graceful failure messages in incident comments

### Best Practices
- ✅ Least-privilege permissions (only User.ReadWrite, not Global Admin)
- ✅ Audit logging via Logic App run history
- ✅ Idempotent operations (safe to re-run)

---

## Testing Results

**Test Scenario:** User modification incident with compromised test account

**Test Account:** jdoe@example.com

**Test Steps:**
1. Created Sentinel incident with jdoe as entity
2. Opened incident in portal
3. Clicked **Actions** → **Run playbook** → **Block-EntraIDUser-Incident**
4. Monitored Logic App execution
5. Verified account status in Entra ID

**Results:**
- ✅ Playbook executed successfully
- ✅ Graph API call returned 200 OK
- ✅ Account disabled in Entra ID (verified in portal)
- ✅ Comment added to incident: "Account jdoe@example.com has been disabled"
- ✅ No errors in run history
- ✅ Total execution time: ~45 seconds

**Screenshot:** Logic App designer view showing Graph API configuration

---

## Content Hub vs Custom Playbooks

### When to Use Content Hub

**Best for:**
- ✅ Common security workflows (disable user, block IP, isolate device)
- ✅ Scenarios requiring complex API integration
- ✅ Time-sensitive deployments
- ✅ Teams lacking deep API development experience
- ✅ Workflows requiring Microsoft support

### When to Build Custom

**Best for:**
- ✅ Organization-specific workflows
- ✅ Integration with custom/internal systems
- ✅ Unique business logic requirements
- ✅ Learning and skill development
- ✅ Workflows not available in Content Hub

---

## Key Learnings

### Successful Patterns
✅ **Content Hub value:** Saved 2-3 hours of development time  
✅ **Managed identity:** No secret management overhead  
✅ **Production-ready:** Microsoft-tested workflows reduce bugs  
✅ **Updates included:** Content Hub solutions receive updates from Microsoft

### Deployment Insights
💡 **Permission requirements:** User Administrator role needed for account disable  
💡 **Testing importance:** Always test with non-critical account first  
💡 **Documentation:** Content Hub includes README with configuration steps  
💡 **Customization:** Can modify deployed playbook if needed

### Security Considerations
🔒 **Privilege separation:** Only grant User Administrator role, not Global Admin  
🔒 **Audit trail:** All actions logged in Logic App run history and Sentinel  
🔒 **Reversible:** Accounts can be re-enabled if false positive  
🔒 **Manual trigger:** Prevents automated lockouts from false positives

---

## Production Considerations

### Recommended Enhancements

**For production use, would add:**
1. **Approval workflow:** Require SOC manager approval for privileged accounts
2. **Notification:** Send Teams/email when account disabled
3. **Ticketing integration:** Create ServiceNow ticket for account restoration
4. **Exception list:** Prevent disabling critical service accounts
5. **Rollback procedure:** Document account re-enable process
6. **Change management:** Track disabled accounts in CMDB

### Operational Procedures

**Should document:**
- Escalation path for false positives
- Account restoration SLA
- Communication plan for affected users
- Testing schedule for playbook updates

---

## Impact & Metrics

**Before automation:**
- Manual account disable: 9-12 minutes
- Risk of human error (wrong account, forgotten documentation)
- Inconsistent process across analysts

**After automation:**
- Automated disable: 30-45 seconds
- Zero human error in execution
- 100% consistent documentation
- Reduced attacker dwell time significantly

---

## Skills Demonstrated
- ✅ Content Hub navigation and solution discovery
- ✅ Pre-built solution deployment and configuration
- ✅ Managed identity permission assignment
- ✅ Microsoft Graph API integration (via Content Hub)
- ✅ Build vs deploy decision-making
- ✅ Understanding Graph API authentication patterns
- ✅ Production playbook evaluation
- ✅ Security workflow best practices
- ✅ Time management (leveraging existing solutions)

---

## Comparison: Custom vs Content Hub

| Aspect | Custom-Built | Content Hub |
|--------|--------------|-------------|
| Development time | 2-3 hours | 10 minutes |
| API configuration | Manual | Pre-configured |
| Authentication | Client secret/cert | Managed identity |
| Error handling | Custom implementation | Production-tested |
| Updates | Manual maintenance | Microsoft-managed |
| Support | Community only | Microsoft-backed |
| Customization | Full control | Modify after deploy |
| Best for | Unique workflows | Common scenarios |

**Conclusion:** Content Hub accelerates deployment of common security workflows while maintaining production quality and security best practices.
