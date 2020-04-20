$komps = Import-Csv -Path 'C:\Users\Alex Adamica\Desktop\pc.csv'
$komps2= Import-Csv -Path 'C:\Users\Alex Adamica\Desktop\pc2.csv'

class Pcko
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$hostname
    [ValidateNotNullOrEmpty()][string]$user
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


  $comparing=Compare-Object -ReferenceObject $pc_users.user -DifferenceObject $pc_users2.user

 $comparing.InputObject


  
  # $pc_users2