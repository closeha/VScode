function Get-ServiceLogonAccount {
[cmdletbinding()]            

param (
$ComputerName = $env:computername,
$LogonAccount
)            

    if($logonAccount) {
        Get-WmiObject -Class Win32_Service -ComputerName $ComputerName |`          
? { $_.StartName -match $LogonAccount } | select DisplayName, StartName, State, Starttype            

    } else {            

        Get-WmiObject -Class Win32_Service -ComputerName $ComputerName | `         
select DisplayName, StartName, State, Starttype
    }            

}