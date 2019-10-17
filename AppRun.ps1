Foreach ($ServerApp in (Get-Content C:\Temp\Output1\Online.txt))
{
    

Get-WmiObject -Class Win32_Product -ComputerName $ServerApp | Select-Object Name,Vendor,Version,Caption | Sort-Object Name | Export-Csv c:\temp\Output1\$ServerApp\$ServerApp"_Applications.csv" -NoTypeInformation
       
}