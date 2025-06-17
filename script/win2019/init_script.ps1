# Windows 2019

$ErrorActionPreference = "Stop"

# ADD DNS
Write-Host "ADD DNS"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Domain" -Value "com2.kr"

# Telnet Client Install
Install-WindowsFeature -Name Telnet-Client | Out-Null

#Disable Network Location wizard
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network" -Name "NewNetworkWindowOff" -Force | Out-Null

# Disable TLS 1.0
Write-Host "Disable TLS 1.0"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

# Disable TLS 1.1
Write-Host "Disable TLS 1.1"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

# Windows Defender AntiSpyware disable
Write-Host "Disable WD"
New-Item -Path "HKLM:\Software\Policies\Microsoft" -Name "Windows Defender" | Out-Null
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 | Out-Null

# Determine if Core or Desktop Experience
$osVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType

# Remove SMB 1.0/CIFS File Sharing Support
Write-Host "Remove SMB 1.0/CIFS File Sharing Support"
Uninstall-WindowsFeature -Name FS-SMB1 | Out-Null

# Remove PowerShell v2
Write-Host "Remove PowerShell v2"
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart | Out-Null

# Remove XPS Viewer
Write-Host "Remove XPS Viewer"
Uninstall-WindowsFeature -Name XPS-Viewer | Out-Null

# Remove Microsoft XPS Document Writer
Write-Host "Remove Microsoft XPS Document Writer"
Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart | Out-Null

# Remove Windows Media Player
Write-Host "Remove Windows Media Player"
Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart | Out-Null

# Remove Windows Media Playback
Write-Host "Remove Windows Media Playback"
Disable-WindowsOptionalFeature -Online -FeatureName MediaPlayback -NoRestart | Out-Null

# Remove Internet Explorer 11
# Write-Host "Remove Internet Explorer 11"
# Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -NoRestart | Out-Null

# Remove Language pack package
Write-Host "Remove Language pack package"
Remove-Item "c:\language_pack_ko-kr.cab" -Force

# RDP Port change
# https://learn.microsoft.com/ko-kr/windows-server/remote/remote-desktop-services/clients/change-listening-port
Write-Host "RDP Port change"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value 63389
New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 63389
New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 63389

# User created (rpzjawltkdydwk)
Write-Host "User created (rpzjawltkdydwk)"
net user rpzjawltkdydwk dnlsehdn@1234 /add
net localgroup Administrators rpzjawltkdydwk /add
Get-WmiObject -Class Win32_UserAccount -Filter "Name='rpzjawltkdydwk'" | ForEach-Object {
    $_.PasswordExpires = $false
    $_.Put()
}