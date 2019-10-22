# Import-CSV -Path "C:\Users\10026629\Documents\JulesServerList.csv"
$SearchLog = New-Item "c:\temp\Output1\JulesErrorLog.txt" -type file -ErrorAction Inquire
ForEach ($ThisServer in (Import-Csv "C:\Users\10026629\Documents\JulesServerList.csv"))
 {
Try{

 $com1 = Get-ADComputer -Identity ($_.serverlist) -Properties name,description | Select-Object name,description
       }
  Catch{
       Add-Content -Path $SearchLog -Value "$(Get-Date -Format dd-MM-yy-hh_mm_ss) $ThisServer had an issue: $_.Exception.Message`n"     
       } 
 }

 Write-Host $com1