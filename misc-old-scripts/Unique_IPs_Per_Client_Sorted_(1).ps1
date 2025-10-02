$client = Read-Host 'Who is the client?'
[int]$period = Read-Host 'How many days into the past do you need?'
$credential = Get-Credential
$credentials = Get-Credential -Credential $credential
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
     -ConfigurationName Microsoft.Exchange -Credential $credentials `
        -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
$startDate = (Get-Date).AddDays(0-$period)
$endDate = (Get-Date)
$Logs = @()
$outputFile = "c:\Output\$client-"+((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))+"-Unique IPs.csv"

Write-Host " "
Write-Host "Output File Location - $outputFile"
"IP, Location" | Out-File $outputFile -Append -Encoding ascii

Function Write-OutFile ([String]$Message)
{
$Message | Out-File $outputFile -Append
}

Write-Host " "
Write-Host "Retrieving login IPs for $client during period $startDate to $endDate"

    do {
        $logs += Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId "UALSearch" -ResultSize 5000 -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn #-SessionId "$($customer.name)"
        Write-Host "Retrieved $($logs.count) logs"
    }while ($Logs.count % 5000 -eq 0 -and $logs.count -ne 0)
    
    Write-Host " "
    Write-Host "Finished Retrieving logs" -ForegroundColor Green

$userIds = $logs.userIds | Sort-Object -Unique

$ips = @()

foreach ($userId in $userIds) {
 
    $searchResult = ($logs | Where-Object {$_.userIds -contains $userId}).auditdata | ConvertFrom-Json -ErrorAction SilentlyContinue
    $ips += $searchResult.clientip | Sort-Object -Unique
}

$ips = $ips | Sort-Object

foreach ($ip in $ips) {
    Write-Host "$ip" -ForegroundColor Yellow
    Write-OutFile "$ip, "
}