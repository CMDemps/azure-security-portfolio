# Sentinel Onboarding

## Steps captured
1. Created Log Analytics Workspace (e.g., `law-sc200-lab`) in the same region as my subscription.
2. Enabled Microsoft Sentinel on that workspace.
3. Installed Azure Monitor Agent (AMA) on the Windows victim VM.
4. Connected Windows Security Events and Sysmon (Operational) channel.
5. Verified ingestion with:
   - `SecurityEvent | take 10`
   - `Sysmon | take 10`

## Screenshot list
- 01-law-created.png
- 02-sentinel-enabled.png
- 03-data-connectors.png
- 04-ama-installed.png
- 05-logs-ingesting.png

## Notes
- Secrets and tenant IDs redacted.
- Screens sanitized of PII where applicable.
- See `docs/detections.md` for the KQL used in validation.
