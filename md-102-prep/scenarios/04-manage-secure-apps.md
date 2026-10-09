# Domain 4 — Manage and secure applications (15–20%)

## Scenario 4.1 — Deploy an in-house .exe installer

The finance team uses a vendor application delivered as `setup.exe` with a silent
switch `/S`. It must be installed on all finance PCs and updated next quarter.

**Question:** how do you deploy it with Intune?

<details>
<summary>Answer</summary>

- Package it as a **Win32 app**: put the installer in a folder and run the
  **Microsoft Win32 Content Prep Tool** (`IntuneWinAppUtil.exe`) to create an
  `.intunewin` file.
- In Intune > Apps > Windows > Add > Windows app (Win32): install command
  `setup.exe /S`, uninstall command, install behaviour (System), requirements
  (64-bit, Windows 11), and a **detection rule** (file, registry key or MSI product code)
  so Intune knows it is installed.
- Assign as **Required** to the finance group.
- Next quarter: add the new version and set **supersedence** to replace the old one.
- Troubleshoot with the app install status report and the Intune Management Extension
  logs on the PC (`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`).
</details>

## Scenario 4.2 — Outlook on personal phones without enrolment

Staff use Outlook and Teams on personal phones. Company data must not be copied into
WhatsApp or personal storage, and must be erasable if someone leaves. Phones are
**not** enrolled in Intune.

**Question:** what do you configure?

<details>
<summary>Answer</summary>

- **App protection policies (MAM without enrolment)** for iOS and Android, targeting
  Outlook, Teams, OneDrive, Word, Excel:
  - restrict cut, copy and paste to policy-managed apps
  - block "Save as" to personal storage
  - require a PIN or biometrics to open the app
  - encrypt app data
- **Conditional Access** with grant control **Require app protection policy**, so only
  protected apps reach Exchange and SharePoint from mobiles.
- When someone leaves: **selective wipe** of company data in the apps; personal photos
  and apps are untouched.
</details>

## Scenario 4.3 — Microsoft 365 Apps on new PCs

New Autopilot PCs must have Microsoft 365 Apps (64-bit, French and English, Monthly
Enterprise Channel) installed before the user reaches the desktop, without Access or
Publisher.

**Question:** how do you deploy and configure it?

<details>
<summary>Answer</summary>

- Intune > Apps > Windows > Add > **Microsoft 365 Apps for Windows 10 and later**:
  choose apps (exclude Access and Publisher), 64-bit, **Monthly Enterprise Channel**,
  languages FR and EN. For advanced options, use an **Office Deployment Tool (ODT)**
  XML configuration.
- Assign as **Required** to the Autopilot device group, and add it to the
  **Enrollment Status Page** blocking apps list.
- Manage settings (for example default file save location, macros) with the
  **Microsoft 365 Apps admin center** cloud policies or an Intune settings catalog
  profile.
</details>
