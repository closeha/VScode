$computer = get-content C:\Temp\Powershell\TwinCreeksServers.txt
$ThisSite = "TwinCreeks"
New-Item -ItemType directory -Path C:\Temp\DNSChange\$ThisSite
$SearchLog = New-Item "c:\temp\DNSChange\$ThisSite\ErrorLog.txt" -type file -ErrorAction Inquire
$SearchLog1 = New-Item "c:\temp\DNSChange\$ThisSite\DNSSuccess.txt" -type file -ErrorAction Inquire

ForEach($Srv in $computer) {
Try{

  $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $Srv |where{$_.IPEnabled -eq “TRUE”}
       }
  Catch{
       Add-Content -Path $SearchLog -Value "$(Get-Date -Format dd-MM-yy-hh_mm_ss) $Srv had an issue with the DNS change: $_.Exception.Message`n"     
       } 
  Foreach($NIC in $NICs) {

$DNSServers = “10.143.149.250",”10.140.2.250"
 $NIC.SetDNSServerSearchOrder($DNSServers)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
}
Add-Content -Path $SearchLog1 -Value "$(Get-Date -Format dd-MM-yy-hh_mm_ss) $Srv successfully updated DNS:"
}