Foreach ($Server in (Get-Content C:\temp\Output1\Online.txt))
{


        #to find local groups
        $Computer = $Server
        $Computer = [ADSI]"WinNT://$Computer"
        $Localgroups=($Computer.psbase.Children | Where {$_.psbase.schemaClassName -eq "group"}).name
                        
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