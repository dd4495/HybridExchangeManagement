Function Disconnect-O365 {
     <#
            .SYNOPSIS
            Disconnect from O365 environment
            .DESCRIPTION
            Removes remote O365 Session
            .EXAMPLE
            Disconnect-O365
    #>
    Remove-PSSession -ComputerName outlook.office365.com
}