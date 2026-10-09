<#
.SYNOPSIS
    Intune: lists non-compliant and out-of-sync devices, and emails the report.

.DESCRIPTION
    WHAT IT IS FOR
    In Intune, a "compliance policy" says what a healthy device looks like
    (disk encrypted with BitLocker, Windows up to date, password set...).
    A non-compliant device can be blocked from company data by Conditional
    Access. The support team must find these devices and fix them before
    users are blocked. This script:
      1. lists every non-compliant device (name, user, OS version)
      2. also flags devices that have not synced with Intune for N days
         (often a lost, broken or unused PC)
      3. saves a CSV and emails an HTML summary to the support team

.EXAMPLE
    .\04-Get-NonCompliantDevices.ps1 -StaleDays 7 -From admin@contoso.onmicrosoft.com -To admin@contoso.onmicrosoft.com

.NOTES
    Needs at least one device enrolled in Intune (see 05-Register-Autopilot.ps1
    and the README), and a compliance policy assigned to it.
#>
param(
    [int]    $StaleDays = 7,
    [string] $From,          # mailbox that sends the email (your admin account)
    [string] $To             # who receives it
)

if (-not (Get-MgContext)) { throw 'Not connected. Run 00-Setup.ps1 first.' }
$limit = (Get-Date).AddDays(-$StaleDays)

$devices = Get-MgDeviceManagementManagedDevice -All
Write-Host "$($devices.Count) managed device(s) found" -ForegroundColor Cyan

$problems = foreach ($d in $devices) {
    $reasons = @()
    if ($d.ComplianceState -ne 'compliant') { $reasons += "Compliance: $($d.ComplianceState)" }
    if ($d.LastSyncDateTime -lt $limit)      { $reasons += "No sync since $($d.LastSyncDateTime.ToString('dd/MM/yyyy'))" }
    if ($reasons) {
        [pscustomobject]@{
            Device    = $d.DeviceName
            User      = $d.UserPrincipalName
            OS        = "$($d.OperatingSystem) $($d.OsVersion)"
            Encrypted = $d.IsEncrypted
            LastSync  = $d.LastSyncDateTime
            Issue     = $reasons -join ' | '
        }
    }
}

$stamp  = Get-Date -Format 'yyyyMMdd'
$outDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$csv = Join-Path $outDir "intune-issues-$stamp.csv"
$problems | Export-Csv $csv -NoTypeInformation -Encoding UTF8

if (-not $problems) {
    Write-Host 'All devices are compliant and recently synced.' -ForegroundColor Green
}
else {
    $problems | Format-Table -AutoSize
}

# Email the report (optional)
if ($From -and $To) {
    $html = if ($problems) {
        $problems | ConvertTo-Html -Fragment -Property Device, User, OS, Encrypted, LastSync, Issue | Out-String
    } else { '<p>Tous les postes sont conformes.</p>' }

    $mail = @{
        Message = @{
            Subject      = "Intune - postes non conformes ($(@($problems).Count)) - $(Get-Date -Format 'dd/MM/yyyy')"
            Body         = @{ ContentType = 'HTML'; Content = "<h3>Rapport de conformité Intune</h3>$html" }
            ToRecipients = @(@{ EmailAddress = @{ Address = $To } })
        }
        SaveToSentItems = $true
    }
    Send-MgUserMail -UserId $From -BodyParameter $mail
    Write-Host "Report emailed to $To" -ForegroundColor Green
}
Write-Host "CSV: $csv" -ForegroundColor Cyan
