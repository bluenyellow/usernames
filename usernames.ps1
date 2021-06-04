
<#
Important an need to change parts of code:

uzivatelia.csv file is input and output file used to store information about users and hostnames. This csv file is created at first run of this script and will be rewritten on at each run of this script.
You can choose the path of this csv file.

Brief explanation of this script:
Its have two parts : 
1. First run: Load all computers from domain , check users logged on them(RDP or locally),and create csv file where every hostname have assigned user

2. Other runs: Load uzivatelia.csv created at last run, compare hostnames from csv and newly loaded hostnames from domain. User check is performed on updated hostnames and old csv file is overwritten by new.

If user value is null , the username cell will not be updated, so only the not null values is written to csv files, which prevent overwriting real usernames with empty values.


Example usage: Put the script in Task scheduler, run it occasionaly it give you updated information about who use the particular computer. 

#>




$cesta="C:\path\to\csv\uzivatelia.csv"          #put here your own path


###################################FIRST RUN###############################################################

$testfile=Test-Path $cesta                                                       


if(!$testfile){
  $pcs= Get-ADComputer -Filter *                                    #load computers from domain


class Pcko                                                        #defining class for computer
{
    [string]$hostname
    [string]$user
  }

$allpc=[System.Collections.ArrayList]@()

foreach($pc in $pcs){                                     #load computers to array

       $pc = [Pcko]@{
           hostname = $pc.Name
           user = ""

    }
    $allpc=$allpc+$pc                                   #update array
    }
    



$wusers=[System.Collections.ArrayList]@()
    
foreach($onepc in $allpc){


$isup=Test-Connection -Count 1 $onepc.hostname -Quiet
        
        if($isup){                                            #if computer is online, do operations below
            $pcq=$onepc.hostname
            $parseuser= qwinsta /SERVER:$pcq
            $usr= $parseuser -replace '\s{2,}', ',' | ConvertFrom-CSV -Header 'UserName', 'Session', 'ID', 'State', 'IdleTime', 'LogonTime' | Where-Object {($_.State -eq "Active")  -and ($_.Session -ne " ")} | Select-Object -ExpandProperty Session
            
            $onepc = [Pcko]@{
            hostname = $pcq 
            user = $usr
                }

          $wusers=$wusers+$onepc        #add finded users to array
          
    }

        else{
              $onepc = [Pcko]@{
              hostname = $onepc.hostname
              user = ""
                }

          $wusers=$wusers+$onepc
     }

       }

$wusers | Export-Csv -Path $cesta -NoTypeInformation

}

#######################SECOND RUN####################################################

else{

$komps = Import-Csv -Path $cesta          #Loading computer names and users from csv
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
  
  #from here it is comparing computers previously loaded in csv and current computers from domain

$comparing=Compare-Object -ReferenceObject $pc_users.hostname -DifferenceObject $pc_users2.hostname           #comparing hostnames



$addtoquery=$comparing | Where-Object {$_.SideIndicator -match "=>"}         #add all missing computers



foreach($item in $addtoquery){
    $item = [Pcko]@{
          hostname = $item.InputObject
          user = ""
  
  }
    $pc_users=$pc_users+$item               
} 

#deleting computers wchich was deleted from domain

$delcompare= Compare-Object -ReferenceObject $pc_users2.hostname -DifferenceObject $pc_users.hostname
$delfromquery=$delcompare | Where-Object {$_.SideIndicator -match "=>"}

foreach($item in $delfromquery){
  $pc_users=$pc_users | Where-Object {$_.hostname -ne $item.inputobject}
}





$pcaktualne=$pc_users | Sort-Object -Property hostname       #sort array by hostnames
 


$wusers=[System.Collections.ArrayList]@()            

$allpc=$pcaktualne


#checking users 


foreach($onepc in $allpc){
   
      $isup=Test-Connection -Count 1 $onepc.hostname -Quiet
        
      if($isup){
        $pcq=$onepc.hostname
        $parseuser= qwinsta /SERVER:$pcq
        $usr= $parseuser -replace '\s{2,}', ',' | ConvertFrom-CSV -Header 'UserName', 'Session', 'ID', 'State', 'IdleTime', 'LogonTime' | Where-Object {($_.State -eq "Active")  -and ($_.Session -ne " ")} | Select-Object -ExpandProperty Session
          
          $onepc = [Pcko]@{
                 hostname = $pcq #$onepc.hostname
                 user = $usr
                }

          $wusers=$wusers+$onepc
           
    }
  }

#compare users  

foreach($hostname in $wusers.hostname){
  
	if ($allpc.hostname -contains $hostname){

		$pozicia=$wusers.hostname.IndexOf($hostname)      #position of hostname in array
		 $juser	=$wusers[$pozicia].user                   #user on that hostname position
    
     if($juser){                                      #if user is not empty....
		 $sh=$allpc.hostname.indexOf($hostname)
     $allpc[$sh].user=$juser
     }
  }
  
}
     
$allpc | Export-Csv -Path $cesta -NoTypeInformation
     
     
     
}     
     
     

