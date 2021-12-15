$domain="AD.BHSSF.ORG"
$computername= "$env:computername"

New-ADUser `
     -CN "Service - tableau_svc-dev" `
	 -Department "Technology & Digital" `
	 -DisplayName "Service - tableau_svc- dev" `
	 -DistinguishedName "CN=Service - tableau_svc-dev,OU=Service,OU=BHSF Entities,DC=AD,DC=BHSSF,DC=ORG" `
	 -EmployeeType "Service Account" `
	 -Name "Service - tableau_svc-s" `
	 -GivenName "Service" `
	 -Service - memberOf "CN=SG-BHSF Removable Media Read-Only,OU=Global,DC=AD,DC=BHSSF,DC=ORG;CN=SG-BHSF Global Restricted Logon Accounts,OU=Roles,OU=Global,DC=AD,DC=BHSSF,DC=ORG;CN=SG-Global BHSF Resource Account Password Policy (PSO),OU=Roles,OU=Global,DC=AD,DC=BHSSF,DC=ORG" `
	 -ObjectCategory "CN=Person,CN=Schema,CN=Configuration,DC=BHSSF,DC=ORG" `
	 -ObjectClass OID "top;person;organizationalPerson;user" `
	 -PrimaryGroupID "513" `
	 -SamAccountName "tableau_svc-s" `
	 -SamAccountNumber "805306368" `
	 -ServicePrincipalName "HTTP/DDMSTABL1T;HTTP/DDMSTABL2T;HTTP/DDMSTABL3T;HTTP/tableaustg.ad.bhssf.org;HTTP/DDMSTABL1T.ad.bhssf.org;HTTP/DDMSTABL2T.ad.bhssf.org;HTTP/DDMSTABL3T.ad.bhssf.org" `
	 -SN "tableau_svc-s" `
	 -Title "Service Account tableau_svc-s" `
	 -UserPrincipalName "tableau_svc-s@AD.BHSSF.ORG" `
	 
$group=$computer.psbase.children.find("administrators")

$userId = (Get-ADUser -OID 'Service - tableau_svc-s').OID
function AddToGroup($OID)
{
     $group.add("WinNT://"+$domain+"/"+$OID )
}

	 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Confirm:$false
Add-Computer -Credential (New-Object -TypeName PSCredential -ArgumentList "<<ado user>>",(ConvertTo-SecureString -String '<<ado password>>' -AsPlainText -Force)[0]) -DomainName AD.BHSSF.ORG -OUPath "OU=Servers,DC=AD,DC=BHSSF,DC=ORG"


New-NetFirewallRule -DisplayName "WMI HTTP" -Action Allow -Description "WMI HTTP" -Direction Inbound -LocalPort 5985 -Protocol tcp
New-NetFirewallRule -DisplayName "WMI HTTP" -Action Allow -Description "WMI HTTPS" -Direction Inbound -LocalPort 5986 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau Inbound Portal HTTP" -Action Allow -Description "Tableau Inbound Portal HTTP" -Direction Inbound -LocalPort 8850 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau Inbound Gateway HTTP" -Action Allow -Description "Tableau Inbound Gateway HTTP" -Direction Inbound -LocalPort 80 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau Inbound Gateway HTTPS" -Action Allow -Description "Tableau Inbound Gateway HTTPS" -Direction Inbound -LocalPort 443 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau Postgres" -Action Allow -Description "Tableau Postgres" -Direction Inbound -LocalPort 8060,8061 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau Dynamic Ports" -Action Allow -Description "Tableau Dynamic Ports" -Direction Inbound -LocalPort 8000-9000 -Protocol tcp
New-NetFirewallRule -DisplayName "Tableau License Server Ports" -Action Allow -Description "Tableau License Server Ports" -Direction Inbound -LocalPort 27000-27009 -Protocol tcp



Enable-PSRemoting –force
# Set start mode to automatic
Set-Service WinRM -StartMode Automatic
# Verify start mode and state - it should be running
Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $true -force
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true -force

$localTableauAdminPwd = ConvertTo-SecureString "admin@123" -AsPlainText -Force
echo $localTableauAdminPwd
$administratorLocalGroup = Get-LocalGroup -Name "Administrators"
$localTableauAdminUser = New-LocalUser "tableauadmin" -FullName "tableauadmin" -Description "tableauadmin" -PasswordNeverExpires -Password $localTableauAdminPwd
Add-LocalGroupMember -Group $administratorLocalGroup -Member $localTableauAdminUser




