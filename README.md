# AutoSiteCr
This Auto builds sharepoint 2016 sites be looking at a SharePoint list. Can be completely hands off if you use task scheduler and save it as a module
First of ensure that all the correct infomation is in place in the modules before trying to run. This can and does use a sharepoint list as its base to look up and pull the correct info to build the sites requested. 

there are lines in the module that you can remove if you don't need (like the guid for a feature)

New-FBDSiteAuto.psm line 102    Enable-SPFeature -Identity da329259-c931-423f-b149-2396bc13a2de -URL $siteURL

as well as the group name for the site-col admin.

New-FBDSiteAuto.psm line 103        new-spuser 'Domain\Groupaccount' -Web $web.url -SiteCollectionAdmin -AssignmentCollection $assign

$NewSiteURL = "https://Portal.Domain.com" (this is the portal URL)
$sourceWebURL = "Targetsite" (The location for the list with the infomation)
$sourceListName = "NewRequests" (The list Name)
