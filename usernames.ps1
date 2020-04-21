$komps = Import-Csv -Path 'C:\Users\Alex Adamica\Desktop\pc.csv'
$komps2= Import-Csv -Path 'C:\Users\Alex Adamica\Desktop\pc2.csv'

class Pcko
{
    [ValidateNotNullOrEmpty()][string]$hostname
    [string]$user
  }

  $pc_users = [System.Collections.ArrayList]@()
  $pc_users2 = [System.Collections.ArrayList]@()

foreach($komp in $komps){

    $komp = [Pcko]@{
            hostname = $komp.PC
            user = $komp.username

    }
    $pc_users=$pc_users+$komp
    
  }
foreach($komp2 in $komps2){
    $komp2 = [Pcko]@{
        hostname = $komp2.PC
        user = $komp2.username

    }
    $pc_users2=$pc_users2+$komp2
  }
  
  
$comparing=Compare-Object -ReferenceObject $pc_users.hostname -DifferenceObject $pc_users2.hostname


$addtoquery=$comparing | Where-Object {$_.SideIndicator -match "=>"} | Select-Object -ExpandProperty InputObject

foreach($item in $addtoquery){
  $komp3 = [Pcko]@{
    hostname = $item
    user = ""
  
  }
  $pc_users=$pc_users+$komp3
} 
$pc_users.hostname


#od tejto casti sa zacina nacitavanie userov a ich porovnavanie
