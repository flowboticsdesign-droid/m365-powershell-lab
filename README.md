# Microsoft 365 & Intune Administration Lab

**Ankit Rastogi** · Microsoft 365 / Entra ID / Power Platform · Provence, France

A hands-on lab that automates the everyday work of a Microsoft 365 administrator with
**PowerShell and Microsoft Graph**: user onboarding and offboarding, identity security
audits, Intune device compliance and Windows Autopilot. It also holds my **MD-102
(Endpoint Administrator)** exam preparation, built around real support scenarios.

Everything runs on an isolated Microsoft 365 **trial tenant**. No client or employer
data is used.

> **Status: in progress.** The table below shows what has actually been run in the lab.
> Details, dates and screenshots are in the [lab journal](journal/LAB-JOURNAL.md).

## Lab progress

| # | Topic | Script / work | Status |
|---|---|---|---|
| 0 | Tenant, PowerShell 7, Graph connection | [`00-Setup.ps1`](scripts/00-Setup.ps1) | ✅ Done |
| 1 | Onboarding from an HR CSV, group-based licensing | [`01-New-LabUsers.ps1`](scripts/01-New-LabUsers.ps1) | ✅ Done |
| 2 | Offboarding: block, revoke, shared mailbox, clean-up, log | [`02-Remove-LabUser.ps1`](scripts/02-Remove-LabUser.ps1) | ✅ Done |
| 3 | Identity audit: inactive accounts, MFA, licences → Power BI | [`03-Get-IdentityAuditReport.ps1`](scripts/03-Get-IdentityAuditReport.ps1) | ⬜ To do |
| 4 | Intune: enrolment, compliance policy, configuration profile, app | [Lab setup](docs/lab-setup.md#intune-portal-steps) | ⬜ To do |
| 5 | Intune non-compliance report by email | [`04-Get-NonCompliantDevices.ps1`](scripts/04-Get-NonCompliantDevices.ps1) | ⬜ To do |
| 6 | Windows Autopilot end to end | [`05-Register-Autopilot.ps1`](scripts/05-Register-Autopilot.ps1) | ⬜ To do |
| 7 | MD-102 scenarios worked through | [MD-102 prep](md-102-prep/README.md) | ⬜ 0 / 15 |

Legend: ⬜ To do · 🟨 In progress · ✅ Done (see journal)

## What each script does, and why an admin needs it

| Script | Admin task | Why it matters |
|---|---|---|
| `00-Setup.ps1` | Install modules, connect to Microsoft Graph with least-needed scopes | Graph is the single API behind Microsoft 365 and Intune. |
| `01-New-LabUsers.ps1` | Create accounts from a CSV (accents removed from logins), department groups, licence by group, `-WhatIf` dry run | Fast, consistent onboarding with no manual errors. |
| `02-Remove-LabUser.ps1` | Disable, revoke sessions, convert mailbox to shared with auto-reply and manager access, remove groups and direct licences, transcript log | Security, business continuity, licence cost, audit trail. |
| `03-Get-IdentityAuditReport.ps1` | Accounts inactive for N days, MFA registration, licence usage, CSV for Power BI | Forgotten and password-only accounts are top attack routes; unused licences cost money. |
| `04-Get-NonCompliantDevices.ps1` | Non-compliant or stale Intune devices, emailed HTML report | Fix devices before Conditional Access blocks users. |
| `05-Register-Autopilot.ps1` | Upload a PC's hardware hash with a group tag | Zero-touch Windows deployment. |

## Skills shown

PowerShell 7 · Microsoft Graph PowerShell SDK · Exchange Online PowerShell ·
Microsoft Entra ID (users, groups, dynamic groups, group-based licensing) ·
Microsoft Intune (enrolment, compliance, configuration, apps) · Windows Autopilot ·
Conditional Access concepts · reporting with Power BI

## Repository structure

```
scripts/        PowerShell scripts + sample users.csv (outputs go to scripts/logs, not committed)
docs/           Lab setup and Intune portal steps
journal/        Lab journal: what I ran, when, the result, screenshots
md-102-prep/    MD-102 exam outline and 15 case scenarios with answers
```

## Run it yourself

See [docs/lab-setup.md](docs/lab-setup.md). Always run a script with `-WhatIf` first.

## Contact

flowbotics.design@gmail.com · Maillane (13), France
