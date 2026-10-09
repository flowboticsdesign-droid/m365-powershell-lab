<#
.SYNOPSIS
    Onboarding: creates users from a CSV, puts them in department groups and
    gives them a Microsoft 365 licence through a licence group.

.DESCRIPTION
    WHAT IT IS FOR
    When 10 people join on Monday, an admin does not click 10 times in the
    portal. This script reads a CSV from HR and, for each person:
      1. builds a clean login (prenom.nom@domain), removing accents
      2. creates the account with a temporary password (change at first login)
      3. adds them to their department group (GRP-Dept-<Department>)
      4. adds them to the licence group, which gives the licence automatically
         (group-based licensing: licences follow group membership)
    Safe to re-run: existing users and groups are detected and skipped.

.EXAMPLE
    .\01-New-LabUsers.ps1 -CsvPath .\users.csv -WhatIf     # dry run, changes nothing
    .\01-New-LabUsers.ps1 -CsvPath .\users.csv             # real run

.NOTES
    Requires: 00-Setup.ps1 run first (Connect-MgGraph done).
    LAB ONLY: temporary passwords are written to a CSV. In production you would
    deliver them through a secure channel, never a file.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $CsvPath,
    [string] $UsageLocation   = 'FR',       # required before a licence can be assigned
    [string] $LicenceGroup    = 'GRP-Licence-M365-BusinessPremium',
    [string] $LicenceSkuPart  = 'SPB'       # SkuPartNumber of Microsoft 365 Business Premium
)

# Keep a reference to the script's cmdlet so helper functions can honour -WhatIf
$script:Cmd = $PSCmdlet

# ---------- helper functions ----------
function Remove-Diacritics([string] $Text) {
    # "Léa Lefèvre" -> "Lea Lefevre"
    $normalized = $Text.Normalize([Text.NormalizationForm]::FormD)
    -join ($normalized.ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' })
}

function New-LabPassword {
    # Lab-grade random password: 12 random chars + guaranteed complexity
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%'
    (-join (1..12 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })) + 'Aa1!'
}

function Get-OrCreateGroup([string] $Name) {
    $group = Get-MgGroup -Filter "displayName eq '$Name'" -ErrorAction SilentlyContinue
    if (-not $group -and $script:Cmd.ShouldProcess($Name, 'Create security group')) {
        $nick  = ($Name -replace '[^a-zA-Z0-9]', '').ToLower()
        $group = New-MgGroup -DisplayName $Name -MailEnabled:$false `
                             -MailNickname $nick -SecurityEnabled
        Write-Host "  + Group created: $Name" -ForegroundColor Green
    }
    return $group
}

# ---------- preparation ----------
if (-not (Get-MgContext)) { throw 'Not connected. Run 00-Setup.ps1 first.' }

$domain = (Get-MgDomain | Where-Object IsDefault).Id
$users  = Import-Csv -Path $CsvPath -Encoding UTF8
Write-Host "Domain: $domain - $($users.Count) users in CSV" -ForegroundColor Cyan

# Licence group: created once, licence attached to the GROUP, not to each user
$licGroup = Get-OrCreateGroup $LicenceGroup
$sku = Get-MgSubscribedSku | Where-Object SkuPartNumber -eq $LicenceSkuPart
if (-not $sku) { throw "Licence $LicenceSkuPart not found. Check Get-MgSubscribedSku." }

if ($licGroup -and $PSCmdlet.ShouldProcess($LicenceGroup, "Attach licence $LicenceSkuPart")) {
    $hasLicence = (Get-MgGroup -GroupId $licGroup.Id -Property AssignedLicenses).AssignedLicenses.SkuId -contains $sku.SkuId
    if (-not $hasLicence) {
        Set-MgGroupLicense -GroupId $licGroup.Id -AddLicenses @(@{ SkuId = $sku.SkuId }) -RemoveLicenses @() | Out-Null
        Write-Host "  + Licence $LicenceSkuPart attached to $LicenceGroup" -ForegroundColor Green
    }
}

# ---------- main loop ----------
$results = foreach ($u in $users) {
    $first = (Remove-Diacritics $u.FirstName).Trim()
    $last  = (Remove-Diacritics $u.LastName).Trim()
    $alias = ("$first.$last".ToLower() -replace "[^a-z0-9\.\-]", '')
    $upn   = "$alias@$domain"
    $status = ''
    $password = ''

    try {
        $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue
        if ($existing) {
            $user = $existing
            $status = 'Already exists'
            Write-Host "= $upn already exists, skipped creation" -ForegroundColor Yellow
        }
        elseif ($PSCmdlet.ShouldProcess($upn, 'Create user')) {
            $password = New-LabPassword
            $user = New-MgUser -DisplayName "$($u.FirstName) $($u.LastName)" `
                -GivenName $u.FirstName -Surname $u.LastName `
                -UserPrincipalName $upn -MailNickname $alias `
                -Department $u.Department -JobTitle $u.JobTitle `
                -UsageLocation $UsageLocation -AccountEnabled `
                -PasswordProfile @{ Password = $password; ForceChangePasswordNextSignIn = $true }
            $status = 'Created'
            Write-Host "+ $upn created" -ForegroundColor Green
        }

        if ($user) {
            # Department group + licence group
            $deptGroup = Get-OrCreateGroup "GRP-Dept-$($u.Department)"
            foreach ($g in @($deptGroup, $licGroup)) {
                if (-not $g) { continue }
                $isMember = Get-MgGroupMember -GroupId $g.Id -All | Where-Object Id -eq $user.Id
                if (-not $isMember -and $PSCmdlet.ShouldProcess($upn, "Add to $($g.DisplayName)")) {
                    New-MgGroupMember -GroupId $g.Id -DirectoryObjectId $user.Id
                    Write-Host "    -> added to $($g.DisplayName)"
                }
            }
        }
    }
    catch {
        $status = "ERROR: $($_.Exception.Message)"
        Write-Host "! $upn : $status" -ForegroundColor Red
    }

    [pscustomobject]@{
        UserPrincipalName = $upn
        Department        = $u.Department
        Status            = $status
        TempPassword      = $password   # LAB ONLY
    }
}

# ---------- result ----------
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$out = Join-Path $PSScriptRoot "logs\onboarding-$stamp.csv"
New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null
$results | Export-Csv $out -NoTypeInformation -Encoding UTF8
$results | Format-Table UserPrincipalName, Department, Status -AutoSize
Write-Host "Report: $out" -ForegroundColor Cyan
