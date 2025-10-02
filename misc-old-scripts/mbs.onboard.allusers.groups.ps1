<#
.SYNOPSIS
	Add a user to standard groups for 'All users' at MBS Insurance
.DESCRIPTION
	This script asks you to enter the new user account and stores it as $User.  It adds them to all groups listed under $AllUserGroups
.NOTES
	File Name:	mbs.allusers.groups.ps1
	Version:	0.7.5
	Author: 	Nicholas Constantinidis
	Addendum:	https://docs.microsoft.com/en-us/microsoft-365/enterprise/connect-to-all-microsoft-365-services-in-a-single-windows-powershell-window?view=o365-worldwide was used as a template to connect to multiple MS services at one time.
#>

# Log into MsolService, AzureAD, and o365
$Credential = Get-Credential
Write-Host "Connecting to MsolService" -ForegroundColor Green
Connect-MsolService -Credential $Credential
Write-Host "Connecting to AzureAD" -ForegroundColor Green
Connect-AzureAD -Credential $Credential
Write-Host "Connecting to o365" -ForegroundColor Green
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication Basic -AllowRedirection 
# Import-PSSession $Session 3> $null
# Import-PSSession $Session -DisableNameChecking
# Should probably not suppress text in case there are errors, eg too many open PSSessions
Import-PSSession $Session


# Get username to work with
$User = Read-Host -Prompt "Please enter a user name"

# Should probably verify this is a valid/active account?
# -SearchString finds closest match, should we use exact with UPN?

# Set $user to object - will include ObjectId, DisplayName, UserPrincipalName, and UserType
$User = Get-AzureADUser -SearchString $User

# Static list of security groups for 'all users' by default
$AllUsersGroups = @(
	"SEC-MBS_SHPT_FOLDER_1.Advice Documents",
	"SEC-MBS_SHPT_FOLDER_2.InsurerDocuments",
	"SEC-MBS_SHPT_FOLDER_ClientsCRA",
	"SEC-MBS_SHPT_FOLDER_ClientsCRA",
	"SEC-MBS_SHPT_FOLDER_ClientsHLBInsurance",
	"SEC-MBS_SHPT_FOLDER_ClientsHLIG(NSW)",
	"SEC-MBS_SHPT_FOLDER_ClientsJBWere",
	"SEC-MBS_SHPT_FOLDER_ClientsMBSInsurance",
	"SEC-MBS_SHPT_FOLDER_ClientsMBSWA",
	"SEC-MBS_SHPT_FOLDER_ClientsPitcherPartners",
	"SEC-MBS_SHPT_FOLDER_Projects",
	"SEC-MBS_SHPT_FOLDER_RenewalsAndReviews",
	"SEC-MBS_SHPT_FOLDER_VBP",
	"SEC-MBS_SHPT_FOLDER_ZZArchive_ReadOnly")

# Progress report
Write-Host "Adding User " -NoNewLine; Write-Host $User.DisplayName -foreground yellow -NoNewLine; Write-Host " to groups:"

# Loop to iterate across array
ForEach($Group in $AllUsersGroups) {
	# For given $Group name in array, get object so we have the ObjectID
	$Group = Get-AzureADGroup -SearchString $Group
	# Add user to each group in array. -ObjectId is for the group, -RefObjectId is for the user, -InformationVariable should track debug info (but isn't) 
	Add-AzureADGroupMember -InformationVariable $Report -ObjectId $Group.ObjectId -RefObjectId $User.ObjectId
	# Debug - count errors using $Error.Count 
	Write-Host $Group.DisplayName " status:" $Report -NoNewLine; Write-Host $Error.Count -Foreground Red -NoNewLine; Write-Host " errors so far."
	
}

# Verify group membership
Write-Host "User " -NoNewLine; Write-Host $User.DisplayName -Foreground Yellow -NoNewLine; Write-Host " is now a member of the following groups:"
$List = Get-AzureADUserMembership -ObjectId $User.ObjectId 
# Sort Group membership List alphabetically
$List | Select DisplayName | Sort-Object -Property DisplayName

# End PowerShell sessions
Get-PSSession | Remove-PSSession 

<# Manual Debug Info:

# User onboarded for T20200908.0071 - New User: Millie Abignano (15/09/2020)
$User = millie.abignano

# Get User as object for ObjectID
$User = Get-AzureADUser -SearchString $user

# Short list of Groups to keep things simple
$AllUsersGroups = @(
	"SEC-MBS_SHPT_FOLDER_1.Advice Documents",
	"SEC-MBS_SHPT_FOLDER_2.InsurerDocuments")

# Break out first two array entries for manual testing
$Group1 = $AllUsersGroups | Select-Object -Index 0
$Group2 = $AllUsersGroups | Select-Object -Index 1

# Make sure we can access ObjectIDs
$Group1 = Get-AzureADGroup -SearchString $Group1
$Group2 = Get-AzureADGroup -SearchString $Group2

# ObjectIDs are accessed by $variable.ObjectId

# Add User to Groups
Add-AzureADGroupMember -ObjectId $Group1.ObjectId -RefObjectId $User.ObjectID
Add-AzureADGroupMember -ObjectId $Group2.ObjectId -RefObjectId $User.ObjectID

# Check User is in Groups
Get-AzureADUserMembership -ObjectId $User.ObjectId | Select DisplayName

# If you need to remove the User from a Group
Remove-AzureADGroupMember -ObjectId $Group1.ObjectId -MemberId $User.ObjectId
Remove-AzureADGroupMember -ObjectId $Group2.ObjectId -MemberId $User.ObjectId
#>