# GitHub Copilot Instructions — Azure Security Portfolio

## Repository Overview

This is an Azure Cloud Security Portfolio showcasing hands-on work in:
- **Cloud Threat Detection Engineering** with KQL analytics and Microsoft Sentinel
- **DevSecOps Automation** with secure CI/CD pipelines
- **Infrastructure as Code** using Azure Bicep and Terraform
- **Security Engineering** aligned with Azure certifications (AZ-500, SC-100, SC-200)

The repository is designed to run in an **Azure Student Subscription** with reproducible, cost-effective deployments.

---

## Repository Structure

```
azure-security-portfolio/
├── docs/                           # Architecture diagrams and images
│   ├── architecture/               # Technical architecture documentation
│   └── images/                     # Screenshots and diagrams
├── infra/                          # Infrastructure as Code
│   ├── bicep/                      # Azure Bicep modules
│   └── terraform/                  # Terraform configurations
├── projects/                       # Main project implementations
│   ├── project-a-cloud-detection-lab/   # KQL detections & threat hunting
│   ├── project-b-landing-zone-lite/     # Secure Azure architecture
│   └── project-c-devsecops-pipelines/   # CI/CD security automation
├── scripts/                        # Automation and utility scripts
├── PORTFOLIO-INDEX.md              # Central project index
└── README.md                       # Portfolio overview
```

---

## Tech Stack

### Cloud & Infrastructure
- **Azure Services**: Log Analytics Workspace, Microsoft Sentinel, Azure Monitor, Key Vault, Virtual Networks, NSGs
- **IaC Tools**: Azure Bicep (preferred), Terraform (alternative)
- **Authentication**: Azure OIDC for GitHub Actions (no secrets stored)

### DevSecOps & Security
- **CI/CD**: GitHub Actions
- **Security Scanning**: CodeQL (SAST), Checkov (IaC), tfsec (Terraform), Trivy (containers)
- **Monitoring**: Azure Monitor Agent (AMA), Sysmon, Windows Security Events

### Detection Engineering
- **Query Language**: Kusto Query Language (KQL)
- **Framework**: MITRE ATT&CK
- **Log Sources**: Windows Security Events, Sysmon, Azure Activity Logs, NSG Flow Logs

---

## Coding Conventions & Best Practices

### Documentation Style
- Use **emoji prefixes** in headers for visual clarity (e.g., `# 🔍 Detection Pack`)
- Start all major documents with a brief overview and purpose
- Include **MITRE ATT&CK mappings** for all detections (Tactic, Technique, ID)
- Use tables for structured information (components, skills, mappings)
- Include **architecture diagrams** (Mermaid preferred)
- Structure case studies with: Overview → Environment → Attack Scenario → Detection → Analysis

### KQL Query Conventions
- Always include comments explaining the detection logic
- Format queries for readability with proper indentation
- Include time windows and thresholds explicitly
- Document **false positive scenarios** and tuning guidance
- Provide **log sources** and required event IDs
- Map to MITRE ATT&CK framework
- Example structure:
  ```kql
  // Purpose: Detect RDP brute force attempts
  // MITRE ATT&CK: T1110 - Brute Force
  SecurityEvent
  | where EventID == 4625
  | where TimeGenerated > ago(1h)
  | summarize FailedAttempts = count() by IpAddress, TargetUserName
  | where FailedAttempts > 10
  ```

### Infrastructure as Code (Bicep/Terraform)
- **Bicep is preferred** for Azure-native deployments
- Use **modular design** with reusable components
- Include comprehensive parameter descriptions
- Apply **security best practices**:
  - Enable diagnostic settings for all resources
  - Use Key Vault for secrets
  - Implement least-privilege NSG rules
  - Enable Azure Monitor integration
- Document resource dependencies clearly
- Include deployment instructions and prerequisites
- Test deployments in student/dev subscriptions first

### Security Practices
- **Zero Trust principles**: Network segmentation, least privilege access
- **Secure by default**: All deployments should include logging and monitoring
- **No secrets in code**: Use Azure Key Vault and GitHub OIDC
- **Defense in depth**: Multiple security layers (NSGs, Azure Firewall, WAF where applicable)
- **Compliance awareness**: Align with Azure security benchmarks

