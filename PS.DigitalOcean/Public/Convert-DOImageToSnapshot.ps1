function Convert-DOImageToSnapshot
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
                   PositionalBinding=$true)]
    [Alias('cdois')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Used to specify the ID of the image(s) to convert.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$ImageID,
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
        if(-not $APIKey){ throw 'Use Connect-DOCloud to specifiy the API key.' }
        [Sting]$sessionBody = @{'type'='convert'} | ConvertTo-Json
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/images/'
    }
    Process
    {
        foreach($image in $ImageID)
        {
            try
            {
                if($Force -or $PSCmdlet.ShouldProcess("Move to $Region",$image))
                {
                    [Uri]$doApiUri = '{0}{1}' -f $doApiUri, "$image/actions"
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'PSTypeName' = 'PS.DigitalOcean.Action'
                        'ActionID' = $doInfo.action.id
                        'Status' = $doInfo.action.status
                        'Type' = $doInfo.action.type
                        'StartedAt' = [datetime]$doInfo.action.started_at
                        'CompletedAt' = [nullable[datetime]]$doInfo.action.completed_at
                        'ResourceID' = $doInfo.action.resource_id
                        'ResourceType' = $doInfo.action.resource_type
                        'Region' = $doInfo.action.region_slug
                    }
                    # Send object to pipeline.
                    Write-Output $doReturnInfo
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
}