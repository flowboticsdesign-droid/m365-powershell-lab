# Domain 3 — Protect devices (15–20%)

## Scenario 3.1 — Encrypt every laptop without user prompts

Half the laptops are not encrypted. Users must not have to do anything, and the
helpdesk must be able to find recovery keys.

**Question:** what do you configure?

<details>
<summary>Answer</summary>

- **Disk encryption policy** (Endpoint security > Disk encryption > BitLocker):
  enable silent encryption, require TPM, encrypt OS drive (used space only for speed
  on new devices), **store recovery keys in Microsoft Entra ID** before encrypting.
- Allow **user self-service recovery** through the Company Portal or myaccount page
  so users can read their own key when locked out.
- Add **BitLocker required** to the compliance policy and watch the **encryption
  report** in Intune for devices that fail (often no TPM, or TPM not ready).
</details>

## Scenario 3.2 — Updates broke the accounting software

Last month a Windows quality update broke the accounting application on every PC at the
same time. Management wants updates, but tested first.

**Question:** how do you organise Windows updates with Intune?

<details>
<summary>Answer</summary>

- Create **update rings** (Devices > Windows updates > Update rings) by wave:
  - *Pilot*: IT and a few key users, deferral 0 days
  - *Broad*: most users, deferral 5–7 days
  - *Critical*: accounting, deferral 10–14 days
- Use groups for each ring; the pilot detects problems before they reach accounting.
- Use **feature update policies** to hold devices on a chosen Windows 11 version until
  tested.
- If an update causes problems, **pause** the ring (up to 35 days) or uninstall.
- Option: **Windows Autopatch** manages rings automatically; **Hotpatch** installs
  security updates without restart on eligible devices.
- Monitor with Windows update reports in Intune.
</details>

## Scenario 3.3 — Ransomware concern

The CEO read about ransomware arriving through Office macros and email attachments,
and asks what Intune can do.

**Question:** list the protections you would deploy.

<details>
<summary>Answer</summary>

- **Microsoft Defender Antivirus** policy: real-time protection, cloud-delivered
  protection, tamper protection.
- **Attack Surface Reduction (ASR) rules**: block Office apps from creating child
  processes, block executable content from email, block untrusted executables from
  USB. Start in **audit mode**, check reports, then **block**.
- **Controlled folder access** to protect documents folders from unknown apps.
- **Security baselines** (Windows, Defender for Endpoint, Microsoft 365 Apps) as a
  hardened starting point.
- **Onboard devices to Microsoft Defender for Endpoint** for EDR: detection,
  investigation and isolation of an infected device.
- Combine with Conditional Access: a device with a high Defender risk score becomes
  non-compliant and loses access.
</details>
