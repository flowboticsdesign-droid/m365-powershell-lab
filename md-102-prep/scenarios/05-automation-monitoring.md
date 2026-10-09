# Domain 5 — Automation, monitoring and reporting (10–15%)

## Scenario 5.1 — Weekly non-compliance report

The IT manager wants every Monday a list of non-compliant devices and devices that have
not synced for 7 days, sent by email, without anyone opening the portal.

**Question:** how do you automate it?

<details>
<summary>Answer</summary>

- PowerShell with **Microsoft Graph** (`Get-MgDeviceManagementManagedDevice`), filter on
  `ComplianceState` and `LastSyncDateTime`, export CSV and send with `Send-MgUserMail`.
  See [`scripts/04-Get-NonCompliantDevices.ps1`](../../scripts/04-Get-NonCompliantDevices.ps1).
- For an unattended run: an **app registration** with application permissions
  (`DeviceManagementManagedDevices.Read.All`, `Mail.Send`) and certificate
  authentication, scheduled in **Azure Automation** or Task Scheduler.
- Alternative without code: Intune **reports** export or a **Power BI** report on the
  Intune data warehouse.
</details>

## Scenario 5.2 — Fix a recurring issue on many PCs automatically

The helpdesk gets 20 tickets a week: a service stops on some PCs, and the fix is always
to restart it.

**Question:** how do you remove these tickets?

<details>
<summary>Answer</summary>

- **Remediations** (Intune > Devices > Scripts and remediations), part of Endpoint
  Analytics:
  - a **detection script** checks if the service is stopped (exit code 1 if yes)
  - a **remediation script** starts it and sets it to automatic
- Assign to all PCs, schedule hourly or daily.
- The report shows how many devices had the problem and how many were fixed: use it to
  find the root cause (which update, which model).
- Document it in the knowledge base: the ticket count should drop to zero.
</details>

## Scenario 5.3 — Users say "my PC is slow"

Many users complain that their PCs are slow to start, but nobody knows which models or
apps are the cause.

**Question:** which Intune tools give you facts?

<details>
<summary>Answer</summary>

- **Endpoint Analytics**: startup performance score (boot and sign-in times), app
  reliability (crashes), restart frequency, compared with a baseline.
- Break down by **model** and by **app**: for example one laptop model with an old
  driver, or a startup app adding 30 seconds to sign-in.
- Act: update drivers through Windows Update for Business driver policies, remove the
  heavy startup app, replace old devices with poor scores.
- Track the score over time to prove the improvement, and set **alerts** for
  regressions.
</details>
