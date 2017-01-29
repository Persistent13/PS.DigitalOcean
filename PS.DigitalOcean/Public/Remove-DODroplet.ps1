function Remove-DODroplet
{
<#
.Synopsis
   The Remove-DODomain cmdlet deletes domain information from the Digital Ocean cloud.
.DESCRIPTION
   The Remove-DODomain cmdlet deletes domain information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Remove-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com

   The above command will remove the example.com domain from the bearer account. No object is returned.

.EXAMPLE
   PS C:\>Remove-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com, example.org

   The above command will remove the example.com and example.org domains from the bearer account. No object is returned.

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
                   PositionalBinding=$true,
                   DefaultParameterSetName='Tag')]
    [Alias('rdovm')]
    [OutputType()]
    Param
    (
        # Used to specify the tag of the droplet(s) to delete.
        [Parameter(Mandatory,ParameterSetName='Tag')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Tag,
        # Used to specify the ID of the droplet(s) to delete.
        [Parameter(Mandatory,ParameterSetName='DropletID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$DropletID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,ParameterSetName='DropletID')]
        [Parameter(Mandatory=$false,ParameterSetName='Tag')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false,ParameterSetName='DropletID')]
        [Parameter(Mandatory=$false,ParameterSetName='Tag')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey
    )

    Begin
    {
        if(-not $APIKey){ throw 'Use Connect-DOCloud to specifiy the API key.' }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        try
        {
            switch($PSCmdlet.ParameterSetName)
            {
                'Tag' {
                    foreach($t in $Tag)
                    {
                        if($Force -or $PSCmdlet.ShouldProcess("Deleting droplets tagged: $t."))
                        {
                            [Uri]$doApiUri = '{0}{1}' -f $doApiUri,"?tag_name=$t"
                            Invoke-RestMethod -Method DELETE -Uri $doApiUri -Headers $sessionHeaders | Out-Null
                        }
                    }
                    # End switch comparison
                    break
                }
                'DropletID' {
                    foreach($droplet in $DropletID)
                    {
                        if($Force -or $PSCmdlet.ShouldProcess("Deleting: $droplet."))
                        {
                            [Uri]$doApiUri = '{0}{1}' -f $doApiUri,$droplet
                            Invoke-RestMethod -Method DELETE -Uri $doApiUri -Headers $sessionHeaders | Out-Null
                        }
                    }
                    # End switch comparison
                    break
                }
            }
        }
        catch
        {
            if($_.Exception.Response)
            {
                # Convert a 400-599 error to something useable.
                $errorDetail = (Resolve-HTTPResponse -Response $_.Exception.Response) | ConvertFrom-Json
                Write-Error -Message $errorDetail.message
            }
            else
            {
                # Return the error as is.
                Write-Error -Message $_
            }
        }
    }
}