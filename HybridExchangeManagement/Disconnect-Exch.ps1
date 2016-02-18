Function Disconnect-Exch {
     <#
            .SYNOPSIS
            Disconnect from On-prem Exchange environment
            .DESCRIPTION
            Removes remote Exchange Session
            .EXAMPLE
            Disconnect-Exch -MailServer mail01
    #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a password')]
        [string]$MailServer
    )
    Remove-PSSession -ComputerName "$MailServer.$env:USERDNSDOMAIN"
}