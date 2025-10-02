$User = read-host -Prompt "Enter Users Primary SMTP address" 

#$User + " is a member of these groups:" 

$Mailbox=get-Mailbox $User

$DN=$mailbox.DistinguishedName

$Filter = "Members -like ""$DN"""

Get-DistributionGroup -ResultSize Unlimited -Filter $Filter |export-CSV C:\systima\"CSV Location" 