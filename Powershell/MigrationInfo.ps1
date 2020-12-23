$datenow = (get-date -f MM-dd-yyyy_HH_mm_ss)

if((Get-ChildItem c:\temp\Output1 -force | Select-Object -First 1 | Measure-Object).Count -eq 0)
{

New-Item -ItemType directory -Path C:\Temp\Output1

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

 Foreach ($ServerApp in (Get-Content C:\Temp\Output1\Online.txt))
{
    

Get-WmiObject -Class Win32_Product -ComputerName $ServerApp | Select-Object Name,Vendor,Version,Caption | Sort-Object Name | Export-Csv c:\temp\Output1\$ServerApp\$ServerApp"_Applications.csv" -NoTypeInformation
       
}

Function Convert-OutputForCSV {
    <#
        .SYNOPSIS
            Provides a way to expand collections in an object property prior
            to being sent to Export-Csv.

        .DESCRIPTION
            Provides a way to expand collections in an object property prior
            to being sent to Export-Csv. This helps to avoid the object type
            from being shown such as system.object[] in a spreadsheet.

        .PARAMETER InputObject
            The object that will be sent to Export-Csv

        .PARAMETER OutPropertyType
            This determines whether the property that has the collection will be
            shown in the CSV as a comma delimmited string or as a stacked string.

            Possible values:
            Stack
            Comma

            Default value is: Stack

        .NOTES
            Name: Convert-OutputForCSV
            Author: Boe Prox
            Created: 24 Jan 2014
            Version History:
                1.1 - 02 Feb 2014
                    -Removed OutputOrder parameter as it is no longer needed; inputobject order is now respected 
                    in the output object
                1.0 - 24 Jan 2014
                    -Initial Creation

        .EXAMPLE
            $Output = 'PSComputername','IPAddress','DNSServerSearchOrder'

            Get-WMIObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True'" |
            Select-Object $Output | Convert-OutputForCSV | 
            Export-Csv -NoTypeInformation -Path NIC.csv    
            
            Description
            -----------
            Using a predefined set of properties to display ($Output), data is collected from the 
            Win32_NetworkAdapterConfiguration class and then passed to the Convert-OutputForCSV
            funtion which expands any property with a collection so it can be read properly prior
            to being sent to Export-Csv. Properties that had a collection will be viewed as a stack
            in the spreadsheet.        
            
    #>
    #Requires -Version 3.0
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [parameter()]
        [ValidateSet('Stack','Comma')]
        [string]$OutputPropertyType = 'Stack'
    )
    Begin {
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            Write-Verbose "$($_)"
        }
        $FirstRun = $True
    }
    Process {
        If ($FirstRun) {
            $OutputOrder = $InputObject.psobject.properties.name
            Write-Verbose "Output Order:`n $($OutputOrder -join ', ' )"
            $FirstRun = $False
            #Get properties to process
            $Properties = Get-Member -InputObject $InputObject -MemberType *Property
            #Get properties that hold a collection
            $Properties_Collection = @(($Properties | Where-Object {
                $_.Definition -match "Collection|\[\]"
            }).Name)
            #Get properties that do not hold a collection
            $Properties_NoCollection = @(($Properties | Where-Object {
                $_.Definition -notmatch "Collection|\[\]"
            }).Name)
            Write-Verbose "Properties Found that have collections:`n $(($Properties_Collection) -join ', ')"
            Write-Verbose "Properties Found that have no collections:`n $(($Properties_NoCollection) -join ', ')"
        }
 
        $InputObject | ForEach-Object {
            $Line = $_
            $stringBuilder = New-Object Text.StringBuilder
            $Null = $stringBuilder.AppendLine("[pscustomobject] @{")

            $OutputOrder | ForEach-Object {
                If ($OutputPropertyType -eq 'Stack') {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$(($line.$($_) | Out-String).Trim())`"")
                } ElseIf ($OutputPropertyType -eq "Comma") {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$($line.$($_) -join ', ')`"")                   
                }
            }
            $Null = $stringBuilder.AppendLine("}")
 
            Invoke-Expression $stringBuilder.ToString()
        }
    }
    End {}
}


$ro=[System.Security.Cryptography.X509Certificates.OpenFlags]"ReadOnly"
$lm=[System.Security.Cryptography.X509Certificates.StoreLocation]"LocalMachine"

