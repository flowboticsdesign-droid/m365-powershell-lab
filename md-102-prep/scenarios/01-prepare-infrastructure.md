# Domain 1 — Prepare infrastructure for devices (20–25%)

## Scenario 1.1 — Company PCs vs personal phones

A 120-person company is moving to cloud-only management. Company laptops must be fully
managed. Staff also want to read work email on their personal Android phones, but
refuse to let IT control the whole phone.

**Question:** which Entra ID device identity and which Intune approach do you use for each?

<details>
<summary>Answer</summary>

- **Company laptops**: **Microsoft Entra join** (the device belongs to the organisation,
  users sign in with work accounts), with **automatic Intune enrolment** (MDM user scope
  set in Intune > Enrollment > Automatic enrollment). Later, Autopilot for new PCs.
- **Personal phones**: **Entra registration** (BYOD: device known, not owned), and either
  Android Enterprise **personally owned work profile** (separates work and personal data;
  IT only manages the work side) or no enrolment at all with **app protection policies
  (MAM)** on Outlook and Teams.
- Use **enrolment restrictions** to decide which platforms and ownership types may enrol.

Key idea: *join* = company device, *register* = personal device (BYOD).
</details>

## Scenario 1.2 — Block access from unhealthy devices

Management wants Microsoft 365 data accessed only from PCs that are encrypted and up to
date. Today anyone can sign in from any computer.

**Question:** what do you configure, and in what order, to avoid locking everyone out?

<details>
<summary>Answer</summary>

1. **Compliance policy** (Intune > Devices > Compliance > Windows 10 and later): require
   BitLocker, Secure Boot, minimum OS version, firewall. Set **Actions for noncompliance**
   (mark non-compliant immediately or after a grace period, send an email).
2. Assign it to a pilot group first, check the compliance report.
3. **Conditional Access policy** (Entra ID > Protection > Conditional Access): users =
   pilot group, cloud apps = Office 365, grant = **Require device to be marked as compliant**.
4. Start in **Report-only** mode, review sign-in logs, then switch to **On**.
5. Exclude **break-glass emergency admin accounts** from the policy.

Compliance policy alone does nothing to access: Conditional Access enforces it.
</details>

## Scenario 1.3 — Local admin passwords and helpdesk rights

All PCs share the same local Administrator password, known by several former
employees. A junior helpdesk technician also has Global Administrator rights "to be able
to reset things".

**Question:** what do you change?

<details>
<summary>Answer</summary>

- **Windows LAPS** with Intune (Endpoint security > Account protection > Local admin
  password solution): a unique, rotated password per device, backed up to Entra ID.
  Helpdesk reads it in the device's page in Intune or Entra when needed, and it can be
  rotated as a remote action after use.
- **Least privilege with RBAC**: remove Global Administrator; give the built-in **Help Desk
  Operator** Intune role (and Helpdesk Administrator in Entra for password resets).
  Use **scope tags** if technicians should only see devices of their site.
- For risky actions like wiping devices, enable **multi-admin approval**.
</details>
