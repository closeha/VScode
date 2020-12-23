function Show-Menu
{
     param (
           [string]$Title = 'SQL Server Service Stop\Start Script'
     )
     Clear-Host
     Write-Host "================ $Title - $Server ================"
    
     Write-Host "1: Press '1' to stop SQL services."
     Write-Host "2: Press '2' to start SQL services."
     Write-Host "3: Press '3' to view what SQL services will be stopped\started."
     Write-Host "4: Press '4' to Change all SQL Services StartupType to Disabled."
     Write-Host "5: Press '5' to Change all SQL Services StartupType to Automatic."
     Write-Host "Q: Press 'Q' to quit."
}

$Server = Read-Host -Prompt 'Input your SQL server name'


$Services = Get-service -ComputerName $Server *SQL* | Where-Object {$_.status -eq   "Running"} 

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                Clear-Host
                'The services are being stopped.'
                Get-service -ComputerName $Server *SQL* | Where-Object {$_.status -eq   "Running"}
                Foreach ($Service in $Services)
                    {
                        Get-Service -ComputerName $Server -name $Service | Stop-Service -PassThru -Force | Set-Service -StartupType disabled
                    }
                
                Get-Service -ComputerName $Server -name MsDtsServer120 | Stop-Service -PassThru -Force | Set-Service -StartupType disabled
                Get-Service -ComputerName $Server -name ReportServer | Stop-Service -PassThru -Force | Set-Service -StartupType disabled
                

           } '2' {
                Clear-Host
                'The services are being started.'
                Get-service -ComputerName $Server *SQL* | Where-Object {$_.status -eq   "Stopped"}

                Foreach ($Service in $Services)
                    {
                        Get-Service -ComputerName $Server -name $Service | Start-Service -PassThru -Force | Set-Service -StartupType Automatic
                    }

                Get-Service -ComputerName $Server -name MSSQLFDLauncher | Set-Service -StartupType manual
                Get-Service -ComputerName $Server -name MsDtsServer120 | Start-Service -PassThru -Force | Set-Service -StartupType automatic
                Get-Service -ComputerName $Server -name ReportServer | Start-Service -PassThru -Force | Set-Service -StartupType automatic
                
                   
           } '3' {
                Clear-Host
                Get-service -ComputerName $Server *SQL* | Where-Object {$_.status -eq   "Running"}
                
                Get-service -ComputerName $Server MsDtsServer120 | Select-Object Name,Status,Starttype,Displayname
                Get-service -ComputerName $Server ReportServer | Select-Object Name,Status,Starttype,Displayname

           } '4' {
                Clear-Host
                'The Startuptypes are being changed.'
                                
                Foreach ($Service in $Services)
                    {
                        Get-Service -ComputerName $Server -name $Service | Set-Service -StartupType disabled
                    }
                Get-Service -ComputerName $Server -name MsDtsServer120 | Set-Service -StartupType disabled
                Get-Service -ComputerName $Server -name ReportServer | Set-Service -StartupType disabled
                
                   
           } '5' {
                Clear-Host
                'The StartupTypes are being changed.'

                Foreach ($Service in $Services)
                    {
                        Get-Service -ComputerName $Server -name $Service | Set-Service -StartupType automatic
                    }
                Get-Service -ComputerName $Server -name MSSQLFDLauncher | Set-Service -StartupType manual
                Get-Service -ComputerName $Server -name MsDtsServer120 | Set-Service -StartupType automatic
                Get-Service -ComputerName $Server -name ReportServer | Set-Service -StartupType automatic
                
                   
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')

