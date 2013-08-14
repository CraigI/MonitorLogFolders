$ComputerName = (get-wmiobject Win32_Computersystem).name
$PathToScript = "<Path to Script>\MonitorLogFolders"
$SettingsINI = "$PathToScript\Settings.ini"
$LogPathCSV = "$PathToScript\LogPaths.csv"
$RecordCSV = "$PathToScript\Record.CSV"
$LogPaths = Import-CSV $LogPathCSV
$Date = Get-Date -Format d
$Time = Get-Date -Format t


get-content $SettingsINI | foreach-object {$iniData = @{}}{$iniData[$_.split('=')[0]] = $_.split('=')[1]}
$AlertMB = $iniData.AlertSize
$AlertFrom = $iniData.EmailFrom
$AlertTo = $iniData.EmailTo
$global:AlertText = $NULL

$AlertCount = 0


function SendAlert
{
  $FromAddress = $AlertFrom
  $ToAddress = $AlertTo
  $MessageSubject = "Log Drive issue(s) found"
  $MessageBody = "$global:AlertText"
  $SendingServer = "<Name or IP of SMTP server>"

  ###Create the mail message and add the statistics text file as an attachment
  $SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, $MessageSubject, $MessageBody

  ###Send the message
  $SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
  $SMTPClient.Send($SMTPMessage)
}

if ((Test-Path $RecordCSV) -eq $false)
{
	Add-Content $RecordCSV "Date,Time,LogLocation,SubFolder,NumberOfFiles,SizeOfFolder"
}

foreach ($LogPath in $LogPaths)
{
	$PathToCheck = $LogPath.RootFolderForLogs
	#Get Sub Folder List in PathToCheck
	$SubFolders = Get-ChildItem $PathToCheck | Where {$_.PSIsContainer}
	foreach ($SubFolder in $SubFolders)
	{
		$FullPath = "$PathToCheck\$SubFolder"
		$FolderStats = Get-ChildItem $FullPath | Measure-Object -property length -sum
		$NumberOfFiles = $FolderStats.Count
		$SizeOfFolder = ($FolderStats.Sum / 1MB)
		Add-Content $RecordCSV "$Date,$Time,$PathToCheck,$SubFolder,$NumberOfFiles,$SizeOfFolder"
		if($SizeOfFolder -gt $AlertMB)
		{
			$AlertCount ++
			$global:AlertText = $global:AlertText + "Folder $SubFolder found under $PathToCheck is currently $SizeOfFolder MB in size.`n"
		}
	}	
}

if ($AlertCount -gt 0)
{
	SendAlert
}