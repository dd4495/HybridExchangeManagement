Function Invoke-ExchToCloud {
<#
            .SYNOPSIS
            Migrates a mailbox from on-prem to O365
            .DESCRIPTION
            This function prepares a mailbox for migration and finishes the migration automatically.
            To run this command, you must first connect to the O365 and On-prem email environments.
            .PARAMETER username
            The username of the individual whose mailbox you're migrating
            .PARAMETER SrcEndpoint
            Your on-prem email domain
            .PARAMETER DeliveryDomain
            Your O365 email domain 
            .PARAMETER MailDomain
            Your on-prem email suffix
            .PARAMETER BadItemLimit
            The maximum number of corrupted items to allow before a migration fails
            Only set this value if a migration fails due to too many corrupted items
            The default value of this parameter is 25
            .PARAMETER LargeItemLimit
            The maximum number of large items to allow before a migration fails
            Only set this value if a migration fails due to too many large items
            The default value of this parameter is 25
            .EXAMPLE
            Invoke-CloudToExch -Username meowth -SrcEndpoint mail.domain.com -DeliveryDomain o365.domain.com
            .EXAMPLE
            Invoke-CloudToExch -Username gro715941 -SrcEndpoint mail.domain.com -DeliveryDomain o365.domain.com -LargeItemLimit 50
            .EXAMPLE
            Invoke-CloudToExch -Username groot -SrcEndpoint mail.domain.com -DeliveryDomain o365.domain.com -LargeItemLimit 50 -BadItemLimit 100
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$username,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 1,HelpMessage = 'Enter your on-prem mail domain')]
        [string]$SrcEndpoint,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 2,HelpMessage = 'Enter your o365 mail domain')]
        [string]$DeliveryDomain,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 3,HelpMessage = 'Enter your email suffix')]
        [string]$MailDomain,
        [Parameter(Mandatory = $false,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 4,HelpMessage = 'Enter a bad item limit')]
        [string]$BadItemLimit = '25',
        [Parameter(Mandatory = $false,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 5,HelpMessage = 'Enter a large item limit')]
        [string]$LargeItemLimit = '25'
    )

    $header = 'EmailAddress'
    $tempFile = "$env:temp\TEMP-$(Get-Date -Format 'yyyy-MM-dd_hh-mm-ss').csv"
    New-Item $tempFile -ItemType File
    "$username@$MailDomain" > $tempFile
    $csvFile = Import-Csv $tempFile -Header $header
    Export-Csv -InputObject $csvFile -Path $tempFile -NoTypeInformation
    Get-Content $tempFile

    if ($moveReqUsr = (Get-OMoveRequest |Select-Object alias, id).where{$_.alias -match $username}.id) {
    Remove-OMoveRequest -Identity $moveReqUsr}
    else {Write-Output "No Move requests for $username"}

    if ($migBatUser = (Get-OMigrationBatch|Select-Object status, CreationDateTime, identity).where{(($_.CreationDateTime.ToShortDateString() -match (Get-Date).ToShortDateString()) -and ($_.status -match 'Completed'))}) {
    Remove-OMigrationBatch -Identity $migBatUser.identity}
    else {Write-Output "No migration batch for $username"}

    New-OMigrationBatch -Name $username -SourceEndpoint $SrcEndpoint -TargetDeliveryDomain $DeliveryDomain -CSVData ([System.IO.File]::ReadAllBytes($tempFile)) -AutoStart -AutoComplete 
}