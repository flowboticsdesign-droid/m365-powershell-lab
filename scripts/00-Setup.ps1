<#
.SYNOPSIS
    One-time setup for the Microsoft 365 / Intune PowerShell lab.

.DESCRIPTION
    Installs the modules used by every lab script and opens a Microsoft Graph
    session with the permissions (scopes) the lab needs.

    WHAT IT IS FOR
    Every admin task in Microsoft 365 (users, groups, licences, Intune devices,
    reports) goes through Microsoft Graph, Microsoft's single API for M365.
    The "Microsoft.Graph" PowerShell module is how admins talk to Graph from a
    script. Exchange Online (mailboxes) still has its own module.

.NOTES
    Run in PowerShell 7 (pwsh), as a normal user (modules install for you only).
    Sign in with the Global Administrator account of your TRIAL tenant.
#>

# 1. Allow locally written scripts to run in this session only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# 2. Install the modules (only the first time; takes a few minutes)
$modules = 'Microsoft.Graph', 'ExchangeOnlineManagement'
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Write-Host "Installing $m ..." -ForegroundColor Cyan
        Install-Module $m -Scope CurrentUser -Force -AllowClobber
    }
    else {
        Write-Host "$m already installed" -ForegroundColor Green
    }
}

# 3. Connect to Microsoft Graph with the permissions the lab uses.
#    Each scope = one permission you consent to the first time.
$scopes = @(
    'User.ReadWrite.All'                       # create / update / disable users
    'Group.ReadWrite.All'                      # create groups, add/remove members
    'Directory.ReadWrite.All'                  # group-based licensing
    'AuditLog.Read.All'                        # last sign-in date of users
    'Reports.Read.All'                         # MFA registration report
    'DeviceManagementManagedDevices.Read.All'  # Intune devices
    'Mail.Send'                                # send the report by email
)
Connect-MgGraph -Scopes $scopes -NoWelcome

# 4. Check who you are connected as, and on which tenant
Get-MgContext | Select-Object Account, TenantId, Scopes

# 5. Useful to know: your default domain and the licences available
(Get-MgDomain | Where-Object IsDefault).Id
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits,
    @{ n = 'Available'; e = { $_.PrepaidUnits.Enabled } }

# To discover any cmdlet:   Get-Command -Module Microsoft.Graph.Users
# To read its help:         Get-Help New-MgUser -Examples
# To find the permission a cmdlet needs:  Find-MgGraphCommand -Command New-MgUser | Select -First 1 -ExpandProperty Permissions
