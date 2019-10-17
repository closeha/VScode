# Enter Server and save as variable
$Server= Read-Host "Please Enter the Server"
# Get Wmi for those variables, choose start mode of auto and display in grid
Get-WmiObject Win32_Service -ComputerName $Server | Where-Object { $_.StartMode -like 'Auto' }| Select-Object __SERVER, Name, DisplayName, StartMode, State |Sort-Object State -desc| Format-Table -auto
Get-WmiObject Win32_Service -ComputerName $Server | Where-Object { $_.DisplayName -like '*SQL*' }| Select-Object __SERVER, Name, DisplayName, StartMode, State | Format-Table -auto
Get-WmiObject Win32_Service -ComputerName $Server | Where-Object { $_.StartMode -like 'Auto' -AND $_.State -notlike 'Running'}| Select-Object __SERVER, Name, DisplayName, StartMode, State |Sort-Object State -desc| Format-Table -auto
#To run these against multiple servers. Create a SQLServers.txt file with a server on each line then run
$SQLServerTXT = "Path to SQLServers.TXT File"
$Servers = Get-Content $SQLServersTXT foreach($Server in $Servers) 
    { Put code in here and use the $Server variable ie get-service -ComputerName $server|Where-Object { $_.Name -like '*SQL*' } } 