function Resize-DODroplet
{
<#
.Synopsis
   The Reset-DODropletPassword cmdlet is used to reset the root password for a droplet in the Digital Ocean cloud.
.DESCRIPTION
   The Reset-DODropletPassword cmdlet is used to reset the root password for a droplet in the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Reset-DODropletPassword -DropleID 3164450

   ActionID      : 36804748
   Status        : in-progress
   Type          : reboot
   StartedAt     : 2014-11-14T16:31:00Z
   CompletedAt   :
   ResourceID    : 3164450
   ResourceType  : droplet
   Region        : nyc3

   The example above restart the droplet resulting in a graceful shutdown.
   The action object preforming the work is returned with status information.

.EXAMPLE
   PS C:\>Reset-DODropletPassword -DropletID 3164450 -Reset

   ActionID      : 36804749
   Status        : in-progress
   Type          : power_cycle
   StartedAt     : 2014-11-14T16:31:03Z
   CompletedAt   :
   ResourceID    : 3164450
   ResourceType  : droplet
   Region        : nyc3

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
                   ConfirmImpact='Low',
                   PositionalBinding=$true)]
    [Alias('rdodp')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Used to specify the name of the droplet.
        [Parameter(Mandatory,
                   ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64[]]$DropletID,
        # Used to specify the size of the droplet.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('512mb','1gb','2gb','4gb','8gb','16gb','32gb','48gb','64gb')]
        [String]$Size,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Permanent,
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
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [String]$sessionBody = @{'type'='resize';'disk'=$Permanent;'size'=$Size} | ConvertTo-Json
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        foreach($droplet in $DropletID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Enabling backups for droplet ID: $droplet."))
            {
                try
                {
                    $doApiUriWithDropletID = '{0}{1}' -f $doApiUri,"$droplet/actions/"
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
                    $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Responce) | ConvertFrom-Json
                    Write-Error $errorDetail.message
                }
            }
        }
    }
}