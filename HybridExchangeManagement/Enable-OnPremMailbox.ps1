Function Enable-OnPremMailbox {
    <#
            .SYNOPSIS
            Creates a new Exchange mailbox
            .DESCRIPTION
            This function will create a new On-prem Exchange mailbox for the specified user.
            To run this command, you must first connect to the O365 and On-prem email environments.
            .PARAMETER username
            The username of the individual for whom you want to create a mailbox
            .EXAMPLE
            Enable-OnPremMailbox -Username meowth
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$username
    )
    Enable-EMailbox -Identity $username 
    Write-Output "Created new On-prem mailbox for $username"
}