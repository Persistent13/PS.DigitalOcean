function Get-DOUser
{
<#
.Synopsis
   The Get-DOUser cmdlet pulls user information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DOUser cmdlet pulls user information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DOUser -APIKey b7d03a6947b217efb6f3ec3bd3504582

   droplet_limit  : 25
   email          : sammy@digitalocean.com
   uuid           : b6fr89dbf6d9156cace5f3c78dc9851d957381ef
   email_verified : True
   status         : active
   status_message : 

   The example above returns the information for the current API bearer.
.INPUTS
   System.String
        
       This cmdlet requires the API key to be passed as a string.
.OUTPUTS
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the account info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdou')]
    [OutputType([PSCustomObject])]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $global:SavedDOAPIKey
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/account/'
    }
    Process
    {
        try
        {
            $doReturnInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Warning "Could not pull user information for the bearer.`n`r$errorDetail"
        }
    }
    End
    {
        Write-Output $doReturnInfo.account
    }
}