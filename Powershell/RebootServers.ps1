$YourFile = Get-Content 'C:\Temp\Powershell\RebootServers.txt'

foreach ($computer in $YourFile)
{

Restart-Computer -ComputerName $computer -force

}