Function Connect-Email {
    <#
            .SYNOPSIS
            Connect to Office 365 and On-prem Exchange environments
            .DESCRIPTION
            Set remote credentials and session information for making connections to O365 and Exchange
            .EXAMPLE
            Connect-Email -O365User admin@domain.onmicrosoft.com -O365Pass P@ssw0rd -ExchUser domain\admin -ExchPass P@ssw0rd!
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$O365User,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$O365Pass,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$ExchUser,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$ExchPass
    )


    $O365pw = ConvertTo-SecureString -AsPlainText -Force -String $O365Pass
    $O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $O365User, $O365pw
    $O365URI = 'https://outlook.office365.com/powershell-liveid/'
    $O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $O365URI -Credential $O365Cred -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue
    Import-PSSession $O365Session -Prefix 'O'

    $ExPW = ConvertTo-SecureString -AsPlainText -Force -String $ExchPass
    $ExCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ExchUser, $ExPW
    $ExURI = "http://cwexch01.$env:USERDNSDOMAIN/PowerShell/?SerializationLevel=Full"
    $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExURI -Credential $ExCred -Authentication Kerberos -WarningAction SilentlyContinue
    Import-PSSession $ExSession -Prefix 'E'

}