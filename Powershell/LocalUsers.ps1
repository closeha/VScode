$computers = get-content "C:\Temp\Powershell\Servers.txt"
$computers | ForEach-Object {
$computername = $_
[ADSI]$S = "WinNT://$computername"
$S.children.where({$_.class -eq 'group'}) |
Select-Object @{Name="Computername";Expression={$_.Parent.split("/")[-1] }},
@{Name="Name";Expression={$_.name.value}},
@{Name="Members";Expression={
[ADSI]$group = "$($_.Parent)/$($_.Name),group"
$members = $Group.psbase.Invoke("Members")
($members | ForEach-Object {
$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
}) -join ";"
}}
} | Export-CSV -path c:\work\localaudit.csv –notypeinformation