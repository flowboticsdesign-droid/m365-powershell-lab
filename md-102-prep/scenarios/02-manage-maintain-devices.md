# Domain 2 — Manage and maintain devices (25–30%)

## Scenario 2.1 — 40 new laptops, no IT on site

A subsidiary opens in another city with 40 new laptops ordered from the vendor. There is
no IT person on site. Each user must receive a laptop ready to work, named
`SUB-<serial>`, with Microsoft 365 Apps installed before they reach the desktop.

**Question:** design the deployment.

<details>
<summary>Answer</summary>

- Ask the vendor to **register the hardware hashes** in your tenant (or import a CSV),
  with a group tag such as `SUB`.
- **Dynamic device group**: `(device.devicePhysicalIds -any (_ -eq "[OrderID]:SUB"))`.
- **Autopilot deployment profile**, **user-driven** mode, Microsoft Entra join,
  device name template `SUB-%SERIAL%`, assigned to that group.
- **Enrollment Status Page (ESP)** that blocks use until required apps (Microsoft 365
  Apps) and policies are installed.
- Laptops are shipped directly to users: they power on, connect to Wi-Fi, sign in, done.

Variants to know: **pre-provisioning** (vendor or IT does the device phase in advance,
user phase is faster) and **self-deploying** (kiosk or shared device, no user sign-in,
needs TPM 2.0).
</details>

## Scenario 2.2 — Moving from Group Policy to Intune

The company has 60 on-premises Group Policy Objects (GPOs) and wants to manage new
cloud-only PCs with Intune instead.

**Question:** how do you migrate the settings, and which tools help?

<details>
<summary>Answer</summary>

- Export the GPOs as XML and import them into **Group Policy analytics** (Intune >
  Devices > Group Policy analytics). It shows which settings are supported in Intune
  and the MDM equivalent.
- Recreate settings with the **settings catalog**, and **import ADMX files** for
  third-party apps (for example browser or PDF reader templates).
- Don't copy all 60 GPOs blindly: remove obsolete settings, group by purpose
  (security, browser, Office), and target with **assignment filters** (for example
  only Windows 11 or only corporate devices).
</details>

## Scenario 2.3 — Lost laptop

A sales rep reports their laptop stolen from a car. It holds client files and is
enrolled in Intune.

**Question:** what remote actions do you take, in which order, and what is the
difference between Retire and Wipe?

<details>
<summary>Answer</summary>

1. In Entra ID: **revoke the user's sessions** and reset their password (the thief
   may have cached credentials).
2. In Intune: **Wipe** the device (factory reset, removes all data). The command runs
   the next time the device connects.
3. **Rotate the BitLocker recovery key** and confirm the key was escrowed in Entra ID,
   so the disk stays unreadable.
4. Disable the device object in Entra ID, then delete it once the wipe is confirmed.
5. Log the incident.

- **Retire**: removes company data, apps, profiles and email from Intune management;
  personal data stays. Used for BYOD or when someone leaves with their own device.
- **Wipe**: full factory reset. Used for lost or stolen company devices, or
  re-assigning a device to someone else.
</details>
