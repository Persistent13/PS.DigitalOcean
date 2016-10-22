function New-DODomain
{
<#
.Synopsis
   The New-DODomain cmdlet pulls domain information from the Digital Ocean cloud.
.DESCRIPTION
   The New-DODomain cmdlet pulls domain information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   New-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -Target '162.10.66.0'

   name        ttl zone_file
   ----        --- ---------
   example.com

   The example above returns the domain information of the new domain.

.INPUTS
   System.String

       This cmdlet requires the API key, domain name, and target to be passed as strings.
.OUTPUTS
   PS.DigitalOcean.Domain

       A PS.DigitalOcean.Domain object holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Low',
                   PositionalBinding=$true)]
    [Alias('ndod')]
    [OutputType('PS.DigitalOcean.Domain')]
    Param
    (
        # Used to specify the name of the new domain name.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the address of the new domain name. IP v4 or v6.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('IPAddress','RecordData','Data','Address')]
        [String]$Target,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
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
        [String]$sessionBody = @{'name'=$DomainName;'ip_address'=$Target} | ConvertTo-Json
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/domains/'
    }
    Process
    {
        if($Force -or $PSCmdlet.ShouldProcess("Creating $DomainName with the IP address of $Target."))
        {
            try
            {
                $doInfo = Invoke-RestMethod -Method POST -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
                $doReturnInfo = [PSCustomObject]@{
                    'Name' = $doInfo.domain.name
                    'TTL' = $doInfo.domain.ttl
                    'ZoneFile' = $doInfo.domain.zone_file
                }
                # DoReturnInfo is returned after Add-ObjectDetail is processed.
                Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Domain'
            }
            catch
            {
                $errorDetail = (Resolve-HTTPResponse -Responce $_.Exception.Responce) | ConvertFrom-Json
                Write-Error $errorDetail.message
            }
        }
    }
}