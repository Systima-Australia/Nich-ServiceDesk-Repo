<#
.SYNOPSIS
	Add a user to standard groups for 'All users' at MBS Insurance
.DESCRIPTION
	This script asks you to enter the new user account and stores it as $User.  It adds them to all groups listed under $AllUserGroups
.NOTES
	File Name:	mbs.allusers.groups.ps1
	Version:	0.3
	Author: 	Nicholas Constantinidis
	Addendum:	https://docs.microsoft.com/en-us/microsoft-365/enterprise/connect-to-all-microsoft-365-services-in-a-single-windows-powershell-window?view=o365-worldwide was used as a template to connect to multiple MS services at one time.
#>

# Here are all the commands in a single block when using the Microsoft Azure Active Directory Module for PowerShell module.
# When finished, run
# Get-PSSession | Remove-PSSession 


$credential = Get-Credential

Connect-MsolService -Credential $credential
Connect-AzureAD -Credential $credential

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $session 

$User = Read-Host -Prompt "Please enter a user name"

$AllUsersGroups = @(
"SEC-MBS_SHPT_FOLDER_1.Advice Documents","SEC-MBS_SHPT_FOLDER_2.InsurerDocuments","SEC-MBS_SHPT_FOLDER_ClientsCRA","SEC-MBS_SHPT_FOLDER_ClientsEcovis","SEC-MBS_SHPT_FOLDER_ClientsHLBInsurance","SEC-MBS_SHPT_FOLDER_ClientsHLIG(NSW)","SEC-MBS_SHPT_FOLDER_ClientsJBWere","SEC-MBS_SHPT_FOLDER_ClientsMBSInsurance","SEC-MBS_SHPT_FOLDER_ClientsMBSWA","SEC-MBS_SHPT_FOLDER_ClientsPitcherPartners","SEC-MBS_SHPT_FOLDER_Projects","SEC-MBS_SHPT_FOLDER_RenewalsAndReviews","SEC-MBS_SHPT_FOLDER_VBP","SEC-MBS_SHPT_FOLDER_ZZArchive_ReadOnly")

$userID = Get-AzureADUser -Filter "userPrincipalName eq '$($User)'"


# Write-Host "Adding user" $User to groups:
# $AllUsersGroups | out-string

ForEach($group in $AllUsersGroups) {
	
			$groupID = Get-AzureADGroup | Where-Object { $_.DisplayName -eq $group} | Select ObjectID
			
			Add-AzureADGroupMember -ObjectId $($groupID.ObjectID) -RefObjectId $userID.ObjectId
			
			Write-Host -ForegroundColor Green "User $($User) has been added to $($group)"

}

Exit-PSSession
