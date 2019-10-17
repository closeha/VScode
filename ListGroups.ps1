$GroupPath = Get-Content  C:\temp\powershell\Groups.txt

Foreach ($group in $GroupPath)
{
Get-ADGroupMember -Identity $group -Server 'newmont.net' -Recursive | Select Name | Export-csv C:\Temp\Groups\$group"_"$(Get-Date -Format dd-MM-yy-hh_mm_ss)".csv" -NoTypeInformation
}
