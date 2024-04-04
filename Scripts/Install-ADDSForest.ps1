param
(
    [string]$domainName = "contoso.com",
    [string]$domainNetbiosName = "CONTOSO",
    [string]$safeModePass = "P@ssw0rd@1411"
)
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "7" `
    -DomainName "$domainName" `
    -DomainNetbiosName "$domainNetbiosName" `
    -ForestMode "7" `
    -InstallDns `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "$safeModePass" -AsPlainText -Force) `
    -Force 