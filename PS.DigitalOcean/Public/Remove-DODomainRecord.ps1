function Remove-DODomainRecord
{
<#
.Synopsis
   The Remove-DODomainRecord cmdlet deletes a domain record from the Digital Ocean cloud.
.DESCRIPTION
   The Remove-DODomainRecord cmdlet deletes a domain record from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Remove-DODomainrecord -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecordID 3352896

   The above command will remove the 3352896 domain ID from the bearer account. No object is returned.

.EXAMPLE
   PS C:\>Remove-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com -DomainRecordID 3352896, 3352897

   The above command will remove the 3352896 and 3352897 domain IDs from the bearer account. No object is returned.

.INPUTS
   System.String
        
       This cmdlet requires the API key and domain names to be passed as strings.
.OUTPUTS
   None
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High',
                   PositionalBinding=$true)]
    [Alias('rdodr')]
    [OutputType()]
    Param
    (
        # Used to specify the name of the domain name to delete.
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the name of the domain name to delete.
        [Parameter(Mandatory=$true, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$DomainRecordID,
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
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/domains/$DomainName/records/"
    }
    Process
    {
        foreach($domainID in $DomainRecordID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Deleting: $domainID"))
            {
                try
                {
                    $doApiUriWithDomainID = '{0}{1}' -f $doApiUri,$domainID
                    [void]Invoke-RestMethod -Method DELETE -Uri $doApiUriWithDomainID -Headers $sessionHeaders -ErrorAction Stop
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Unable to delete the domain record.`n`r$errorDetail"
                }
            }
        }
    }
}