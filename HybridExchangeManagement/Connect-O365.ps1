Function Connect-O365 {
    <#
    .SYNOPSIS
    Connect to Office 365 environment
    .DESCRIPTION
    Set remote credentials and session information for making a connection to O365
    .EXAMPLE
    Connect-O365 -O365User admin@domain.onmicrosoft.com -O365Pass P@ssw0rd
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$O365User,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$O365Pass
    )

    $O365pw = ConvertTo-SecureString -AsPlainText -Force -String $O365Pass
    $O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $O365User, $O365pw
    $O365URI = 'https://outlook.office365.com/powershell-liveid/'
    $O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $O365URI -Credential $O365Cred -Authentication Basic -AllowRedirection
    Import-Module MSOnline
    Import-PSSession $O365Session
    Connect-MsolService
}