﻿param(
    $smtp ="smtp.office365.com" # SMTP/Email server
    ,$to       # Destination email account
    ,$from     # Email user
    ,$user     # Email user
    ,$password # Email password (use Encrypted Global Property)
    ,$port = 587 # Port for sending email
    ,[switch]$debug
)

try
{ 
    Get-Date | Out-Host
    $results = get-aduser -filter * -Properties * | where-object{ $_.enabled -eq $true -and $_.lockedout -eq $true} | Select-Object Name,Mail,Enabled,LockedOut,PasswordExpired | Out-Host
    $results | ForEach-Object{ $body = $body + "<br>Name: " + $_.Name + "<br>Mail: " + $_.Mail + "<br>Enabled: " + $_.Enabled + "<br>LockedOut: " + $_.LockedOut + "<br>PasswordExpired: " + $_.PasswordExpired + "<br>" }
    $subject = "AD locked accounts report " + (Get-Date -Format "MM/dd/yyyy hh:mm")
 
    $secpasswd = ConvertTo-SecureString "$password" -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
        
    if(!$debug)
    { Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -UseSSL -Credential $mycreds -Port $port }
}
catch [Exception]
{
    Write-Host $_
    Write-Host "Error finding accounts or sending email!"
    Exit 1 
}