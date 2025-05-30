using namespace System.Net

Function Invoke-RemoveUser {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Identity.User.ReadWrite
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    $Headers = $Request.Headers
    Write-LogMessage -Headers $Headers -API $APIName -message 'Accessed this API' -Sev 'Debug'

    # Interact with query parameters or the body of the request.
    $TenantFilter = $Request.Query.tenantFilter ?? $Request.Body.tenantFilter
    $UserID = $Request.Query.ID ?? $Request.Body.ID
    $UserPrincipalName = $Request.Query.userPrincipalName ?? $Request.Body.userPrincipalName

    if (!$UserID) { exit }
    try {
        $null = New-GraphPostRequest -uri "https://graph.microsoft.com/beta/users/$($UserID)" -type DELETE -tenant $TenantFilter
        $Result = "Successfully deleted user with ID: '$UserID'"
        if ($UserPrincipalName) { $Result += " and User Principal Name: '$UserPrincipalName'" }
        Write-LogMessage -Headers $Headers -API $APIName -message $Result -Sev 'Info' -tenant $TenantFilter
        $StatusCode = [HttpStatusCode]::OK

    } catch {
        $ErrorMessage = Get-CippException -Exception $_
        $Result = "Failed to delete user $($UserID). $($ErrorMessage.NormalizedError)"
        if ($UserPrincipalName) { $Result += " User Principal Name: '$($UserPrincipalName)'" }
        Write-LogMessage -Headers $Headers -API $APIName -message $Result -Sev 'Error' -tenant $TenantFilter -LogData $ErrorMessage
        $StatusCode = [HttpStatusCode]::InternalServerError
    }

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $StatusCode
            Body       = @{ 'Results' = $Result }
        })
}
