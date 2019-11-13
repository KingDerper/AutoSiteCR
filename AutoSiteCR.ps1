<#
.Synopsis
THis builds sites and fretches data From a SP list.

.Description

This Module uses a some other modules to build SP site Collections. 

.Example:

AutoSiteCR, this will call in  NEW-FBDSiteAUTO So see that for details

#> 
Function AutoSiteCR{
if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null) {
 Add-PSSnapin Microsoft.SharePoint.PowerShell;
}
$NewSiteURL = "https://Portal.Domain.com"
$sourceWebURL = "Targetsite"
$sourceListName = "NewRequests"

$spSourceWeb = Get-SPWeb $sourceWebURL
$spSourceList = $spSourceWeb.Lists[$sourceListName]
$spSourceItems = $spSourceList.Items | where {$_['Request Status'] -eq "Approved - Awaiting site creation"}
$list = $spSourceWeb.Lists[$sourceListName]
$spSourceItems | ForEach-Object {
 $Title = $_['Please provide the title for your SharePoint Team Space:']
 $url = $_['Does your team have an abreviated name or acronym? If so, please provide this:']
 $USERS= $_['Please provide the names of the Business Owners for your SharePoint Space:']
 Write-Host "Create site: $TITLE"
 NEW-FBDSiteAUTO -ShortName $url -Site $title  #–url $url -name $Title -template teamspaces#0 
 $_['Request Status'] = "Site Created - Request completed"
 #$_['URL'] = $url + ", " + $Title 
         foreach($user in $USERS)
           {
               Try{
                 #Get the Group and User
                   $grp=get-spsite -Limit all |?{$_.url -like "*$URL*"}
                    $group=$grp.rootweb.SiteGroups|?{$_ -like "*OWNER*"}
                    $group.AddUser($user.User)
                    #Add user to Group
    
                    Write-Host "$($User) Added to $group Successfully!" -ForegroundColor Green
                 }
            Catch{
                Write-Host "there was an error!"
                $Error
                  }
        }
 $_.Update()
}
}