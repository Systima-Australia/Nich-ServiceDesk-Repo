#Prompt for User Input Variables
$client = Read-Host 'Who is the client?'
[int]$period = Read-Host 'How many days into the past do you need? (1-90)'


# Prompt for Office 365 Credentials
$credential = Get-Credential
$credentials = Get-Credential -Credential $credential
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
     -ConfigurationName Microsoft.Exchange -Credential $credentials `
        -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber

# Set Date Range
$startDate = (Get-Date).AddDays(0-$period)
$endDate = (Get-Date)

# Set Arrays
$Logs = @()
$searchResults = @()

# Set Output File Location and Format
$outputFile = "c:\Output\$client-"+((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))+"-New-InboxRule.csv"
Write-Host " "
Write-Host "Output File Location - $outputFile"
"Date, Time, User" | Out-File $outputFile -Append -Encoding ascii

#Output File Function
Function Write-OutFile ([String]$Message)
{
    $Message | Out-File $outputFile -Append
}

# Retrieve Records
Write-Host " "
Write-Host "Retrieving Mailbox Rule data for $client during period $startDate to $endDate"

do {
    $Logs += Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId "UALSearch" -ResultSize 1000 -StartDate $startDate -EndDate $endDate -Operations New-InboxRule, Set-InboxRule, UpdateInboxRules  #-SessionId "$($customer.name)"
    Write-Host "Retrieved $($logs.count) Mailbox Rule logs"
    }
while ($Logs.count % 1000 -eq 0 -and $logs.count -ne 0)
    

# Extract Results
foreach ($Entry in $Logs)
{
    $data = $Entry.AuditData | ConvertFrom-Json

        $temp = "" | select timeStamp, userId, userIp, operation, recordInfo
        $temp.timeStamp = $data.CreationTime
        $temp.userId = $data.UserId
        $temp.userIp = $data.ClientIp
        $temp.operation = $data.Operation
        $searchResults += $temp
}


foreach ($record in $searchResults)
{
    $recordDate = ($record.timeStamp).Substring(0,10)
    $recordTime = ($record.timeStamp).Substring(10.8)
    $recordUserId = $record.userId
    $recordUserIp = $record.userIp
    $recordOperation = $record.operation

    Write-Host "$recordDate, $recordTime, $recordUserId, $recordUserIp, $recordOperation"

    Write-OutFile "$recordDate, $recordTime, $recordUserId, $recordUserIp, $recordOperation"

}
