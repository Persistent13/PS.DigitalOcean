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
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('rdodr')]
    [OutputType()]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $global:SavedDOAPIKey,
        # Used to specify the name of the domain name to delete.
        [Parameter(Mandatory=$true, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,
        # Used to specify the name of the domain name to delete.
        [Parameter(Mandatory=$true, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$DomainRecordID
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
        $doReturnInfo = @()
        foreach($domainID in $DomainRecordID)
        {
            try
            {
                $doApiUriWithDomainID = '{0}{1}' -f $doApiUri,$domainID
                $doReturnInfo += Invoke-RestMethod -Method DELETE -Uri $doApiUriWithDomainID -Headers $sessionHeaders -ErrorAction Stop
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Unable to delete the domain record.`n`r$errorDetail"
            }
        }
    }
    End
    {
        Write-Output $doReturnInfo
    }
}