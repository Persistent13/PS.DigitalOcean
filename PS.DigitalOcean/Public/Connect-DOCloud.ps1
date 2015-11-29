function Connect-DOCloud
{
<#
.Synopsis
   The Connect-DOCloud cmdlet sets the API key for the Digital Ocean module cmdlets.
.DESCRIPTION
   The Connect-DOCloud cmdlet sets the API key for the Digital Ocean module cmdlets.

   An API key is required to use this cmdlet.
.EXAMPLE
   Connect-DOCloud

   The above command will prompt for the API key and save it for use in other PS.DigitalOcean modules.

.EXAMPLE
   PS C:\>Connect-DOCloud -APIKey b7d03a6947b217efb6f3ec3bd3504582

   The above command will take the API key given and save it for use in other PS.DigitalOcean modules.

.INPUTS
   System.String
        
       This cmdlet can take the API key as a string.
.OUTPUTS
   None
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true)]
    [Alias('cdoc')]
    [OutputType()]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey
    )

    Begin
    {
        if(-not $APIKey)
        {
            $APIKey = (Get-Credential -Message 'Enter your API key below.' -UserName Bearer).GetNetworkCredential().Password
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/account/'
    }
    Process
    {
        try
        {
            $doReturnInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders
            $script:SavedDOAPIKey = $APIKey
        }
        catch
        {
            if(Test-Connection -ComputerName $doApiUri.DnsSafeHost -Port $doApiUri.Port)
            {
                Write-Error -Exception 'Unable to authenticate with given APIKey.' `
                    -Message 'Unable to authenticate with given APIKey.' -Category AuthenticationError
            }
            else
            {
                Write-Error -Exception "Cannot reach $doApiUri please check connecitvity." `
                    -Message "Cannot reach $doApiUri please check connecitvity." -Category ConnectionError
            }
        }
    }
    End
    {
        Write-Output $doReturnInfo.account
    }
}