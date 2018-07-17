import-module webadministration

    $EmailFrom = ""
	$EmailTo = ""
	$SMTPServer = ""
 
	function main{
	#get-command -module webadministration will show all the IIS stuff
	$appPoolName = "WsusPool"
	
	$dt = get-date
	$ComputerName = $env:computername
	If((get-WebAppPoolState -name $appPoolName).Value -eq "Stopped")
	{
		write-host "Failure detected, attempting to start it"
		start-webAppPool -name $appPoolName
		start-sleep -s 60
		
		If((get-WebAppPoolState -name $appPoolName).Value -eq "Stopped")
		{
			write-host "Tried to restart, but it didn't work!"
			sendmail "AppPoolRestart Failed" "App Pool $appPoolName restart on $ComputerName failed - this will effect search `n $dt"
			#log to event log
		}
		else
		{
			write-host "Looks like the app pool restarted ok"
			$subjectString = "AppPool Restart was needed"
			$body = "A routine check of the App Pool $appPoolName on $ComputerName found that it was not running, it has been started. `n $dt"
			sendmail $subjectString $body
			#log to event log?
		}
	}
	else
	 {
	 write-host "app pool $appPoolName is running"
	 }
    exit 0
 } #end main function
 
 function sendmail($subject, $body)
 {
	$EmailBody = $body
	$EmailSubject = $subject

    write-host "in Sendmail with subject: $subject, and body: $body"
 
	Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $subject -body $EmailBody -SmtpServer $SMTPServer
	"Emailed $subject on $dt to $EmailTo" | out-file -filepath "CheckSearchAppPools.log" -append 
 }
 
 #call main function
 Set-ExecutionPolicy -Bypass
 main
 exit 0
