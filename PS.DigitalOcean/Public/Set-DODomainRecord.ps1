function Set-DODomainRecord
{
<#
.Synopsis
   The Set-DODomainRecord cmdlet updates domain information in the Digital Ocean cloud.
.DESCRIPTION
   The Set-DODomainRecord cmdlet updates domain information in the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Set-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecordID 3352896 -RecordType A -DomainRecord blog -Target 162.10.66.0

   id       : 3352896
   type     : A
   name     : blog
   data     : 162.10.66.0
   priority :
   port     :
   weight   :

   The example above updates domain record 3352896 with the domain name of blog.example.com.

.EXAMPLE
   PS C:\>Set-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecordID 3352897 -RecordType MX -Target mail1 -Priority 10

   id       : 3352897
   type     : MX
   name     : @
   data     : mail1
   priority : 10
   port     :
   weight   :

   The example above updates domain record 3352897 with the domain name of mail1.example.com and a priority of 10.

.EXAMPLE
   PS C:\>Set-DODomainRecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecordID 3352898 -RecordType SRV -Target srv1 -Priority 10 -Port 16384 -Weight 100

   id       : 3352898
   type     : SRV
   name     : _sip._tcp.example.com
   data     : srv1
   priority : 10
   port     : 16384
   weight   : 100

   The example above updates domain record 3352897 with the domain name of mail1.example.com and a priority of 10.

.INPUTS
   System.String

       This cmdlet requires the API key to be passed as a string.

   System.UInt16

       This cmdlet requires the domain record id, priority, port, and weigth to be passed as 16-bit, unsiged integers.
.OUTPUTS
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High',
                   PositionalBinding=$true)]
    [Alias('sdodr')]
    [OutputType([PSCustomObject])]
    Param
    (
        # Used to specify the name of the domain name to create the record under.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to get a specific domain record.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('RecordID','ID')]
        [UInt64[]]$DomainRecordID,
        # Used to specify the DNS record type.
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('A','AAAA','CNAME','MX','NS','SRV','TXT')]
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
        [UInt16]$Weight,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=8)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false,
                   Position=9)]
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
        [Hashtable]$sessionBodyBuild = @{'type'=$RecordType;'data'=$Target}
        if($DomainRecord)
        {
            $sessionBodyBuild += @{'name'=$DomainRecord}
        }
        if($Priority)
        {
            $sessionBodyBuild += @{'priority'=$Priority}
        }
        if($Port)
        {
            $sessionBodyBuild += @{'port'=$Port}
        }
        if($Weight)
        {
            $sessionBodyBuild += @{'weight'=$Weight}
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [String]$sessionBody = $sessionBodyBuild | ConvertTo-Json
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/domains/$DomainName/records/"
    }
    Process
    {
        foreach($record in $DomainRecordID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Update record: $record."))
            {
                try
                {
                    $doApiUriWithRecord = '{0}{1}' -f $doApiUri,$record
                    $doInfo = Invoke-RestMethod -Method PUT -Uri $doApiUriWithRecord -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
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