# Offboards V3?

<# 
.SYNOPSIS
    Try to add some interaction and verification, rather than having people paste code blocks.

.DESCRIPTION
    Offboard template for 365 accounts.  Check which email and calendars they have access to, and remove that access.
    Massive WIP!
        Currently working as individual copy/paste blocks of code, trying to make it betterer.
        To do:
            Prompt input for UPN, save UPN and Alias variables
            Check if the account exists and the UPN and Alias are correct, update person running code
            Eventually look at whether to do for 1 entered person at a time, or use a CSV to process multiple accounts

.NOTES
    File name   : Single-Offboard_v0.1.ps1
    Author      : Nicholas Constantinidis
    Prereqs     : Unsure if actually requires PowerShell v5
    Copyright   : 2024 - NConstantinidis

.LINK
    Posted to   : github eventually?   
#>


<# 
.PSEUDOCODE
## Use Write-Host etc to ask for UPN to be entered
## Verify account exists, show some basic details from Get-ExoMailbox
## Prompt if this is correct?
## Save UPN, Alias (and DisplayName ?) to separate variables
##      Look at whether this should be client agnostic, or be for specific clients to handle quirks?  Separate files vs prompt and internal references/functions
###     Look at using $Variables vs @Arrays vs Objects to store data as it's captured/iterated
###     Look at checking if Connect-AzureAD and Connect-ExchangeOnline already have running instances or need to be run
###     Look at better ways to handle group membership 
####        other types of groups eg Teams, Sharepoint, etc
###     Consider how we want to have auditable data for adding to ticket notes
####        Output to Screen? Use colours?
####        Output to CSV or Text file?
#>

<#
Write-Host "Enter full UPN for user to offboard:"
Read-Host $OffboardUserUPN
Write-Host "Checking if account exists..."
$UserStatus = Switch (Get-ExoMailbox $OffboardUserUPN) 
    if exists, then{
        Write-Host "Are these details correct?"
        Write-Host "Found account with these details, is this correct?"
        Write-Host "DisplayName: " ($UserStatus).DisplayName
        Write-Host "UPN: " ($UserStatus).UserPrincipalName
        Write-Host "Alias: " ($UserStatus).Alias
        Write-Host "Name: " ($UserStatus).Name
        Write-Host "PrimarySmtpAddress: " ($UserStatus).PrimarySmtpAddress
        Write-Host "RecipientType: " ($UserStatus).RecipientType
    }
    else{
        Write-Host "Account not found, try again"
        Read-Host $OffboardUserUPN }
#>



# Check user account for group membership

# Set variable to required username for offboarded user
$offboarduserUPN= "username@blackwoodfamilylawyers.com.au"

# Check user account for group membership
Connect-AzureAD
Get-AzureADUserMembership -ObjectId (Get-AzureADUser -ObjectID $offboarduserUPN).ObjectID | Sort-Object displayname | Select-Object displayname, mail


# Check which mail accounts and calendars they had delegate access to

# connect to Exchangeonline within Powershell
Connect-ExchangeOnline -DelegatedOrganization blackwoodfamilylawyers.com.au

# If not set above, UPN of user being offboard
$offboarduserUPN = "username@blackwoodfamilylawyers.com.au"

# Mailboxes

# get a list of all mailboxes that $offboarduserUPN has access to
$mailboxread = get-exomailbox | Get-MailboxPermission -User $offboarduserUPN
$mailboxsendas = get-exomailbox | Get-RecipientPermission -Trustee $offboarduserUPN
$mailboxsendonbehalf = Get-Mailbox | Where-Object {$_.GrantSendOnBehalfTo -match $offboarduserUPN }

# show list of permissions
$mailboxread | Select-Object identity, user, accessrights
$mailboxsendas | Select-Object identity, trustee, accesscontroltype
$mailboxsendonbehalf | Select-Object name, grantsendonbehalfto

# remove permissions for all three types
foreach ($mbox in $mailboxread) { Remove-MailboxPermission -Identity $mbox.identity -User $offboarduserUPN -AccessRights $mbox.accessrights }
foreach ($mbox in $mailboxsendas) { Remove-RecipientPermission -Identity $mbox.identity -Trustee $offboarduserUPN -AccessRights SendAs }
foreach ($mbox in $mailboxsendonbehalf) { Set-Mailbox -Identity $mbox.identity -GrantSendOnBehalfTo @{remove=$offboarduserUPN}}

# Calendars

# Set variable to required alias for offboarded user (full UPN does bad things here)
$offboarduserAlias = "username"

# find all calendars on licensed accounts that the offboarded user has access to, save to variable to speed things up
$offboardcalendarsearch = Get-EXOMailbox -RecipientTypeDetails Usermailbox | ForEach-Object {Get-EXOMailboxFolderPermission $_":\calendar"} | Where-Object {$_.User -match $offboarduserAlias }

# find all calendars on shared mailboxes - split up because this one takes longer to search, eventually this step shouldn't be required
$offboardSharedcalendarsearch = Get-EXOMailbox -RecipientTypeDetails Usermailbox | ForEach-Object {Get-EXOMailboxFolderPermission $_":\calendar"} | Where-Object {$_.User -match $offboarduserAlias }

# output list of calendars offboarded user has access to
$offboardcalendarsearch | Select-Object identity, user, accessrights
$offboardSharedcalendarsearch | Select-Object identity, user, accessrights

# remove offboarded user's permissions on all calendars
## run once each to process changes
Foreach ( $user in $offboardcalendarsearch ) { Write-Host "Now removing  $offboarduseralias  permissions for calendar owner: " -NoNewLine; Write-Host -ForeGroundColor Green (Get-ExoMailbox ($user.Identity.ToString().split(":")[0])).alias; Remove-MailboxFolderPermission -identity $user.identity -user $offboarduserAlias -Confirm:$false }
Foreach ( $user in $offboardSharedcalendarsearch ) { Write-Host "Now removing  $offboarduseralias  permissions for calendar owner: " -NoNewLine; Write-Host -ForeGroundColor Green (Get-ExoMailbox ($user.Identity.ToString().split(":")[0])).alias; Remove-MailboxFolderPermission -identity $user.identity -user $offboarduserAlias -Confirm:$false }