function Initialize-DODroplet
{
<#
.Synopsis
   The Restore-DODropletSnapshot cmdlet restores a droplet to a specified backup image.
.DESCRIPTION
   The Restore-DODropletSnapshot cmdlet restores a droplet to a specified backup image.

   An API key is required to use this cmdlet.
.EXAMPLE
   Restore-DODropletSnapshot -APIKey b7d03a6947b217efb6f3ec3bd3504582

   id           : 3164444
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : Friday, November 14, 2014 8:29:21 AM
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938002}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True;
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         :
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   The example above returns the information for all droplets available to the current API bearer.

.EXAMPLE
   PS C:\>Restore-DODropletSnapshot -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DropletID 3164444, 3164445

   id           : 3164444
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : Friday, November 14, 2014 8:29:21 AM
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938002}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True;
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         :
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   id           : 3164445
   name         : example.org
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : Friday, November 14, 2014 8:42:36 AM
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938003}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True;
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         :
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   The example above returns the information for all the specified droplet IDs available to the current API bearer.

.INPUTS
   System.String

       This cmdlet requires the API key to be passed as a string.

   System.UInt64

       This cmdlet requires the droplet ID to be passed as a 64-bit, unsiged integer.
.OUTPUTS
   PS.DigitalOcean.Action

       A PS.DigitalOcean.Action object holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High',
                   PositionalBinding=$false,
                   DefaultParameterSetName='ImageSlug')]
    [Alias('idovm')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Uniqe ID of the Droplet.
        [Parameter(Mandatory,Position=0,
                   ParameterSetName='ImageSlug')]
        [Parameter(Mandatory,Position=0,
                   ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$DropletID,
        # Uniqe ID of the image to install.
        [Parameter(Mandatory,Position=1,
                   ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ImageID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,Position=2,
                   ParameterSetName='ImageSlug')]
        [Parameter(Mandatory=$false,Position=2,
                   ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false,Position=3,
                   ParameterSetName='ImageSlug')]
        [Parameter(Mandatory=$false,Position=3,
                   ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey
    )

    DynamicParam {
        # A rebuild can only be started from a private image
        # so we add that switch here
        $images = Get-DOImage -Limit ([Int]::MaxValue) -APIKey $script:SavedDOAPIKey -ErrorAction Stop
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $imageParam = @{
            Name = 'ImageSlug'
            Type = [String]
            ValidateSet = $images.slug | Sort-Object -Unique
            Mandatory = $true
            ParameterSetName = 'ImageSlug'
            Position = 1
            HelpMessage = 'Used to specify the image installed to the droplet.'
            DPDictionary = $Dictionary
        }

        New-DynamicParam @imageParam
        return $Dictionary
    }

    Begin
    {
        if(-not $APIKey){ throw 'Use Connect-DOCloud to specifiy the API key.' }
        #region
        # Here we add the variables for the dynamic parameters
        if($PSCmdlet.ParameterSetName -eq 'ImageSlug')
        {
            function _temp {[CmdletBinding()] Param()}
            $boundKeys = $PSBoundParameters.keys | Where-Object {(Get-Command _temp | Select-Object -ExpandProperty parameters).Keys -notcontains $_}
            foreach($param in $boundKeys)
            {
                if(-not(Get-Variable -Name $param -Scope 0 -ErrorAction SilentlyContinue))
                {
                    New-Variable -Name $Param -Value $PSBoundParameters.$param
                    Write-Verbose -Message "Adding variable for dynamic parameter '$param' with value '$($PSBoundParameters.$param)'"
                }
            }
        }
        #endregion
        #region
        # Here we build the request body
        [String]$sessionBody = @{'type'='rebuild';'image'="$ImageSlug$ImageID"} | ConvertTo-Json
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
        #endregion
    }
    Process
    {
        foreach($droplet in $DropletID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Restoring image $ImageID$ImageSlug for $droplet."))
            {
                try
                {
                    [Uri]$doApiUriWithID = '{0}{1}' -f $doApiUri,"$droplet/actions"
                    $doInfo = Invoke-RestMethod -Method Post -Uri $doApiUriWithID -Headers $sessionHeaders -Body $sessionBody -ErrorAction Stop
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