Foreach ($Server in (Get-Content C:\temp\output1\online.txt))
{
Get-WmiObject -computername $Server -class win32_operatingsystem | Select-Object PSComputerName,BuildNumber,BuildType,Caption,Description,InstallDate,LastBootupTime,OSArchitecture,SystemDrive,WindowsDirectory | Export-Csv C:\temp\Output1\$Server\$Server"_OperatingSystem.csv" -NoTypeInformation
Get-WmiObject -computername $Server -class Win32_logicaldisk | Select-Object -Property DeviceID, DriveType, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}}, @{L="CapacityGB";E={"{0:N2}" -f ($_.Size /1GB)}} | Export-Csv C:\temp\Output1\$Server\$Server"_Volumes.csv" -NoTypeInformation
Get-WmiObject -Class Win32_ComputerSystem -computer $Server | Select-Object DNSHostName,Domain,NumberOfLogicalProcessors,NumberOfProcessors, @{L='Physical MemoryGB';E={"{0:N2}" -f ($_.TotalPhysicalMemory /1GB)}} | Export-Csv C:\Temp\Output1\$Server\$Server"_Memory.csv" -NoTypeInformation
get-WmiObject -class Win32_Share -computer $Server | Select-Object Name,Path,Status,Description | Export-Csv C:\Temp\Output1\$Server\$Server"_Shares.csv" -NoTypeInformation
Get-WmiObject -class Win32_ServerFeature -ComputerName $Server | Select-Object Name | Sort-Object Name | Export-Csv C:\Temp\Output1\$Server\$Server"_WindowFeature.csv" -NoTypeInformation
$NetAdConfig = Get-WmiObject -ComputerName $Server Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null } 
$NetAdConfig | Select-Object IPAddress,MACAddress,DefaultIPGateway | Convert-OutputForCSV | Export-Csv C:\temp\Output1\$Server\$Server"_NetworkInfo.csv" -NoTypeInformation
$store=new-object System.Security.Cryptography.X509Certificates.X509Store("\\$Server\My",$lm)
$store.Open($ro)
$certificates=$store.Certificates
$certificates | Select-Object DnsNameList,EnhancedKeyUsageList,Thumbprint,Issuer,Subject | Export-Csv C:\Temp\Output1\$Server\$Server"_Certificates.csv" -NoTypeInformation
}

Foreach ($Server in (Get-Content C:\temp\Output1\Online.txt))
{


        #to find local groups
        $Computer = $Server
        $Computer = [ADSI]"WinNT://$Computer"
        $Localgroups=($Computer.psbase.Children | Where-Object {$_.psbase.schemaClassName -eq "group"}).name
                        
        #$Localgroups= (Get-WMIObject win32_group -filter "LocalAccount='True'" -ComputerName $Server).Name
        #$Localgroups.trimend()
        

        #for finding each Group members using foreach
        foreach ($groupname in $Localgroups ) {


        $group =[ADSI]"WinNT://$server/$groupname" 
    
        $members = @($group.psbase.Invoke("Members"))

         
         Foreach ($m in $members)

            {
                New-Object psobject -Property @{
                        
                        GroupName = $Groupname
                        ComputerName = $Server
                        Members = $m.GetType().InvokeMember("Name", 'GetProperty', $null, $m, $null)
                        

                 #Need to change Output file location.                               
                 } | Export-csv -NoTypeInformation -append -Path C:\temp\Output1\$Server\$Server"_All_LocalGroup_members.csv"
                    
            }
        
      }
     
     
 }
 } Else {

  
 ROBOCOPY C:\Temp\Output1 C:\Temp\$datenow /Move /E

 $TARGETDIR = "C:\Temp\Output1"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR

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

 Foreach ($ServerApp in (Get-Content C:\Temp\Output1\Online.txt))
{
    

Get-WmiObject -Class Win32_Product -ComputerName $ServerApp | Select-Object Name,Vendor,Version,Caption | Sort-Object Name | Export-Csv c:\temp\Output1\$ServerApp\$ServerApp"_Applications.csv" -NoTypeInformation
       
}

Function Convert-OutputForCSV {
    <#
        .SYNOPSIS
            Provides a way to expand collections in an object property prior
            to being sent to Export-Csv.

        .DESCRIPTION
            Provides a way to expand collections in an object property prior
            to being sent to Export-Csv. This helps to avoid the object type
            from being shown such as system.object[] in a spreadsheet.

        .PARAMETER InputObject
            The object that will be sent to Export-Csv

        .PARAMETER OutPropertyType
            This determines whether the property that has the collection will be
            shown in the CSV as a comma delimmited string or as a stacked string.

            Possible values:
            Stack
            Comma

            Default value is: Stack

        .NOTES
            Name: Convert-OutputForCSV
            Author: Boe Prox
            Created: 24 Jan 2014
            Version History:
                1.1 - 02 Feb 2014
                    -Removed OutputOrder parameter as it is no longer needed; inputobject order is now respected 
                    in the output object
                1.0 - 24 Jan 2014
                    -Initial Creation

        .EXAMPLE
            $Output = 'PSComputername','IPAddress','DNSServerSearchOrder'

            Get-WMIObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True'" |
            Select-Object $Output | Convert-OutputForCSV | 
            Export-Csv -NoTypeInformation -Path NIC.csv    
            
            Description
            -----------
            Using a predefined set of properties to display ($Output), data is collected from the 
            Win32_NetworkAdapterConfiguration class and then passed to the Convert-OutputForCSV
            funtion which expands any property with a collection so it can be read properly prior
            to being sent to Export-Csv. Properties that had a collection will be viewed as a stack
            in the spreadsheet.        
            
    #>
    #Requires -Version 3.0
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [parameter()]
        [ValidateSet('Stack','Comma')]
        [string]$OutputPropertyType = 'Stack'
    )
    Begin {
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            Write-Verbose "$($_)"
        }
        $FirstRun = $True
    }
    Process {
        If ($FirstRun) {
            $OutputOrder = $InputObject.psobject.properties.name
            Write-Verbose "Output Order:`n $($OutputOrder -join ', ' )"
            $FirstRun = $False
            #Get properties to process
            $Properties = Get-Member -InputObject $InputObject -MemberType *Property
            #Get properties that hold a collection
            $Properties_Collection = @(($Properties | Where-Object {
                $_.Definition -match "Collection|\[\]"
            }).Name)
            #Get properties that do not hold a collection
            $Properties_NoCollection = @(($Properties | Where-Object {
                $_.Definition -notmatch "Collection|\[\]"
            }).Name)
            Write-Verbose "Properties Found that have collections:`n $(($Properties_Collection) -join ', ')"
            Write-Verbose "Properties Found that have no collections:`n $(($Properties_NoCollection) -join ', ')"
        }
 
        $InputObject | ForEach-Object {
            $Line = $_
            $stringBuilder = New-Object Text.StringBuilder
            $Null = $stringBuilder.AppendLine("[pscustomobject] @{")

            $OutputOrder | ForEach-Object {
                If ($OutputPropertyType -eq 'Stack') {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$(($line.$($_) | Out-String).Trim())`"")
                } ElseIf ($OutputPropertyType -eq "Comma") {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$($line.$($_) -join ', ')`"")                   
                }
            }
            $Null = $stringBuilder.AppendLine("}")
 
            Invoke-Expression $stringBuilder.ToString()
        }
    }
    End {}
}


