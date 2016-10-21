function Get-DODomainRecord
{
<#
.Synopsis
   The Get-DODomainRecord cmdlet pulls domain record information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DODomainRecord cmdlet pulls domain record information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com

   id       : 3352892
   type     : NS
   name     : @
   data     : ns1.digitalocean.com
   priority :
   port     :
   weight   :

   id       : 3352893
   type     : NS
   name     : @
   data     : ns2.digitalocean.com
   priority :
   port     :
   weight   :

   id       : 3352894
   type     : NS
   name     : @
   data     : ns3.digitalocean.com
   priority :
   port     :
   weight   :

   id       : 3352895
   type     : A
   name     : @
   data     : 1.2.3.4
   priority :
   port     :
   weight   :

   The example above returns all avaiable domain records information on all domains for the current API bearer.

   Multiple domain names can be specified.

.EXAMPLE
   PS C:\>Get-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecord 3352895, 3352894

   id       : 3352894
   type     : NS
   name     : @
   data     : ns3.digitalocean.com
   priority :
   port     :
   weight   :

   id       : 3352895
   type     : A
   name     : @
   data     : 1.2.3.4
   priority :
   port     :
   weight   :

   The example above returns the domain records information for the selected record IDs for the current API bearer.

   Multiple domain names cannot be specifed when the DomainRecord parameter is used.

.INPUTS
   System.String

       This cmdlet requires the API key and domain name to be passed as strings.

   System.UInt64

       This cmdlet requires the domain record ID to be passed as an unsigned, 64-bit interger.
.OUTPUTS
   PS.DigitalOcean.DomainRecord

       A custome PS.DigitalOcean.DomainRecord holding the domain record info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdod')]
    [OutputType('PS.DigitalOcean.DomainRecord')]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey,
        # Used to get a specific domain.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to get a specific domain record.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('RecordID','ID')]
        [UInt64[]]$DomainRecordID
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/domains/$DomainName/records/"
    }
    Process
    {
        if(-not $DomainRecordID)
        {
            try
            {
                $doReturnInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
                foreach($info in $doInfo.domain_records)
                {
                    $doReturnInfo = [PSCustomObject]@{
                        'ID' = $info.id
                        'Type' = $info.type
                        'Name' = $info.name
                        'Data' = $info.data
                        'Priority' = $info.priority
                        'Port' = $info.port
                        'Weight' = $info.weight
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.DomainRecord'
                }
            }
            catch
            {
                $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Response) | ConvertFrom-Json
                Write-Error $errorDetail.message
            }
        }
        else
        {
            foreach($record in $DomainRecordID)
            {
                try
                {
                    $doApiUriWithRecord = '{0}{1}' -f $doApiUri,$record
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithRecord -Headers $sessionHeaders -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'ID' = $doInfo.domain_record.id
                        'Type' = $doInfo.domain_record.type
                        'Name' = $doInfo.domain_record.name
                        'Data' = $doInfo.domain_record.data
                        'Priority' = $doInfo.domain_record.priority
                        'Port' = $doInfo.domain_record.port
                        'Weight' = $doInfo.domain_record.weight
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.DomainRecord'
                }
                catch
                {
                    $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Response) | ConvertFrom-Json
                    Write-Error $errorDetail.message
                }
            }
        }
    }
}