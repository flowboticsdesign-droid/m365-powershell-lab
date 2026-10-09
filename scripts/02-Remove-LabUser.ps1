<#
.SYNOPSIS
    Offboarding: secures and cleans up the account of a person who leaves.

.DESCRIPTION
    WHAT IT IS FOR
    When someone leaves, the account must be closed fast (security) without
    losing their emails (business continuity). Doing it by hand, steps get
    forgotten. This script does them in the right order and logs everything:
      1. block sign-in (disable the account)
      2. revoke sessions: kicks them out of Teams, Outlook, phone apps now
      3. mailbox -> shared mailbox, hidden from the address book,
         automatic reply, and full access given to their manager
         (a shared mailbox needs no licence, so emails are kept for free)
      4. remove from all groups (this also removes group-based licences)
      5. remove licences assigned directly to the user
      6. write a log file (proof for audit)

.EXAMPLE
    .\02-Remove-LabUser.ps1 -UserPrincipalName lea.martin@contoso.onmicrosoft.com `
        -ManagerUpn camille.durand@contoso.onmicrosoft.com -WhatIf

.NOTES
    Requires: Connect-MgGraph (00-Setup.ps1). The script connects to Exchange
    Online itself. Order matters: convert the mailbox BEFORE removing the
    licence, otherwise the mailbox is deleted after 30 days.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $UserPrincipalName,
    [string] $ManagerUpn,
    [string] $AutoReply = "Cette personne ne fait plus partie de l'entreprise. Merci de contacter l'accueil."
)

$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$logDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
Start-Transcript -Path (Join-Path $logDir "offboarding-$($UserPrincipalName.Split('@')[0])-$stamp.log")

try {
    if (-not (Get-MgContext)) { throw 'Not connected to Graph. Run 00-Setup.ps1 first.' }

    $user = Get-MgUser -UserId $UserPrincipalName `
        -Property Id, DisplayName, AccountEnabled, LicenseAssignmentStates
    Write-Host "Offboarding $($user.DisplayName) ($UserPrincipalName)" -ForegroundColor Cyan

    # 1. Block sign-in
    if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Disable account')) {
        Update-MgUser -UserId $user.Id -AccountEnabled:$false
        Write-Host '[1] Account disabled' -ForegroundColor Green
    }

    # 2. Revoke all active sessions / refresh tokens
    if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Revoke sign-in sessions')) {
        Revoke-MgUserSignInSession -UserId $user.Id | Out-Null
        Write-Host '[2] Sessions revoked' -ForegroundColor Green
    }

    # 3. Mailbox: shared + hidden + auto-reply + manager access
    if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Convert mailbox to shared')) {
        Connect-ExchangeOnline -ShowBanner:$false
        Set-Mailbox -Identity $UserPrincipalName -Type Shared -HiddenFromAddressListsEnabled $true
        Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -AutoReplyState Enabled `
            -InternalMessage $AutoReply -ExternalMessage $AutoReply
        if ($ManagerUpn) {
            Add-MailboxPermission -Identity $UserPrincipalName -User $ManagerUpn `
                -AccessRights FullAccess -InheritanceType All | Out-Null
            Write-Host "    Manager $ManagerUpn has full access" -ForegroundColor Green
        }
        Write-Host '[3] Mailbox converted to shared' -ForegroundColor Green
    }

    # 4. Remove from all groups
    $groups = Get-MgUserMemberOf -UserId $user.Id -All |
        Where-Object { $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.group' }
    foreach ($g in $groups) {
        $name = $g.AdditionalProperties['displayName']
        if ($g.AdditionalProperties['groupTypes'] -contains 'DynamicMembership') {
            Write-Host "    ~ $name is dynamic (rule-based): leaves automatically" -ForegroundColor Yellow
            continue
        }
        if ($PSCmdlet.ShouldProcess($name, 'Remove member')) {
            try {
                Remove-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $user.Id
                Write-Host "    - removed from $name"
            }
            catch {
                # e.g. distribution lists are managed in Exchange, not Graph
                Write-Host "    ! $name : remove manually ($($_.Exception.Message))" -ForegroundColor Yellow
            }
        }
    }
    Write-Host "[4] Removed from $($groups.Count) group(s)" -ForegroundColor Green

    # 5. Remove licences assigned DIRECTLY (group licences left with the groups)
    $direct = $user.LicenseAssignmentStates |
        Where-Object { -not $_.AssignedByGroup } | Select-Object -ExpandProperty SkuId -Unique
    if ($direct -and $PSCmdlet.ShouldProcess($UserPrincipalName, 'Remove direct licences')) {
        Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses @($direct) | Out-Null
    }
    Write-Host "[5] Direct licences removed: $(@($direct).Count)" -ForegroundColor Green

    Write-Host 'Offboarding complete.' -ForegroundColor Cyan
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Stop-Transcript
}
