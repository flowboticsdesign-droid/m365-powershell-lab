# MD-102 — Microsoft 365 Endpoint Administrator: preparation

Exam MD-102 leads to the **Microsoft 365 Certified: Endpoint Administrator Associate**
certification. It tests deploying, configuring, protecting and monitoring devices and
apps with Microsoft Intune, Windows Autopilot and Microsoft Entra ID.

Outline below follows the official study guide, version effective **27 October 2026**
([source](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102)).
Check that page again before booking the exam: Microsoft updates it regularly.

## Skills measured

| # | Domain | Weight | Scenarios |
|---|---|---|---|
| 1 | Prepare infrastructure for devices | 20–25% | [01-prepare-infrastructure.md](scenarios/01-prepare-infrastructure.md) |
| 2 | Manage and maintain devices | 25–30% | [02-manage-maintain-devices.md](scenarios/02-manage-maintain-devices.md) |
| 3 | Protect devices | 15–20% | [03-protect-devices.md](scenarios/03-protect-devices.md) |
| 4 | Manage and secure applications | 15–20% | [04-manage-secure-apps.md](scenarios/04-manage-secure-apps.md) |
| 5 | Optimize endpoint operations: automation, monitoring, reporting | 10–15% | [05-automation-monitoring.md](scenarios/05-automation-monitoring.md) |

### Main topics per domain

**1. Prepare infrastructure for devices**
- Entra join vs Entra registration; joining and registering devices; dynamic device groups
- Intune enrolment: settings, automatic Windows enrolment, enrolment restrictions,
  Apple Business Manager, Android Enterprise profiles
- Intune roles, scope tags, multi-admin approval
- Compliance policies; Conditional Access requiring a compliant device
- Windows Hello for Business, Windows LAPS, local group membership

**2. Manage and maintain devices**
- Autopilot: deployment profiles vs device preparation; user-driven, pre-provisioning,
  self-deploying; device name template; Enrollment Status Page (ESP)
- Windows 11 upgrades with Intune; Windows 365 Cloud PCs; Windows Backup
- Configuration profiles: settings catalog, ADMX import, Group Policy analytics,
  assignment filters
- Intune Suite: Endpoint Privilege Management, Enterprise App Catalog, Remote Help,
  Cloud PKI, Microsoft Tunnel for MAM, Advanced Analytics
- Remote actions: sync, restart, retire, wipe, bulk actions, rotate BitLocker keys and
  LAPS passwords, device query (KQL), collect diagnostics

**3. Protect devices**
- Endpoint security: antivirus, disk encryption (BitLocker), firewall, Attack Surface
  Reduction, security baselines, App Control for Business
- Microsoft Defender for Endpoint integration and onboarding, EDR
- Updates: update rings, feature and quality updates, Windows Autopatch, Hotpatch,
  iOS/macOS/Android updates, Delivery Optimization, monitoring

**4. Manage and secure applications**
- Win32, line-of-business and Microsoft Store apps; Microsoft 365 Apps deployment and
  policies; Office Deployment Tool; troubleshooting install failures
- App protection policies (MAM) for managed and BYOD devices; Conditional Access for
  app protection; app configuration policies

**5. Automation, monitoring and reporting**
- Intune automation with PowerShell and Microsoft Graph; custom compliance with PowerShell
- Security Copilot agents in Intune
- Reports and workbooks; Endpoint Analytics; Remediations scripts; service health;
  alerts on compliance drift and enrolment failures

## How to use the scenarios

Each scenario is a short support or project situation like the ones in the exam's
case studies. Read it, write your own answer, then open **Answer** to compare.
Where possible, reproduce it in the lab and log it in the [journal](../journal/LAB-JOURNAL.md).

## Study plan (4 weeks, about 1 hour a day)

| Week | Focus | Microsoft Learn path | Lab |
|---|---|---|---|
| 1 | Domain 1: identity, enrolment, compliance | MD-102 path, "Prepare infrastructure" modules | Scripts 00–03; enrol the VM |
| 2 | Domain 2: Autopilot, configuration, remote actions | "Manage and maintain devices" | Script 05; configuration profiles |
| 3 | Domains 3 and 4: security, updates, apps | "Protect devices", "Manage applications" | BitLocker, update ring, Win32 app, app protection |
| 4 | Domain 5 + revision | "Automation and monitoring"; free Practice Assessment | Script 04; Remediations; all scenarios again |

## Progress

- [ ] Domain 1 scenarios (3)
- [ ] Domain 2 scenarios (3)
- [ ] Domain 3 scenarios (3)
- [ ] Domain 4 scenarios (3)
- [ ] Domain 5 scenarios (3)
- [ ] Microsoft Learn Practice Assessment above 80%
- [ ] Exam booked
