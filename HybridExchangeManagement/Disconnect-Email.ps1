Function Disconnect-Email {
     <#
            .SYNOPSIS
            Disconnect from O365 and On-prem Exchange environments
            .DESCRIPTION
            Removes remote O365 and Exchange Sessions
            .EXAMPLE
            Disconnect-Email -MailServer mail01
    #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$MailServer
    )
    Remove-PSSession -ComputerName outlook.office365.com
    Remove-PSSession -ComputerName "$MailServer.$env:USERDNSDOMAIN"
}