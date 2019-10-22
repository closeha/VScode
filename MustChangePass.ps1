Foreach ($User in (Get-Content C:\temp\powershell\Users.txt))
{
Get–aduser $User | set-aduser –changepasswordatlogon $false
}

Write-Host