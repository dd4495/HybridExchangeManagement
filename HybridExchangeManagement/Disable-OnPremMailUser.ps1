Function Disable-OnPremMailUser {
    <#
            .SYNOPSIS
            Removes Exchange attributes from a user in AD
            .DESCRIPTION
            This function will remove Exchange attributes from the specified user. 
            To run this command, you must first connect to the O365 and On-prem email environments.
            .PARAMETER username
            The username of the individual whose attributes you want to remove
            .EXAMPLE
            Disable-OnPremMailUser -Username meowth
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$username
    )
    Disable-EMailuser -identity $username
    Write-Output "Removed Exchange Attributes from $username"
}