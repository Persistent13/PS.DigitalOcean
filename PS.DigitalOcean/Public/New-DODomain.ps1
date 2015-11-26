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
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Low',
                   PositionalBinding=$true)]
    [Alias('ndod')]
    [OutputType([PSCustomObject])]
    Param
    (
        # Used to specify the name of the new domain name.
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the address of the new domain name. IP v4 or v6.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('IPAddress','RecordData','Data','Address')]
        [String]$Target,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=3)]
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
                $doReturnInfo = Invoke-RestMethod -Method POST -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Unable to create the domain.`n`r$errorDetail"
            }
        }
    }
    End
    {
        Write-Output $doReturnInfo.domain
    }
}