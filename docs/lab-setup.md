# Lab setup

About one hour the first time.

## 1. Trial tenant

Create a free 1-month trial of **Microsoft 365 Business Premium** (search
"Microsoft 365 Business Premium free trial"). It includes Entra ID P1, Intune and
25 licences. Use a separate email address, never a real company's tenant.

## 2. PowerShell 7

```powershell
winget install Microsoft.PowerShell
pwsh
cd <path-to-repo>\scripts
.\00-Setup.ps1
```

`00-Setup.ps1` installs `Microsoft.Graph` and `ExchangeOnlineManagement` and connects
to Graph. Sign in with the trial's Global Administrator.

## 3. Windows 11 virtual machine (for Intune and Autopilot)

Hyper-V (Windows Pro or Enterprise) > New virtual machine:

- Generation 2, 4 GB RAM or more, 64 GB disk
- Settings > Security: enable **Trusted Platform Module** (Windows 11 needs TPM 2.0)
- Install Windows 11 Pro from the Microsoft ISO
- Take a checkpoint before enrolling, so you can go back and retry

## 4. Running the scripts

```powershell
.\01-New-LabUsers.ps1 -CsvPath .\users.csv -WhatIf     # dry run
.\01-New-LabUsers.ps1 -CsvPath .\users.csv
.\03-Get-IdentityAuditReport.ps1 -InactiveDays 90
.\02-Remove-LabUser.ps1 -UserPrincipalName lea.martin@<tenant>.onmicrosoft.com `
    -ManagerUpn camille.durand@<tenant>.onmicrosoft.com -WhatIf
.\04-Get-NonCompliantDevices.ps1 -From admin@<tenant>.onmicrosoft.com -To admin@<tenant>.onmicrosoft.com
# 05-Register-Autopilot.ps1 runs INSIDE the Windows 11 VM, as administrator
```

Outputs and logs go to `scripts/logs/` (ignored by git, as they can contain user data).

## Intune portal steps

In the Intune admin center (intune.microsoft.com):

1. **Enrol the VM**: in the VM, Settings > Accounts > Access work or school > Connect >
   *Join this device to Microsoft Entra ID*, sign in with a lab user.
2. **Compliance policy**: Devices > Compliance > Create policy > Windows 10 and later.
   Require BitLocker, minimum OS version, password. Assign to a group of lab users.
3. **Configuration profile**: Devices > Configuration > Create > Settings catalog
   (for example: block removable storage, set the lock screen).
4. **App deployment**: Apps > Windows > Add > Microsoft 365 Apps, assign as *Required*.
5. **Autopilot**: run `05-Register-Autopilot.ps1` in the VM, create a dynamic device group
   for the `LAB-PC` group tag, create a user-driven Entra join deployment profile,
   reset the VM and watch the out-of-box experience.

After each step, add an entry to the [lab journal](../journal/LAB-JOURNAL.md) with a screenshot.

## Key concepts

- **Microsoft Graph**: one API for Microsoft 365; permissions are *scopes* you consent to.
- **Group-based licensing**: the licence sits on a group; membership gives the licence.
- **UsageLocation**: must be set before a licence can be assigned.
- **Revoke sessions**: disabling an account does not end sessions already open; revoking does.
- **Shared mailbox**: no licence needed (under 50 GB), so a leaver's mail is kept for free.
- **Compliance + Conditional Access**: Intune marks a device healthy or not; Conditional
  Access uses that status to allow or block access.
- **`-WhatIf`**: dry-run mode for any script that changes things.
