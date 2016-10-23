﻿function Get-DOSize
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
            foreach($size in $doInfo.sizes)
            {
                $doReturnInfo = [PSCustomObject]@{
                    'Slug' = $size.slug
                    'Memory' = $size.memory
                    'vCPU' = $size.vcpus
                    'Disk' = $size.disk
                    'Transfer' = $size.transfer
                    'PriceMonthly' = $size.price_monthly
                    'PriceHourly' = $size.price_hourly
                    'Region' = $size.regions
                    'Available' = $size.available
                }
                # DoReturnInfo is returned after Add-ObjectDetail is processed.
                Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Size'
            }
        }
        catch
        {
            if($_.Exception.Response)
            {
                # Convert a 400-599 error to something useable.
                $errorDetail = (Resolve-HTTPResponse -Response $_.Exception.Response) | ConvertFrom-Json
                Write-Error -Message $errorDetail.message
            }
            else
            {
                # Return the error as is.
                Write-Error -Message $_
            }
        }
    }
}