function Restart-DODroplet
{
<#
.Synopsis
   The Restart-DODroplet cmdlet is used to restart a droplet in the Digital Ocean cloud.
.DESCRIPTION
   The Restart-DODroplet cmdlet is used to restart a droplet in the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Restart-DODroplet -DropleID 3164450

   id            : 36804748
   status        : in-progress
   type          : reboot
   started_at    : 2014-11-14T16:31:00Z
   completed_at  :
   resource_id   : 3164450
   resource_type : droplet
   region        : nyc3
   region_slug   : nyc3

   The example above restart the droplet resulting in a graceful shutdown.
   The action object preforming the work is returned with status information.

.EXAMPLE
   PS C:\>Restart-DODroplet -DropletID 3164450 -Reset

   id            : 36804749
   status        : in-progress
   type          : power_cycle
   started_at    : 2014-11-14T16:31:03Z
   completed_at  :
   resource_id   : 3164450
   resource_type : droplet
   region        : nyc3
   region_slug   : nyc3

   The example above power cycles the droplet resulting in a non-graceful reboot, like pressing the reset button on a physical computer.
   The action object preforming the work is returned with status information.

.INPUTS
   System.String

       This cmdlet can use the APIKey to authenticate independent from Connect-DOCloud.

   System.UInt16

       This cmdlet requires the droplet ID to be passed as 64-bit, unsiged integer.
.OUTPUTS
   PS.DigitalOcean.Action

       A PS.DigitalOcean.Action object holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Medium',
                   PositionalBinding=$true)]
    [Alias('ndovm')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Used to specify the name of the droplet.
        [Parameter(Mandatory,
                   ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64[]]$DropletID,
        # Used to force a power cycle of the droplet.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Reset,
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
        #region
        # Here we set the VM to either gracefully restart (power_cycle)
        # or forefully restart (reset)
        if($Reset){ [String]$sessionBody = @{'type'='power_cycle'} | ConvertTo-Json }
        else{ [String]$sessionBody = @{'type'='reset'} | ConvertTo-Json }
        #endregion
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        foreach($droplet in $DropletID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Restarting droplet ID: $droplet."))
            {
                try
                {
                    [Uri]$doApiUriWithDropletID = '{0}{1}' -f $doApiUri,"$droplet/actions/"
                    $doInfo = Invoke-RestMethod -Method POST -Uri $doApiUriWithDropletID -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'ActionID' = $doInfo.action.id
                        'Status' = $doInfo.action.status
                        'Type' = $doInfo.action.type
                        'StartedAt' = [datetime]$doInfo.action.started_at
                        'CompletedAt' = [datetime]$doInfo.action.completed_at
                        'ResourceID' = $doInfo.action.resource_id
                        'ResourceType' = $doInfo.action.resource_type
                        'Region' = $doInfo.action.region_slug
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Action'
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
}