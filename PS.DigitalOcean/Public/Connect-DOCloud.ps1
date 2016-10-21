function Connect-DOCloud
{
<#
.Synopsis
   The Connect-DOCloud cmdlet sets the API key for the Digital Ocean module cmdlets.
.DESCRIPTION
   The Connect-DOCloud cmdlet sets the API key for the Digital Ocean module cmdlets.

   An API key is required to use this cmdlet.
.EXAMPLE
   Connect-DOCloud

   The above command will prompt for the API key and save it for use in other PS.DigitalOcean modules.

.EXAMPLE
   PS C:\>Connect-DOCloud -APIKey b7d03a6947b217efb6f3ec3bd3504582

   The above command will take the API key given and save it for use in other PS.DigitalOcean modules.

.INPUTS
   System.String

       This cmdlet can take the API key as a string.
.OUTPUTS
   PS.DigitalOcean.Account

       A PS.DigitalOcean.Account object holding the account info is returned on a sucessful login.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true)]
    [Alias('cdoc')]
    [OutputType('PS.DigitalOcean.Account')]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey
    )

    Begin
    {
        if(-not $APIKey)
        {
            $APIKey = (Get-Credential -Message 'Enter your API key below.' -UserName Bearer).GetNetworkCredential().Password
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/account/'
    }
    Process
    {
        try
        {
            $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders
            $script:SavedDOAPIKey = $APIKey
            $doReturnInfo = [PSCustomObject]@{
                'DropletLimit' = $doInfo.account.droplet_limit
                'FloatingIPLimit' = $doInfo.account.floating_ip_limit
                'Email' = $doInfo.account.email
                'UUID' = $doInfo.account.uuid
                'EmailVerified' = $doInfo.account.email_verified
                'Status' = $doInfo.account.status
                'StatusMessage' = $doInfo.account.status_message
            }
            # DoReturnInfo is returned after Add-ObjectDetail is processed.
            Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Account'
        }
        catch
        {
            $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Response) | ConvertFrom-Json
            Write-Error $errorDetail.message
        }
    }
}