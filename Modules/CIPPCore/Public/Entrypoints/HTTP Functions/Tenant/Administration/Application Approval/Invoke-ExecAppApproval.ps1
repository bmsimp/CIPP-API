using namespace System.Net

function Invoke-ExecAppApproval {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Tenant.Application.Read
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    $Headers = $Request.Headers
    Write-LogMessage -headers $Headers -API $APIName -message 'Accessed this API' -Sev 'Debug'


    # Seems to be an unused endpoint? -Bobby

    $ApplicationId = if ($Request.Query.ApplicationId) { $Request.Query.ApplicationId } else { $env:ApplicationID }
    $Results = Get-Tenants | ForEach-Object {
        [PSCustomObject]@{
            defaultDomainName = $_.defaultDomainName
            link              = "https://login.microsoftonline.com/$($_.customerId)/v2.0/adminconsent?client_id=$ApplicationId&scope=$ApplicationId/.default"
        }
    }

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $Results
        })

}
