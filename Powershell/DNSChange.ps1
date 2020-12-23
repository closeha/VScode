$computer = get-content C:\Temp\Powershell\Servers.txt

ForEach($Srv in $computer) {
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $Srv |where{$_.IPEnabled -eq “TRUE”}
  Foreach($NIC in $NICs) {

$DNSServers = “10.140.2.250",”10.140.2.251"
 $NIC.SetDNSServerSearchOrder($DNSServers)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
}
}