#$ComputerName = (Get-Content C:\temp\powershell\servers.txt)
$SearchLog = New-Item "c:\temp\Output1\ErrorLog.txt" -type file -ErrorAction Inquire
$SearchLog1 = New-Item "c:\temp\Output1\Online.txt" -type file -ErrorAction Inquire
$SearchLog2 = New-Item "c:\temp\Output1\NotOnline.txt" -type file -ErrorAction Inquire

Foreach ($Computer in (Get-Content C:\temp\powershell\servers.txt))
{
    #Ping Test. If PC is shut off, script will stop for the current PC in pipeline and move to the next one.
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
    {
        Add-Content -Path $SearchLog1 -Value $Computer
    } else {
        Add-Content -Path $SearchLog2 -Value "$(Get-Date -Format dd-MM-yy-hh_mm_ss) $Computer is not Online:"
    }
} # bottom of foreach loop

 ForEach ($ThisServer in (Get-Content C:\Temp\Output1\Online.txt))
  {       

  New-Item -ItemType directory -Path C:\Temp\Output1\$ThisServer
  

  Try{

  Get-WmiObject -Class Win32_Service -ComputerName $ThisServer | Select-Object DisplayName, StartName, State, StartMode | Sort-Object DisplayName,State | Export-csv C:\Temp\Output1\$ThisServer\$ThisServer"_Services.csv" -NoTypeInformation -ErrorAction SilentlyContinue
       }
  Catch{
       Add-Content -Path $SearchLog -Value "$(Get-Date -Format dd-MM-yy-hh_mm_ss) $ThisServer had an issue: $_.Exception.Message`n"     
       } 
 }