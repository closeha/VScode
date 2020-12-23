$ServersFile = "C:\Temp\Output1\Online.txt"
$ResultFile = "C:\Temp\RFReport.CSV"
$STR = "Server Name, Role/Feature Installed"
Add-Content $STR $ResultFile
ForEach ($ThisServer in Get-Content $ServersFile)
{
$AllRF = Get-WindowsFeature -ComputerName $ThisServer | Where-Object {$_.Installed -match $True} | Select-Object Property Name
ForEach ($ThisItem in $AllRF)
{
$InstalledItem = $ThisItem.Name
$STR = $ThisServer+","+$InstalledItem
Add-Content $ResultFile $STR
}
}