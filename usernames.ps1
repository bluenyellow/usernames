$komps = Import-Csv -Path 'C:\Users\Alex Adamica\Desktop\pc.csv'

class Pcko
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$hostname
    [ValidateNotNullOrEmpty()][string]$user
  }

  $testArray = [System.Collections.ArrayList]@()

foreach($komp in $komps){

    $komp = [Pcko]@{
            hostname = $komp.PC
            user = $komp.username

    }
    $testArray=$testArray+$komp
    
}
$testArray
