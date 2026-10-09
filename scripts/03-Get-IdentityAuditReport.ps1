<#
.SYNOPSIS
    Identity audit: inactive accounts, MFA status and licence usage, exported
    to CSV for Excel or Power BI.

.DESCRIPTION
    WHAT IT IS FOR
    Security and cost questions every IT manager asks:
      - Which accounts have not signed in for 90 days? (risk: forgotten
        accounts are a classic entry point for attackers)
      - Who has not registered MFA yet? (risk: password-only accounts)
      - How many licences do we pay for vs use? (cost)
    The script answers all three and writes two CSV files. Load them into
    Power BI for a monthly identity dashboard: this is where your BI
    background makes the difference.

.EXAMPLE
    .\03-Get-IdentityAuditReport.ps1 -InactiveDays 90

.NOTES
    Sign-in dates need Entra ID P1 (included in Business Premium) and the
    AuditLog.Read.All permission. On a brand-new tenant, most users show
    "Never" signed in: sign in once with a few lab users to see real data.
#>
param(
    [int] $InactiveDays = 90
)

if (-not (Get-MgContext)) { throw 'Not connected. Run 00-Setup.ps1 first.' }
$limit = (Get-Date).AddDays(-$InactiveDays)

# 1. Licence names: SkuId (a GUID) -> readable SkuPartNumber
$skus = Get-MgSubscribedSku
$skuName = @{}
foreach ($s in $skus) { $skuName[$s.SkuId] = $s.SkuPartNumber }

# 2. MFA registration, indexed by UPN for fast lookup
Write-Host 'Reading MFA registration...' -ForegroundColor Cyan
$mfa = @{}
Get-MgReportAuthenticationMethodUserRegistrationDetail -All | ForEach-Object {
    $mfa[$_.UserPrincipalName] = $_
}

# 3. All users with the properties we need
Write-Host 'Reading users...' -ForegroundColor Cyan
$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled,
    Department, JobTitle, CreatedDateTime, SignInActivity, AssignedLicenses, UserType

$report = foreach ($u in $users | Where-Object UserType -eq 'Member') {
    $last = $u.SignInActivity.LastSignInDateTime
    $m    = $mfa[$u.UserPrincipalName]

    [pscustomobject]@{
        DisplayName       = $u.DisplayName
        UserPrincipalName = $u.UserPrincipalName
        Department        = $u.Department
        Enabled           = $u.AccountEnabled
        Created           = $u.CreatedDateTime
        LastSignIn        = if ($last) { $last } else { 'Never' }
        Inactive          = (-not $last) -or ($last -lt $limit)
        MfaRegistered     = [bool]$m.IsMfaRegistered
        MfaMethods        = ($m.MethodsRegistered -join ', ')
        Licences          = (($u.AssignedLicenses.SkuId | ForEach-Object { $skuName[$_] }) -join ', ')
    }
}

$licences = foreach ($s in $skus) {
    [pscustomobject]@{
        Licence   = $s.SkuPartNumber
        Purchased = $s.PrepaidUnits.Enabled
        Assigned  = $s.ConsumedUnits
        Free      = $s.PrepaidUnits.Enabled - $s.ConsumedUnits
    }
}

# 4. Export
$stamp  = Get-Date -Format 'yyyyMMdd'
$outDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$report   | Export-Csv (Join-Path $outDir "audit-users-$stamp.csv")    -NoTypeInformation -Encoding UTF8
$licences | Export-Csv (Join-Path $outDir "audit-licences-$stamp.csv") -NoTypeInformation -Encoding UTF8

# 5. Summary on screen
$enabled = $report | Where-Object Enabled
Write-Host ''
Write-Host "Enabled accounts          : $($enabled.Count)"
Write-Host "Inactive > $InactiveDays days        : $(($enabled | Where-Object Inactive).Count)" -ForegroundColor Yellow
Write-Host "Without MFA registered    : $(($enabled | Where-Object { -not $_.MfaRegistered }).Count)" -ForegroundColor Yellow
$licences | Format-Table -AutoSize
Write-Host "CSV files written to $outDir" -ForegroundColor Cyan
