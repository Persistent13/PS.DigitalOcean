function Get-DOSize
{
<#
.Synopsis
    The Get-DOUser cmdlet pulls droplet size information from the Digital Ocean cloud.
.DESCRIPTION
    The Get-DOUser cmdlet pulls droplet size information from the Digital Ocean cloud.

    An API key is required to use this cmdlet.
.EXAMPLE
    Get-DOSize -APIKey b7d03a6947b217efb6f3ec3bd3504582

    slug          : 512mb
    memory        : 512
    vcpus         : 1
    disk          : 20
    transfer      : 1.0
    price_monthly : 5.0
    price_hourly  : 0.00744
    regions       : {nyc1, sgp1, ams1, ams2...}
    available     : True

    slug          : 1gb
    memory        : 1024
    vcpus         : 1
    disk          : 30
    transfer      : 2.0
    price_monthly : 10.0
    price_hourly  : 0.01488
    regions       : {nyc2, sgp1, ams1, sfo1...}
    available     : True

    slug          : 2gb
    memory        : 2048
    vcpus         : 2
    disk          : 40
    transfer      : 3.0
    price_monthly : 20.0
    price_hourly  : 0.02976
    regions       : {nyc2, sfo1, ams1, sgp1...}
    available     : True

    The example above returns the information for the current API bearer.
.INPUTS
    System.String

       This cmdlet requires the API key to be passed as a string.
.OUTPUTS
    PS.DigitalOcean.Account

       A PS.DigitalOcean.Account object holding the account info is returned.
.ROLE
    PS.DigitalOcean
.FUNCTIONALITY
    PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdou')]
    [OutputType('PS.DigitalOcean.Size')]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/sizes/'
    }
    Process
    {
        try
        {
            $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
            $doReturnInfo = [PSCustomObject]@{
                'Slug' = $doInfo.account.slug
                'Memory' = $doInfo.account.memory
                'vCPU' = $doInfo.account.vcpus
                'Disk' = $doInfo.account.disk
                'Transfer' = $doInfo.account.transfer
                'PriceMonthly' = $doInfo.account.price_monthly
                'PriceHourly' = $doInfo.account.price_hourly
                'Regions' = $doInfo.account.regions
                'Available' = $doInfo.account.available
            }
            # DoReturnInfo is returned after Add-ObjectDetail is processed.
            Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Account'
        }
        catch
        {
            $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Responce) | ConvertFrom-Json
            Write-Error $errorDetail.message
        }
    }
}