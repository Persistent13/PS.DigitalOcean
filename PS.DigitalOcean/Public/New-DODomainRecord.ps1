function New-DODomainRecord
{
<#
.Synopsis
   The New-DODomain cmdlet creats a new domain entry in the Digital Ocean cloud.
.DESCRIPTION
   The New-DODomain cmdlet creats a new domain entry in the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   New-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -RecordType A -Target '162.10.66.0' -DomainRecord www

   id       : 3352896
   type     : A
   name     : www
   data     : 162.10.66.0
   priority :
   port     :
   weight   :

   The example above creates an A record with the name of www with a target of 162.10.66.0 for the example.com domain.

.EXAMPLE
   PS C:\>Get-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -RecordType MX -Target '162.10.66.0' -DomainRecord mail1 -Priority 10

   id       : 3352897
   type     : MX
   name     : mail
   data     : 162.10.66.0
   priority : 10
   port     :
   weight   :

   The example above creates a MX record with the name of mail with a target of 162.10.66.0 with a priority of 10 for the example.com domain.

.EXAMPLE
   PS C:\>Get-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -RecordType SRV -Target srv1 -DomainRecord '_sip._tcp.example.com' -Priority 10 -Port 16384 -Weight 100

   id       : 3352898
   type     : SRV
   name     : _sip._tcp.example.com
   data     : srv1
   priority : 10
   port     : 16384
   weight   : 100

   The example above creates a SRV record with the name of _sip._tcp.example.com with a target of srv1 with a priority of 10 with a port of
   16384 with a weight of 100 for the example.com domain.

.INPUTS
   System.String

       This cmdlet requires the API key, domain name, record type, target, and domain record to be passed as strings.

   System.UInt16

       This cmdlet requires the priority, port, and weigth to be passed as 16-bit, unsiged integers.
.OUTPUTS
   PS.DigitalOcean.DomainRecord

       A PS.DigitalOcean.DomainRecord object holding the domain record info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Low',
                   PositionalBinding=$true)]
    [Alias('ndodr')]
    [OutputType('PS.DigitalOcean.DomainRecord')]
    Param
    (
        # Used to specify the name of the domain name to create the record.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the DNS record type.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('A','AAAA','CNAME','MX','TXT','SRV','NS')]
        [Alias('Type')]
        [String]$RecordType,
        # Used to specify the address of the new domain name. IP v4 or v6 and the name of the SRV and MX record.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('IPAddress','RecordData','Data','Address')]
        [String]$Target,
        # Used to specify the name of the new domain record.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Record','Name')]
        [String]$DomainRecord,
        # Used to set the priority of a SRV or MX record.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Priority,
        # Used to set the port of a SRV record.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Port,
        # Used to set the weight of a SRV record.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Weight,
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
        if($RecordType -eq 'MX' -or $RecordType -eq 'CNAME' -or $RecordType -eq 'NS')
        {
            if(-not $Target.EndsWith('.'))
            {
                $Target = '{0}{1}' -f $Target,'.'
            }
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [String]$sessionBody = @{'type'=$RecordType;'name'=$DomainRecord;'data'=$Target;'priority'=$Priority;'port'=$Port;'weight'=$Weight} | ConvertTo-Json
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/domains/$DomainName/records/"
    }
    Process
    {
        if($Force -or $PSCmdlet.ShouldProcess("Record creation for $DomainName with RecordName: $RecordName RecordType: $RecordType Target: $Target Priority: $Priority Port: $Port Weight: $Weight"))
        {
            try
            {
                $doInfo = Invoke-RestMethod -Method POST -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
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
                $errorDetail = (Resolve-HTTPResponse -Responce $_.Exception.Responce) | ConvertFrom-Json
                Write-Error $errorDetail.message
            }
        }
    }
}