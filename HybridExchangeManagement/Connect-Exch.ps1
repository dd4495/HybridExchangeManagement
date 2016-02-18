Function Connect-Exch {
<#
    .SYNOPSIS
    Connect to On-prem Exchange environment
    .DESCRIPTION
    Set remote credentials and session information for making a connection to Exchange
    .EXAMPLE
    Connect-Exch -ExchUser domain\admin -ExchPass P@ssw0rd!
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$ExchUser,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$ExchPass,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$MailServer
    )

    $ExPW = ConvertTo-SecureString -AsPlainText -Force -String $ExchPass
    $ExCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ExchUser,$ExPW
    $ExURI = "http://$MailServer.$env:USERDNSDOMAIN/PowerShell/?SerializationLevel=Full"
    $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExURI -Credential $ExCred -Authentication Kerberos
    Import-PSSession $ExSession
}