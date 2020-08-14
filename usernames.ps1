$testfile=Test-Path C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv

if(!$testfile){
  $pcs= Get-ADComputer -Filter * 


class Pcko
{
    [string]$hostname
    [string]$user
  }

$allpc=[System.Collections.ArrayList]@()

foreach($pc in $pcs){

       $pc = [Pcko]@{
           hostname = $pc.Name
           user = ""

    }
    $allpc=$allpc+$pc
    }
    



$wusers=[System.Collections.ArrayList]@()
    
foreach($onepc in $allpc){


$isup=Test-Connection -Count 1 $onepc.hostname -Quiet
        
        if($isup){
            $pcq=$onepc.hostname
            $parseuser= qwinsta /SERVER:$pcq
            $usr= $parseuser -replace '\s{2,}', ',' | ConvertFrom-CSV -Header 'UserName', 'Session', 'ID', 'State', 'IdleTime', 'LogonTime' | Where-Object {($_.State -eq "Active")  -and ($_.Session -ne " ")} | Select-Object -ExpandProperty Session
            #$usr=Get-WmiObject Win32_ComputerSystem -ComputerName $onepc.hostname | Where-Object {$_.username -notmatch 'mikusek'} | Where-Object {$_.username -notmatch 'hudacin'} | Where-Object {$_.username -notmatch 'selicky'} | Where-Object {$_.username -notmatch 'zilavy'} | Where-Object {$_.username -notmatch 'vanco'} |  Where-Object {$_.username -notmatch 'NT AUTHORITY'} | Where-Object {$_.username -notmatch '.DEFAULT'} | Where-Object {$_.username -notmatch 'frcka'} |  Where-Object {$_.username -notmatch 'kocurik'} |  Where-Object {$_.username -notmatch 'haburaj'} |  Where-Object {$_.username -notmatch 'otcenas'} |  Where-Object {$_.username -notmatch 'dcadmin'} | Where-Object {$_.username -notmatch 'adamica'} | Where-Object {$_.username -notmatch 'teleky'} | Where-Object {$_.username -notmatch 'Administrator'} | Where-Object {$_.username -notmatch 'siket'} | Select-Object -ExpandProperty username
            $onepc = [Pcko]@{
            hostname = $pcq #$onepc.hostname
            user = $usr
                }

          $wusers=$wusers+$onepc
          
    }

        else{
              $onepc = [Pcko]@{
              hostname = $onepc.hostname
              user = ""
                }

          $wusers=$wusers+$onepc
     }

       }

$wusers | Export-Csv -Path C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv -NoTypeInformation

}

##############################################PART2######################

else{
  
#Loading computer names and users from csv

$komps = Import-Csv -Path 'C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv'
$komps2= Get-ADComputer -Filter *   




$pc_users = [System.Collections.ArrayList]@()
$pc_users2 = [System.Collections.ArrayList]@()

foreach($komp in $komps){

    $komp = [Pcko]@{
          hostname = $komp.hostname
          user = $komp.user

    }
    $pc_users=$pc_users+$komp
    
  }
foreach($komp2 in $komps2){
    $komp2 = [Pcko]@{
           hostname = $komp2.Name
           user = ""

    }
    $pc_users2=$pc_users2+$komp2
  }
  

$comparing=Compare-Object -ReferenceObject $pc_users.hostname -DifferenceObject $pc_users2.hostname



$addtoquery=$comparing | Where-Object {$_.SideIndicator -match "=>"} 


#pridanie hostnamov do array
foreach($item in $addtoquery){
    $item = [Pcko]@{
          hostname = $item.InputObject
          user = ""
  
  }
    $pc_users=$pc_users+$item
} 

#tu potrebujem pridat este opacne porovnavanie aby to mazalo kompy ktore sa uz v domene nenachadzaju

$delcompare= Compare-Object -ReferenceObject $pc_users2.hostname -DifferenceObject $pc_users.hostname
$delfromquery=$delcompare | Where-Object {$_.SideIndicator -match "=>"}

foreach($item in $delfromquery){
  $pc_users=$pc_users | Where-Object {$_.hostname -ne $item.inputobject}
}

########################################################



$pcaktualne=$pc_users | Sort-Object -Property hostname    
 


$wusers=[System.Collections.ArrayList]@()            

$allpc=$pcaktualne


#od tejto casti sa zacina nacitavanie userov a ich porovnavanie


foreach($onepc in $allpc){
   
      $isup=Test-Connection -Count 1 $onepc.hostname -Quiet
        
      if($isup){
        $pcq=$onepc.hostname
        $parseuser= qwinsta /SERVER:$pcq
        $usr= $parseuser -replace '\s{2,}', ',' | ConvertFrom-CSV -Header 'UserName', 'Session', 'ID', 'State', 'IdleTime', 'LogonTime' | Where-Object {($_.State -eq "Active")  -and ($_.Session -ne " ")} | Select-Object -ExpandProperty Session
          #$usr=Get-WmiObject Win32_ComputerSystem -ComputerName $onepc.hostname | Where-Object {$_.username -notmatch 'mikusek'} | Where-Object {$_.username -notmatch 'hudacin'} | Where-Object {$_.username -notmatch 'selicky'} | Where-Object {$_.username -notmatch 'zilavy'} | Where-Object {$_.username -notmatch 'vanco'} |  Where-Object {$_.username -notmatch 'NT AUTHORITY'} | Where-Object {$_.username -notmatch '.DEFAULT'} | Where-Object {$_.username -notmatch 'frcka'} |  Where-Object {$_.username -notmatch 'kocurik'} |  Where-Object {$_.username -notmatch 'haburaj'} |  Where-Object {$_.username -notmatch 'otcenas'} |  Where-Object {$_.username -notmatch 'dcadmin'} | Where-Object {$_.username -notmatch 'adamica'} | Where-Object {$_.username -notmatch 'teleky'} | Where-Object {$_.username -notmatch 'Administrator'} | Where-Object {$_.username -notmatch 'siket'} | Select-Object -ExpandProperty username
          $onepc = [Pcko]@{
                 hostname = $pcq #$onepc.hostname
                 user = $usr
                }

          $wusers=$wusers+$onepc
           
    }
  }

<#
      $wusers.user | ForEach-Object {
              
          if ($allpc.user -contains $_) {                                      #tu zistujem ci sa username z $wusers nachadza v $allpc
              Write-Host "`$allpc contains the `$wusers string [$_]"
        } 
      
          else{Write-Host "`$allpc not contain the `$wusers string [$_]"
              $pozicia=$wusers.user.IndexOf($_)
              $hostnejm=$wusers[$pozicia].hostname

              $ph=$allpc.hostname.IndexOf($hostnejm)
              $allpc[$ph].user=$wusers[$pozicia].user
        }
}#>
     

foreach($hostname in $wusers.hostname){
  
	if ($allpc.hostname -contains $hostname){

		$pozicia=$wusers.hostname.IndexOf($hostname)
		 $juser	=$wusers[$pozicia].user
    
     if($juser){
		 $sh=$allpc.hostname.indexOf($hostname)
     $allpc[$sh].user=$juser
     }
  }
  
}
     
$allpc | Export-Csv -Path C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv -NoTypeInformation
     
     
     
}     
     
     

