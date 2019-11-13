<#
.Synopsis
It will build sites for us.

.Description

This is a module for the creation of a new team site, with the current template, quotas, features and sharepoint groups and permissions. 

.Example:

New-FBDsite -Shortname (the short or abbraviated Name of the Site) -Site (The Title Of the Site) everything else is called in.

#> 
Function NEW-FBDSiteAUTO(){
    
    
    [CmdletBinding()]
    Param(
    [Parameter (mandatory=$true, Position = 0, Helpmessage="The Short name for the Site/abbreviation")]
    [String]$ShortName,
    [Parameter (mandatory=$true, Position = 1, Helpmessage="The Full name for the Site to be give as the Site title")]
    [String]$Site,
    [Parameter(mandatory=$False, Position = 2, Helpmessage="Do you require a new DB with this site")]
    [Switch]$FBDConTDB,
    [Parameter (mandatory=$False, Position = 3, Helpmessage="OwnerAlias Display Name")]
    [String]$Primary,
    [Parameter (mandatory=$False, Position = 4, Helpmessage="SecondaryOwnerAlias DisplayName")]
    [String]$Secondary,
    [Parameter (mandatory=$False, Position = 5, Helpmessage="SecondaryOwnerAlias DisplayName")]
    [String]$DefaultGrps
    )

    sleep 5
    $assignmentCollection = Start-SPAssignment;
    if ($FBDConTDB){
    FBDConTDB
    
    }
    If(!$primary){
    $PUSER=Get-SPManagedAccount|select username|?{$_.username -like "*Config*"}
    $primary=$PUSER.Username.Replace('Domainname\','')
    }
    Write-host "Primary User is going to be"$primary
    
    if (!$secondary){
    $secondary = $env:USERNAME
    Write-Host "Secondary Owner has been Set as you!"$Secondary
    }
    <#If(!$FBDConTDB)
        {
        Write-host "Would you want to create a DB (Default is No)" -ForegroundColor Yellow 
        $Readhost = Read-Host " ( y / n ) " 
        Switch ($ReadHost) 
            { 
             Y {Write-host "Yes, DB will be made" -ForegroundColor Green; FBDConTDB} 
             N {Write-Host "No, DB will not be Made" -ForegroundColor Green; $FBDConTDB=$false} 
             Default {Write-Host "Default, Skip DB Creation"; $FBDConTDB=$false} 
            }
    
        }#>
        Try{
             write-host "Getting Portal WebApp" -ForegroundColor Green
             $WEBAPP=Get-SPWebApplication |?{$_.Displayname -like "portal"} 
             $WA=$WEBAPP.DisplayName
             Write-Host $WA -ForegroundColor Yellow
             $URL=$WEBAPP.Url
             $Managedpath=Get-SPManagedPath -WebApplication $URL|?{$_.name -like "sites"}
             $path=$managedpath.Name
             $siteURL="$url$Path/$Shortname"
             New-SPSite -url $url$Path/$Shortname -Name "$site" -OwnerAlias "Domain\$primary" -SecondaryOwnerAlias "Domain\$secondary" -template "TeamSpaces#0" -QuotaTemplate Teams –AssignmentCollection $assignmentCollection;
             Write-host "Site built" -foregroundcolor Green
            sleep 5
            Write-Host "Creating Groups"
            DefaultGrps
            Stop-SPAssignment $assignmentCollection;
            }
        Catch{
                Write-host "An Error Occured, Below Will say where the Error occured" -BackgroundColor Red -ForegroundColor Green
                Write-Host $_.scriptStackTrace
                Write-Host $_.exception.message
             }
        Stop-SPAssignment $assignmentCollection;
        write-host "Clean up will begin, Ignore all 'Clear-Variable :' type errors" -ForegroundColor Green
        try{
        Clear-Variable data, WA, WEBAPP, Managedpath, path, primary, secondary, shortname , assignmentCollection, Assign
        }
        Catch {
        Write-host "An Error Occured, Below Will say where the Error occured" -BackgroundColor Red -ForegroundColor Green
            Write-Host $_.scriptStackTrace
            Write-Host $_.exception.message
                }
       
        }
    
    Function DefaultGrps(){
        $assign=Start-SPAssignment; 
        $WEB= Get-SPSite $siteURL -AssignmentCollection $assign
        $RootWeb=$WEB.rootweb
        $groupowner=$web.Owner.UserLogin
        $RootWeb.CreateDefaultAssociatedGroups($GroupOwner, "", $RootWeb.title)
        sleep 5
        Enable-SPFeature -Identity da329259-c931-423f-b149-2396bc13a2de -URL $siteURL
        new-spuser 'Domain\Groupaccount' -Web $web.url -SiteCollectionAdmin -AssignmentCollection $assign
        Stop-SPAssignment $assign;                   } 
                                         
    Function FBDConTDB(){
    $data=Get-SPDatabase|select server|?{$_.Server -like "spData"}|select -First 1
    $REdata=$data.Server
    Write-host "This is the SQL instance the new Database will be added to:" $REdata  -ForegroundColor Yellow
    Write-host "Please Confirm the above is correct, If incorrect Press CRTL C" -foregroundcolor RED
    pause
    write-host "Getting Portal WebApp" -ForegroundColor Green
    $WEBAPP=Get-SPWebApplication |?{$_.Displayname -like "portal"} 
    $WA=$WEBAPP.DisplayName
    $URL=$WEBAPP.Url
    Write-Host $WEBAPP -ForegroundColor Yellow
    Write-Host "Is this Correct" -ForegroundColor Red
    Pause
    Write-host "new DB Name will be 'BS_PROD_Portal_$ShortName'" -ForegroundColor DarkGreen
        Try{
        
        New-SPContentDatabase “BS_PROD_Portal_$ShortName" -DatabaseServer $REdata -WebApplication $WA  –AssignmentCollection $assignmentCollection 
        write-host "content Built" -foregroundcolor Green
        }
            Catch{
            Write-host "An Error Occured, Below Will say where the Error occured" -BackgroundColor Red -ForegroundColor Green
            Write-Host $_.scriptStackTrace
            Write-Host $_.exception.message
            
            }
    Sleep 5
    }
    