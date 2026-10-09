<#
.SYNOPSIS
    Autopilot: registers a Windows PC in your tenant so it configures itself
    at first start.

.DESCRIPTION
    WHAT IT IS FOR
    With Windows Autopilot, IT never "images" a PC by hand. Each PC has a
    hardware hash (a fingerprint). Once this hash is uploaded to Intune, the
    PC recognises the company at first start: the user signs in with their
    work account, and the PC joins Entra ID, enrols in Intune and installs
    apps and policies on its own.
    In real life the PC vendor uploads the hashes. In the lab you upload the
    hash of your Windows 11 virtual machine yourself.

    RUN THIS SCRIPT INSIDE THE WINDOWS 11 VM, in PowerShell AS ADMINISTRATOR.

.NOTES
    Then, in the Intune admin center (intune.microsoft.com):
      Devices > Windows > Enrollment > Deployment profiles > Create profile
        - Join to Microsoft Entra ID, user-driven, assign to the group below
      After the profile shows "Assigned" on the device:
      reset the VM (Settings > System > Recovery > Reset this PC)
      and watch the out-of-box experience (OOBE) with your company branding.
#>

# 1. Allow the script to run in this window only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# 2. Install Microsoft's community script that reads the hardware hash
Install-Script -Name Get-WindowsAutopilotInfo -Force

# 3. Upload the hash directly to your tenant (you will be asked to sign in)
#    -GroupTag lets you target this kind of device with a dynamic group
#    -Assign waits until a deployment profile is assigned
Get-WindowsAutopilotInfo -Online -GroupTag 'LAB-PC' -Assign

# Alternative without upload: save the hash to a CSV and import it in
# Intune > Devices > Windows > Enrollment > Devices > Import
#   Get-WindowsAutopilotInfo -OutputFile C:\Temp\autopilot-hash.csv

<#  Dynamic group to create in Entra ID (Groups > New group > Dynamic device),
    rule that catches every device with the tag LAB-PC:
        (device.devicePhysicalIds -any (_ -eq "[OrderID]:LAB-PC"))
#>
