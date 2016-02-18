Function Start-Dirsync {
    <#
            .SYNOPSIS
            Starts DirSync
            .DESCRIPTION
            This function starts a new DirSync process. Use this function if you've recently made a change to a user's O365 account
            and need to sync the change to O365 and AD.
            .PARAMETER DSServer
            The FQDN of your DirSync Server
            .PARAMETER AsJob
            DO NOT USE. For testing purposes only
            .EXAMPLE
            Start-DirSync
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Enter the FQDN of the DirSync server')]
        [string]$DSServer,
        [parameter()][Switch]
        $AsJob
    )

    $ScriptBlock = {
        Invoke-Command -ComputerName "$DSServer" {"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" ` 
            -psconsolefile "$env:ProgramFiles\Windows Azure Active Directory Sync\DirSyncConfigShell.psc1" ` 
        -command 'Start-OnlineCoexistenceSync'}
    }

    if ($AsJob){
        Start-Job -ScriptBlock $ScriptBlock
    } else {
        Invoke-Command -ScriptBlock $ScriptBlock
    }

}