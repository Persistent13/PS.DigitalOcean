function Get-DODomain
{
<#
.Synopsis
   The Get-DODomain cmdlet pulls domain information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DODomain cmdlet pulls domain information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582

   name        ttl  zone_file                                                                                                                                   
   ----        ---  ---------                                                                                                                                   
   example.com 1800 $ORIGIN example.com....

   The example above returns all avaiable domain information for the current API bearer.

.EXAMPLE
   PS C:\>Get-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com, example.org

   name        ttl  zone_file                                                                                                                                   
   ----        ---  ---------                                                                                                                                   
   example.com 1800 $ORIGIN example.com....

   name        ttl  zone_file                                                                                                                                   
   ----        ---  ---------                                                                                                                                   
   example.org 1800 $ORIGIN example.org....

   The example above returns the specfied domain information for the current API bearer if available.

.INPUTS
   System.String
        
       This cmdlet requires the API key and domain names to be passed as strings.
.OUTPUTS
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdod')]
    [OutputType([PSCustomObject])]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey,
        # Used to get a specific domain with the domain name.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$DomainName
    )

    Begin
    {
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/domains/'
    }
    Process
    {
        if(-not $DomainName)
        {
            try
            {
                $doReturnInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Could not find any domain information.`n`r$errorDetail"
            }
        }
        else
        {
            $doReturnInfo = @()
            foreach($domain in $DomainName)
            {
                try
                {
                    $doApiUriWithDomain = '{0}{1}' -f $doApiUri,$domain
                    $doReturnInfo += Invoke-RestMethod -Method GET -Uri $doApiUriWithDomain -Headers $sessionHeaders -ErrorAction Stop
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Could not find any domain information for $domain.`n`r$errorDetail"
                }
            }
        }
    }
    End
    {
        if(-not $DomainName)
        {
            Write-Output $doReturnInfo.domains
        }
        else
        {
            Write-Output $doReturnInfo.domain
        }
    }
}