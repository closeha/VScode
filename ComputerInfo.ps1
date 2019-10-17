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
        $PSBoundParameters.GetEnumerator() | ForEach {
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
 
        $InputObject | ForEach {
            $Line = $_
            $stringBuilder = New-Object Text.StringBuilder
            $Null = $stringBuilder.AppendLine("[pscustomobject] @{")

            $OutputOrder | ForEach {
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