<powershell>
$thisComputer = $env:COMPUTERNAME
$smtpServer = "exchange.yourdomain.com"
$smtpFrom = "updates@yourdomain.com"
$smtpTo = "you@yourdomain.com";
$messageSubject = $thisComputer + " Update/Reboot Report"
$Message = New-Object System.Net.Mail.mailmessage $smtpFrom, $smtpTo
$Message.Subject = $messageSubject

#Define update criteria.
$Criteria = "IsInstalled=0 and Type='Software'"

#Search for relevant updates.
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchResult = $Searcher.Search($Criteria).Updates

If ($SearchResult.Count -gt 0)
{
	#Download updates.
	$Session = New-Object -ComObject Microsoft.Update.Session
	$Downloader = $Session.CreateUpdateDownloader()
	$Downloader.Updates = $SearchResult
	$Downloader.Download()

	#Install updates.
	$Installer = New-Object -ComObject Microsoft.Update.Installer
	$Installer.Updates = $SearchResult
	$Result = $Installer.Install()
	#Reboot if required by updates.

	If ($Result.rebootRequired) 
	{ 
		$timeStamp = get-date -Format hh:mm
		$todaysDate = get-date -format D
		$RebootResult = "The server: " + $thisComputer + " has installed its updates and requires a reboot. It began rebooting at:" + $timeStamp + " on " + $todaysDate
		$Message.Body = $RebootResult
		$smtp = new-Object Net.Mail.SmtpClient($smtpServer)
		$smtp.Send($message)
		shutdown.exe /t 0 /r 
	}
	If (!$Result.rebootRequired)
	{
		$timeStamp = get-date -Format hh:mm
		$todaysDate = get-date -format D
		$RebootResult = "The server: " + $thisComputer + " has installed its updates and did not require a reboot. It finished installing its updates at:" + $timeStamp + " on " + $todaysDate
		$smtp = new-Object Net.Mail.SmtpClient($smtpServer)
		$smtp.Send($message)
	}
		
	Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False.
	winrm quickconfig 
	winrm get winrm/config/listener 
	winrm get winrm/config 
	winrm set winrm/config/service/auth @{Basic="true"} 
	winrm set winrm/config/service @{AllowUnencrypted="true"} 
	winrm get winrm/config 
	winrm set winrm/config/client/auth @{Basic="true"} 
	winrm set winrm/config/client @{AllowUnencrypted="true"}

	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
}else
{
	$rebootRequired = Get-WUIsPendingReboot
	If ($rebootRequired)
	{
		echo "Reboot Pending"
		shutdown.exe -r
	}else
	{
		echo "No New Updates to Install and No Reboot requests are pending"
		$LocalTempDir = $env:TEMP;$ChromeInstaller = "ChromeInstaller.exe";(new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor = "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)
		
		Disable-LocalUser -Name "Administrator"
	}
	
}
</powershell>