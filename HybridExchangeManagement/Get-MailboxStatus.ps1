Function Get-MailboxStatus {
    <#
            .SYNOPSIS
            Check whether a user exists in O365 and On-Prem Exchange
            .DESCRIPTION
            This function will check to see if a user has a mailbox in the cloud. If the user exists, the cmdlet will return an ExchangeGuid. 
            This function will also check to see if a user has an On-prem mailbox, or if the user is an on-prem Mailuser.
            To run this command, you must first connect to the O365 and On-prem email environments.
            .PARAMETER username
            The username of the individual you're looking up
            .EXAMPLE
            Get-MailboxStatus -Username meowth
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$username
    )

    if ($ombexist = ($(Get-OMailbox -ErrorAction SilentlyContinue -Identity $username | Select-Object exchangeguid)))
    {
        $O365_GUID = $ombexist.ExchangeGuid
    }
    else {$O365_GUID = 'User not found in O365'}

    if ($exmbstatus = ($(Get-EMailbox -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Identity $username | Select-Object IsValid)).isvalid -eq $True)
    {
        $EXCH_MB_STAT = 'Yes'
        $EXCH_MU_STAT = 'No'
    }
    elseif ($exmustatus = ($(Get-EMailUser -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Identity $username | Select-Object IsValid)).IsValid -eq $false)
    {
        $EXCH_MB_STAT = 'No'
        $EXCH_MU_STAT = 'Yes'
    }
    else
    {
        $EXCH_MB_STAT = 'No'
        $EXCH_MU_STAT = 'No'
    }

    $emailObj = [PSCustomObject]@{
        'Exch Mailbox'=$EXCH_MB_STAT
        'Exch MailUser'=$EXCH_MU_STAT
        'O365 GUID'=$O365_GUID
    }

    Write-Output -InputObject $emailObj
}