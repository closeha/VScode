
$Name = Read-Host -Prompt 'What is your Username:'
$User = Get-ADUser -Filter {sAMAccountName -eq $Name}
If ($User -eq $Null) {"User does not exist in AD"}
Else {"User found in AD"}