### DevSecOps Pipeline Conventions
- **Security gates** should be non-blocking for linting but blocking for critical vulnerabilities
- Run security scans in this order:
  1. IaC validation and linting
  2. Security scanning (Checkov/tfsec)
  3. CodeQL static analysis
  4. Container scanning (if applicable)
  5. Deployment to Azure
- Use **GitHub OIDC** for Azure authentication (no service principal secrets)
- Include job summaries with scan results
- Fail fast on critical security issues

### Git & Versioning
- Use descriptive commit messages following conventional commits format
- Keep `.gitkeep` files in empty directories to maintain structure
- Exclude build artifacts, credentials, and temporary files via `.gitignore`
- Document breaking changes in commit messages

---

## Project-Specific Guidance

### Project A: Cloud Threat Detection Lab
- Focus on **practical, actionable detections** not theoretical rules
- All detections must be tested in the lab environment
- Include investigation workflow and sample logs
- Provide tuning guidance to reduce false positives
- Document data sources and retention requirements
- Use case study format: Problem → Simulation → Detection → Investigation → Lessons Learned

### Project B: Landing Zone Lite
- Design for **Azure Student Subscription constraints** (limited quotas, budget)
- Implement **cost-effective** solutions (Standard tier when possible)
- Document **troubleshooting steps** for common deployment issues
- Include network diagrams showing subnet segmentation
- Provide both Bicep and Terraform implementations when possible

### Project C: DevSecOps Pipelines
- Prioritize **secure automation** over speed
- Include detailed documentation on OIDC setup
- Provide examples of security scan integration
- Document how to interpret scan results
- Include pipeline-as-code with GitHub Actions YAML

---

## Common Tasks & Commands

### Testing KQL Queries
```kql
// Test queries in Log Analytics Workspace
// Use small time windows during development
// Validate against actual logs before productionizing
```

### IaC Deployment
```bash
# Bicep deployment
# Use a JSON parameter file:
az deployment group create \
  --resource-group <rg-name> \
  --template-file main.bicep \
  --parameters @parameters.json

# Or use a native Bicep parameter file (recommended for Bicep projects):
az deployment group create \
  --resource-group <rg-name> \
  --template-file main.bicep \
  --parameters @main.bicepparam

# Terraform deployment
terraform init
terraform plan
terraform apply
```

### Security Scanning
```bash
# Bicep/ARM scanning
checkov -d ./infra/bicep/

# Terraform scanning
tfsec ./infra/terraform/
```

---

## Key Principles

1. **Security First**: Every component should be designed with security in mind
2. **Practical Over Perfect**: Solutions should be deployable in student subscriptions
3. **Documentation Matters**: All code should be well-documented for learning purposes
4. **MITRE ATT&CK Alignment**: All detections must map to ATT&CK framework
5. **Cost Awareness**: Consider Azure costs in all design decisions
6. **Reproducibility**: Anyone should be able to deploy these projects in their own Azure environment
7. **Real-World Relevance**: Focus on techniques and tools used in actual security operations

---

## Additional Context

- This portfolio demonstrates **entry to mid-level** cloud security engineering skills
- All projects are designed for **learning and demonstration**, not production use
- **Azure Student Subscription** is the target deployment environment
- The portfolio owner focuses on **Azure-native** security solutions
- Detection engineering follows **Sentinel best practices**
- Infrastructure follows **Azure Well-Architected Framework** security pillar

---

## When Generating Code or Content

### For KQL Detections:
- Always include MITRE ATT&CK mapping
- Provide threshold justification
- Document expected log sources
- Include false positive scenarios
- Add tuning recommendations

### For IaC:
- Default to Bicep for Azure resources
- Include diagnostic settings
- Add resource tags for organization
- Document required permissions
- Include deployment validation steps

### For Documentation:
- Use markdown tables for structured data
- Include visual elements (diagrams, screenshots)
- Provide step-by-step instructions
- Add troubleshooting sections
- Include links to official Azure documentation

### For Scripts:
- Add comprehensive error handling
- Include usage documentation
- Validate prerequisites
- Log important operations
- Make scripts idempotent where possible

---

## References

- **MITRE ATT&CK**: https://attack.mitre.org/
- **Azure Security Benchmark**: https://aka.ms/azsecbm
- **KQL Reference**: https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/
- **Bicep Documentation**: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
- **Microsoft Sentinel**: https://learn.microsoft.com/en-us/azure/sentinel/
