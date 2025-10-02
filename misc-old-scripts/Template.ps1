#Import/Connect to platform commands here here

#365
    # Connect-MsolService

# JumpCloud
    #   $JumpCloudAPIKey = "InsertApiKeyHere" 
    #   Connect-JCOnline -JumpCloudAPIKey $JumpCloudAPIKey -Force -Verbose

#Set these (First one is purely for a text line later)
$platform = "365"
$Domain = "@domain.x.x"

Do{

Write-Host "`n   Enter the new users details" -ForegroundColor Yellow
$FirstName = Read-Host -Prompt "`n   Enter the users First name"
$LastName = Read-Host -Prompt "`n   Enter the users Last name"
$LastNameShort = $LastName.replace(' ','')


# Gathering Password
$passwordValid = $false
Do{
    Write-Host "`n   Password must meet complexity requirements:" -ForegroundColor Red
    $password1 = Read-Host "Enter the user's password" -AsSecureString
    # Prompt the user to confirm the password
    $password2 = Read-Host "Confirm the user's password" -AsSecureString

# Define a regular expression pattern to check the password requirements
    $pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#%^&$])[A-Za-z\d!@#%^&$]{10,}$"

# Check whether the password meets the requirements and matches the confirmation
    if ([System.Text.RegularExpressions.Regex]::IsMatch([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1)), $pattern) -and ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1)) -eq [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2)))) {
 
        #Sets the user values to a single variable for easier collection later
        ##Check these to confirm they meet your client requirements##
        $user = @{
                "firstName" = $FirstName
                "surname" = $LastName
                "preferredName" = "$FirstName $LastName"
                "email" = "$FirstName.$LastNameShort$Domain".ToLower()
                "username" = "$FirstName.$LastNameShort".ToLower()
                "password" = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1))
                }        
            Write-Host "The Password meets requirements, Proceeding to next step"
            $passwordValid = $True    
    else{
                Write-Host "The password does not meet the requirements or do not match. Please try again."
            }}

} While (-not $passwordValid)
Write-Host "`n`n  User Details to be added to $platform" -ForegroundColor Yellow
Write-Output $user

Write-Host "`n    Press Ctrl+C to exit at any time" -ForegroundColor Green


Write-Host "`n  Review the above details thoroughly" -ForegroundColor Yellow

Start-Sleep -seconds 7

   $Confirmation2 = Read-Host -Prompt "`n  Are they correct? (y/n)"
        }
        while ($Confirmation2 -ne "y")

#Everything below this line should be user creation steps

# SwapthiswithCreateUserCommand -firstname $user.firstName -lastname $user.surname -displayname $user.preferredName -email $user.email -password $user.password