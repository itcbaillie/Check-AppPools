
$TaskName = "Check App Pools"

$Schedule = New-Object -com Schedule.Service
$Schedule.connect()
$Tasks = $Schedule.GetFolder("\").GetTasks(0)

$TaskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName}

if(-not $TaskExists){
    Write-Host "Creating task..." -ForegroundColor Cyan
    $action = New-ScheduledTaskAction -Execute "E:\WSUS\Check-AppPools.ps1"
    $trigger = New-ScheduledTaskTrigger -Once -At "6/8/2018 00:00:00" -RepetitionInterval (New-TimeSpan -Minutes 60) -RepetitionDuration ([System.TimeSpan]::MaxValue)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType S4U -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel

    Register-ScheduledTask -TaskName "AppPool Check" -Action $action -Trigger $trigger -Settings $settings -Principal $principal
    Write-Host "Created task..." -ForegroundColor Cyan
} else {
    Write-Host "Task already exists" -ForegroundColor Cyan
}