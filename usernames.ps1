#Variable $testfile checks if u 

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
        
            $usr=Get-WmiObject Win32_Desktop -ComputerName $onepc.hostname | Where-Object {$_.Name -notmatch 'mikusek'} | Where-Object {$_.Name -notmatch 'hudacin'} | Where-Object {$_.Name -notmatch 'selicky'} | Where-Object {$_.Name -notmatch 'zilavy'} | Where-Object {$_.Name -notmatch 'vanco'} |  Where-Object {$_.Name -notmatch 'NT AUTHORITY'} | Where-Object {$_.Name -notmatch '.DEFAULT'} | Where-Object {$_.Name -notmatch 'frcka'} |  Where-Object {$_.Name -notmatch 'kocurik'} |  Where-Object {$_.Name -notmatch 'haburaj'} |  Where-Object {$_.Name -notmatch 'otcenas'} |  Where-Object {$_.Name -notmatch 'dcadmin'} | Where-Object {$_.Name -notmatch 'adamica'} | Where-Object {$_.Name -notmatch 'teleky'} | Where-Object {$_.Name -notmatch 'Administrator'} | Where-Object {$_.Name -notmatch 'siket'} | Select-Object -ExpandProperty Name
            $onepc = [Pcko]@{
            hostname = $onepc.hostname
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


#class Pcko
#{
 # [string]$hostname
  #[string]$user
  #}

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
$pcaktualne=$pc_users | Sort-Object -Property hostname    #POTIALTO JE TO FUNKCNE




$wusers=[System.Collections.ArrayList]@()            

$allpc=$pcaktualne


#od tejto casti sa zacina nacitavanie userov a ich porovnavanie


foreach($onepc in $allpc){
   
      $isup=Test-Connection -Count 1 $onepc.hostname -Quiet
        
      if($isup){
        
          $usr=Get-WmiObject Win32_Desktop -ComputerName $onepc.hostname | Where-Object {$_.Name -notmatch 'mikusek'} | Where-Object {$_.Name -notmatch 'hudacin'} | Where-Object {$_.Name -notmatch 'selicky'} | Where-Object {$_.Name -notmatch 'zilavy'} | Where-Object {$_.Name -notmatch 'vanco'} | Where-Object {$_.Name -notmatch 'NT AUTHORITY'} | Where-Object {$_.Name -notmatch '.DEFAULT'} | Where-Object {$_.Name -notmatch 'frcka'} |  Where-Object {$_.Name -notmatch 'kocurik'} |  Where-Object {$_.Name -notmatch 'haburaj'} |  Where-Object {$_.Name -notmatch 'otcenas'} |  Where-Object {$_.Name -notmatch 'dcadmin'} | Where-object {$_.Name -notmatch 'adamica'} | Where-object {$_.Name -notmatch 'teleky'} | Where-Object {$_.Name -notmatch 'Administrator'} | Where-Object {$_.Name -notmatch 'siket'} | Select-Object -ExpandProperty Name
          $onepc = [Pcko]@{
                 hostname = $onepc.hostname
                 user = $usr
                }

          $wusers=$wusers+$onepc
           
    }
  }
      $wusers.user | ForEach-Object {
              
      if ($allpc.user -contains $_) {
          Write-Host "`$allpc contains the `$wusers string [$_]"
        } 
      
      else{Write-Host "`$allpc not contain the `$wusers string [$_]"
          $pozicia=$wusers.user.IndexOf($_)
          $hostnejm=$wusers[$pozicia].hostname

          $ph=$allpc.hostname.IndexOf($hostnejm)
          $allpc[$ph].user=$wusers[$pozicia].user
        }
}
     
     
$allpc | Export-Csv -Path C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv -NoTypeInformation
     
     
     
}     
     
     

