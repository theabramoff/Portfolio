#########################################
# The script does the following:
# - Updating registry and setting up 2 new paths for TempDB Data and TempDB Log
# - Setting up Scheduler task for 2 folders creation during start up
#########################################

#task schedule parameters
$Trigger= New-ScheduledTaskTrigger -AtStartup
$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction -Execute "C:\Program Files\Microsoft SQL Server IaaS Agent\Bin\SqlIaaSExtension.SqlServerStarter.exe"
			
#registry path
$registry = "Registry::HKLM\SOFTWARE\Microsoft\SqlIaaSExtension\CurrentVersion"
			
#confuguring TempDB paths for DATA and LOG in registry
#!!!!!  * to be changed to a proper drive letter  !!!!
			
Set-ItemProperty -Path $registry -Name "TempDbData" -Value "*:\TempDB\DATA"
Set-ItemProperty -Path $registry -Name "TempDbLog" -Value "*:\TempDB\LOG"
			
#If TargetedSqlInstance doesn't exist - run the line below:
#Set-ItemProperty -Path $registry -Name "TargetedSqlInstance" -Value "MSSQLSERVER"
			
#creating scheduling task
Register-ScheduledTask -TaskName "SQL Starter" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force