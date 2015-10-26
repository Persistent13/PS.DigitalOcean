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
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('ndodr')]
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
        # Used to specify the name of the domain name to create the record.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the DNS record type.
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('A','AAAA','CNAME','MX','TXT','SRV','NS')]
        [Alias('Type')]
        [String]$RecordType,
        # Used to specify the address of the new domain name. IP v4 or v6 and the name of the SRV and MX record.
        [Parameter(Mandatory=$true,
                   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('IPAddress','RecordData','Data','Address')]
        [String]$Target,
        # Used to specify the name of the new domain record.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Record','Name')]
        [String]$DomainRecord,
        # Used to set the priority of a SRV or MX record.
        [Parameter(Mandatory=$false,
                   Position=5)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Priority,
        # Used to set the port of a SRV record.
        [Parameter(Mandatory=$false,
                   Position=6)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Port,
        # Used to set the weight of a SRV record.
        [Parameter(Mandatory=$false,
                   Position=7)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt16]$Weight
    )

    Begin
    {
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
        try
        {
            $doReturnInfo = Invoke-RestMethod -Method POST -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Warning "Unable to create the domain record.`n`r$errorDetail"
        }
    }
    End
    {
        Write-Output $doReturnInfo.domain_record
    }
}