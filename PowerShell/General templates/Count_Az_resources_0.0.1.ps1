#########################################
# Az module required
# The script does count WebApps, SQL DBs, MySQL DBs and VMs.
#########################################

Connect-AzAccount 

$subscriptions = Get-AzSubscription

$totalSql = 0
$totalMySQL = 0
$totalWebApp = 0
$totalVM = 0
Foreach ($subscription in $subscriptions)
{

(Select-AzSubscription "$Subscription").Subscription.Name.silence

 $Sql = (Get-AzResource -ResourceType "Microsoft.Sql/servers/databases").count
 $MySQL = (Get-AzResource -ResourceType "Microsoft.DBforMySQL/servers").count
 $WebApp = (Get-AzResource -ResourceType "Microsoft.Web/sites").count
 $VMs= (Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines").count
 
 $totalSql += $Sql
 $totalMySQL += $MySQL
 $totalWebApp += $WebApp
 $totalVM += $VMs

}
Write-Host "total Sql = $totalSql"
Write-Host "total MySQLMySQL = $totalMySQL"
Write-Host "total WebApp = $totalWebApp"
Write-Host "total VMs = $totalVM"