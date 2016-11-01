function Get-DODroplet
{
<#
.Synopsis
   The Get-DODroplet cmdlet pulls droplet information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DODroplet cmdlet pulls droplet information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582

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
   PS C:\>Get-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DropletID 3164444, 3164445

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
   PS.DigitalOcean.Droplet

       A PS.DigitalOcean.Droplet object holding the droplet info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true,
                   DefaultParameterSetName='All')]
    [Alias('gdovm')]
    [OutputType('PS.DigitalOcean.Droplet')]
    Param
    (
        # Retrieve all droplets associated with the account.
        [Parameter(Mandatory=$false,ParameterSetName='All')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$All,
        # Tag to filter results by.
        [Parameter(Mandatory=$false,ParameterSetName='Tag')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Tag,
        # ID of the droplet to retrieve.
        [Parameter(Mandatory=$false,ParameterSetName='DropletID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$DropletID,
        # API key to access account.
        [Parameter(Mandatory=$false,ParameterSetName='DropletID')]
        [Parameter(Mandatory=$false,ParameterSetName='Tag')]
        [Parameter(Mandatory=$false,ParameterSetName='All')]
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
                'All' {
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
                    foreach($info in $doInfo.droplets)
                    {
                        $doReturnInfo = [PSCustomObject]@{
                            'DropletID' = $info.id
                            'Name' = $info.name
                            'Memory' = $info.memory
                            'CPU' = $info.vcpus
                            'DiskGB' = $info.disk
                            'Locked' = $info.locked
                            'Status' = $info.status
                            'CreatedAt' = [datetime]$info.created_at
                            'Features' = $info.features
                            'Kernel' = $info.kernel
                            'NextBackupWindow' = $info.next_backup_window
                            'BackupID' = $info.backup_ids
                            'SnapshotID' = $info.snapshot_ids
                            'Image' = $info.image
                            'Size' = $info.size_slug
                            'Network' = $info.networks
                            'Region' = $info.region
                        }
                        # DoReturnInfo is returned after Add-ObjectDetail is processed.
                        Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Droplet'
                    }
                }
                'Tag' {
                    foreach($t in $Tag)
                    {
                        [Uri]$doApiUri = '{0}{1}' -f $doApiUri,"?tag_name=$t"
                        $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
                        foreach($info in $doInfo.droplets)
                        {
                            $doReturnInfo = [PSCustomObject]@{
                                'DropletID' = $info.id
                                'Name' = $info.name
                                'Memory' = $info.memory
                                'CPU' = $info.vcpus
                                'DiskGB' = $info.disk
                                'Locked' = $info.locked
                                'Status' = $info.status
                                'CreatedAt' = [datetime]$info.created_at
                                'Features' = $info.features
                                'Kernel' = $info.kernel
                                'NextBackupWindow' = $info.next_backup_window
                                'BackupID' = $info.backup_ids
                                'SnapshotID' = $info.snapshot_ids
                                'Image' = $info.image
                                'Size' = $info.size_slug
                                'Network' = $info.networks
                                'Region' = $info.region
                            }
                            # DoReturnInfo is returned after Add-ObjectDetail is processed.
                            Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Droplet'
                        }
                    }
                }
                'DropletID' {
                    foreach($droplet in $DropletID)
                    {
                        [Uri]$doApiUriWithID = '{0}{1}' -f $doApiUri,$droplet
                        $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithID -Headers $sessionHeaders -ErrorAction Stop
                        $doReturnInfo = [PSCustomObject]@{
                            'DropletID' = $doInfo.droplet.id
                            'Name' = $doInfo.droplet.name
                            'Memory' = $doInfo.droplet.memory
                            'CPU' = $doInfo.droplet.vcpus
                            'DiskGB' = $doInfo.droplet.disk
                            'Locked' = $doInfo.droplet.locked
                            'Status' = $doInfo.droplet.status
                            'CreatedAt' = [datetime]$doInfo.droplet.created_at
                            'Features' = $doInfo.droplet.features
                            'Kernel' = $doInfo.droplet.kernel
                            'NextBackupWindow' = $doInfo.droplet.next_backup_window
                            'BackupID' = $doInfo.droplet.backup_ids
                            'SnapshotID' = $doInfo.droplet.snapshot_ids
                            'Image' = $doInfo.droplet.image
                            'Size' = $doInfo.droplet.size_slug
                            'Network' = $doInfo.droplet.networks
                            'Region' = $doInfo.droplet.region
                        }
                        # DoReturnInfo is returned after Add-ObjectDetail is processed.
                        Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Droplet'
                    }
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