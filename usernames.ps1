$komps = Import-Csv -Path 'C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv'
$komps2= Get-ADComputer -Filter *  #|  Where{$_.Name -match "traffic-0"} 


class Pcko
{
    [string]$hostname
    [string]$user
  }

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
#$addtoquery.InputObject

#pridanie hostnamov do array
foreach($item in $addtoquery){
  $item = [Pcko]@{
    hostname = $item.InputObject
    user = ""
  
  }
  $pc_users=$pc_users+$item
} 
$pcaktualne=$pc_users | Sort -Property hostname    #POTIALTO JE TO FUNKCNE




$wusers=[System.Collections.ArrayList]@()            
#$test=$pcaktualne #.hostname
#$uz=$test

$uz=$pcaktualne


#od tejto casti sa zacina nacitavanie userov a ich porovnavanie


foreach($t in $uz){
   
                 

        $isup=Test-Connection -Count 1 $t.hostname -Quiet
        
        if($isup){
        
        $usr=gwmi Win32_Desktop -ComputerName $t.hostname | Where {$_.Name -notmatch 'vanco'} |  Where {$_.Name -notmatch 'NT AUTHORITY'} | Where {$_.Name -notmatch '.DEFAULT'} | Where {$_.Name -notmatch 'frcka'} |  Where {$_.Name -notmatch 'kocurik'} |  Where {$_.Name -notmatch 'haburaj'} |  Where {$_.Name -notmatch 'otcenas'} |  Where {$_.Name -notmatch 'dcadmin'} | Where {$_.Name -notmatch 'adamica'} | Where {$_.Name -notmatch 'teleky'} | Where {$_.Name -notmatch 'Administrator'} | Where {$_.Name -notmatch 'siket'} | Select -ExpandProperty Name
        $t = [Pcko]@{
                hostname = $t.hostname
                user = $usr
                }

          $wusers=$wusers+$t
           #$uz=$uz+$t
    }
  }
     $wusers.user | ForEach-Object {
              
            if ($uz.user -contains $_) {
                Write-Host "`$uz contains the `$wusers string [$_]"
        } 
            else{Write-Host "`$uz not contain the `$wusers string [$_]"
                 $pozicia=$wusers.user.IndexOf($_)
                 $hostnejm=$wusers[$pozicia].hostname

                 $ph=$uz.hostname.IndexOf($hostnejm)
                 $uz[$ph].user=$wusers[$pozicia].user
        }
}
     
     
     $uz | Export-Csv -Path C:\Users\adamica.JOJ\Desktop\users\uzivatelia.csv -NoTypeInformation
     
