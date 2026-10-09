# Lab journal

A dated record of what I actually ran in the lab, what happened, and what I learned.
Newest entries at the top. Screenshots go in [`screenshots/`](screenshots/).

Remove tenant IDs, real email addresses and passwords from screenshots before committing.

---

##2026-08-09 — Lab setup: PowerShell 7 and Microsoft Graph

Goal: prepare the admin workstation and connect to the Microsoft 365 tenant with PowerShell.
What I ran: installed PowerShell 7.6 (winget), modules Microsoft.Graph 2.41 and ExchangeOnlineManagement 3.10;
`Connect-MgGraph` with read-only scopes (User.Read.All, Organization.Read.All); `Get-MgContext`, `Get-MgUser`,
`Get-MgSubscribedSku`, `Get-MgDomain`.
Result: connected as tenant admin; 1 user; 1 domain (.onmicrosoft.com, initial and default);
licences: Business Premium trial (SPB, 25 available, 0 assigned), Business Standard (O365_BUSINESS_PREMIUM), Power BI, Power Apps Developer.
Problem met and fix: sign-in window can open behind the terminal (Web Account Manager warning); found it in the taskbar.
What I learned: variables and properties (`$PSVersionTable.PSVersion`), the pipeline `|` with `Select-Object`,
Graph scopes = permissions consented at sign-in, licence SKU code names (SPB = Business Premium, O365_BUSINESS_PREMIUM = Business Standard).
