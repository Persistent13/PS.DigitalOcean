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
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Could not find any record information for $DomainName.`n`r$errorDetail"
            }
        }
        else
        {
            $doReturnInfo = @()
            foreach($record in $DomainRecordID)
            {
                try
                {
                    $doApiUriWithRecord = '{0}{1}' -f $doApiUri,$record
                    $doReturnInfo += Invoke-RestMethod -Method GET -Uri $doApiUriWithRecord -Headers $sessionHeaders -ErrorAction Stop
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Could not find any domain information for $record.`n`r$errorDetail"
                }
            }
        }
    }
    End
    {
        if(-not $DomainRecordID)
        {
            Write-Output $doReturnInfo.domain_records
        }
        else
        {
            Write-Output $doReturnInfo.domain_record
        }
    }
}