$ro=[System.Security.Cryptography.X509Certificates.OpenFlags]"ReadOnly"
$lm=[System.Security.Cryptography.X509Certificates.StoreLocation]"LocalMachine"

Foreach ($Server in (Get-Content C:\temp\output1\online.txt))
{
Get-WmiObject -computername $Server -class win32_operatingsystem | Select-Object PSComputerName,BuildNumber,BuildType,Caption,Description,InstallDate,LastBootupTime,OSArchitecture,SystemDrive,WindowsDirectory | Export-Csv C:\temp\Output1\$Server\$Server"_OperatingSystem.csv" -NoTypeInformation
Get-WmiObject -computername $Server -class Win32_logicaldisk | Select-Object -Property DeviceID, DriveType, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}}, @{L="CapacityGB";E={"{0:N2}" -f ($_.Size /1GB)}} | Export-Csv C:\temp\Output1\$Server\$Server"_Volumes.csv" -NoTypeInformation
Get-WmiObject -Class Win32_ComputerSystem -computer $Server | Select-Object DNSHostName,Domain,NumberOfLogicalProcessors,NumberOfProcessors, @{L='Physical MemoryGB';E={"{0:N2}" -f ($_.TotalPhysicalMemory /1GB)}} | Export-Csv C:\Temp\Output1\$Server\$Server"_Memory.csv" -NoTypeInformation
get-WmiObject -class Win32_Share -computer $Server | Select-Object Name,Path,Status,Description | Export-Csv C:\Temp\Output1\$Server\$Server"_Shares.csv" -NoTypeInformation
Get-WmiObject -class Win32_ServerFeature -ComputerName $Server | Select-Object Name | Sort-Object Name | Export-Csv C:\Temp\Output1\$Server\$Server"_WindowFeature.csv" -NoTypeInformation
$NetAdConfig = Get-WmiObject -ComputerName $Server Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null } 
$NetAdConfig | Select-Object IPAddress,MACAddress,DefaultIPGateway | Convert-OutputForCSV | Export-Csv C:\temp\Output1\$Server\$Server"_NetworkInfo.csv" -NoTypeInformation
$store=new-object System.Security.Cryptography.X509Certificates.X509Store("\\$Server\My",$lm)
$store.Open($ro)
$certificates=$store.Certificates
$certificates | Select-Object DnsNameList,EnhancedKeyUsageList,Thumbprint,Issuer,Subject | Export-Csv C:\Temp\Output1\$Server\$Server"_Certificates.csv" -NoTypeInformation
}

