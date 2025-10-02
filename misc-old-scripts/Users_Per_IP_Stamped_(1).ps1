#Prompt for User Input Variables
$client = Read-Host 'Who is the client?'
[int]$period = Read-Host 'How many days into the past do you need?'
[string]$ipRange = Read-Host 'IP Address'

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
$outputFile = "c:\Output\$client-"+((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))+"-User per IP-$ipRange .csv"
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
Write-Host "Retrieving user login data for $client during period $startDate to $endDate"

do {
    $Logs += Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId "UALSearch" -ResultSize 5000 -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn #-SessionId "$($customer.name)"
    Write-Host "Retrieved $($logs.count) logs"
    }
while ($Logs.count % 5000 -eq 0 -and $logs.count -ne 0)
    
Write-Host " "
Write-Host "Finished Retrieving logs" -ForegroundColor Green

# Extract Results
foreach ($Entry in $Logs)
{
    $data = $Entry.AuditData | ConvertFrom-Json

    if ($data.ClientIP = $ipRange)
    {
        $temp = "" | select timeStamp, userID
        $temp.timeStamp = $data.CreationTime
        $temp.userId = $data.UserId
        $searchResults += $temp
    }
}

Write-Host "$ipRange"

foreach ($record in $searchResults)
{
    $recordDate = ($record.timeStamp).Substring(0,10)
    $recordTime = ($record.timeStamp).Substring(10.8)
    $recordUserId = $record.userId
    Write-Host "$recordDate, $recordTime, $recordUserId"
    Write-OutFile "$recordDate, $recordTime, $recordUserId"
}