Foreach ($Server in (Get-Content C:\temp\Output1\Online.txt))
{


        #to find local groups
        $Computer = $Server
        $Computer = [ADSI]"WinNT://$Computer"
        $Localgroups=($Computer.psbase.Children | Where-Object {$_.psbase.schemaClassName -eq "group"}).name
                        
        #$Localgroups= (Get-WMIObject win32_group -filter "LocalAccount='True'" -ComputerName $Server).Name
        #$Localgroups.trimend()
        

        #for finding each Group members using foreach
        foreach ($groupname in $Localgroups ) {


        $group =[ADSI]"WinNT://$server/$groupname" 
    
        $members = @($group.psbase.Invoke("Members"))

         
         Foreach ($m in $members)

            {
                New-Object psobject -Property @{
                        
                        GroupName = $Groupname
                        ComputerName = $Server
                        Members = $m.GetType().InvokeMember("Name", 'GetProperty', $null, $m, $null)
                        

                 #Need to change Output file location.                               
                 } | Export-csv -NoTypeInformation -append -Path C:\temp\Output1\$Server\$Server"_All_LocalGroup_members.csv"
                    
            }
        
      }
     
     
 }

} 
}

$args = @()
$args += ("-Inputfile", "C:\Temp\Powershell\Servers.txt")
$args += ("-Trustee", "admds629")
$cmd = "C:\Temp\Powershell\Set-ADAccountasLocalAdministrator.ps1"

Invoke-Expression "$cmd $args"

$args1 = @()
$args1 += ("-Inputfile", "C:\Temp\Powershell\Servers.txt")
$args1 += ("-Trustee", "admhc868")
$cmd1 = "C:\Temp\Powershell\Set-ADAccountasLocalAdministrator.ps1"

Invoke-Expression "$cmd1 $args1"

$args2 = @()
$args2 += ("-Inputfile", "C:\Temp\Powershell\Servers.txt")
$args2 += ("-Trustee", "admks625")
$cmd2 = "C:\Temp\Powershell\Set-ADAccountasLocalAdministrator.ps1"

Invoke-Expression "$cmd2 $args2"

$args3 = @()
$args3 += ("-Inputfile", "C:\Temp\Powershell\Servers.txt")
$args3 += ("-Trustee", "Admrg604")
$cmd3 = "C:\Temp\Powershell\Set-ADAccountasLocalAdministrator.ps1"

Invoke-Expression "$cmd3 $args3"

$args4 = @()
$args4 += ("-Inputfile", "C:\Temp\Powershell\Servers.txt")
$args4 += ("-Trustee", "NEVADAGM\svc-gl-admtng")
$cmd4 = "C:\Temp\Powershell\Set-ADAccountasLocalAdministrator.ps1"

Invoke-Expression "$cmd4 $args4"


#Define variables
$computers11 = Get-Content C:\Temp\Powershell\Servers.txt
#$computers = Import-CSV C:\Computers.csv | select Computer
$username = "NevadaSrvAdm"
$password = "9HBm))A@--ra3eq"
$fullname = "NevadaGM Server Admin"
$local_security_group = "Administrators"
$description = "Local Admin Account for the JV Migration"
 
Foreach ($computer in $computers11) {
    $users = $null
    $comp = [ADSI]"WinNT://$computer"
 
    #Check if username exists   
    Try {
        $users = $comp.psbase.children | Select-Object -expand name
        if ($users -like $username) {
            Write-Host "$username already exists on $computer"
 
        } else {
            #Create the account
            $user = $comp.Create("User","$username")
            $user.SetPassword("$password")
            $user.Put("Description","$description")
            $user.Put("Fullname","$fullname")
            $user.SetInfo()         
              
            #Set password to never expire
            #And set user cannot change password
            $ADS_UF_DONT_EXPIRE_PASSWD = 0x10000 
            $ADS_UF_PASSWD_CANT_CHANGE = 0x40
            $user.userflags = $ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE
            $user.SetInfo()
 
            #Add the account to the local admins group
            $group = [ADSI]"WinNT://$computer/$local_security_group,group"
            $group.add("WinNT://$computer/$username")
 
                #Validate whether user account has been created or not
                $users = $comp.psbase.children | Select-Object -expand name
                if ($users -like $username) {
                    Write-Host "$username has been created on $computer"
                } else {
                    Write-Host "$username has not been created on $computer"
                }
               }
        }
 
     Catch {
           Write-Host "Error creating $username on $($computer.path):  $($Error[0].Exception.Message)"
           }
}