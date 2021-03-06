﻿function Get-DODroplet
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
   created_at   : 2014-11-14T16:29:21Z
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
   created_at   : 2014-11-14T16:29:21Z
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
   created_at   : 2014-11-14T16:42:36Z
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
                  PositionalBinding=$true)]
    [Alias('gdovm')]
    [OutputType('PS.DigitalOcean.Droplet')]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey,
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$DropletID
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        if(-not $DropletID)
        {
            try
            {
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
                        'CreatedAt' = $info.created_at
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
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Could not pull the droplet information.`n`r$errorDetail"
            }
        }
        else
        {

            foreach($droplet in $DropletID)
            {
                try
                {
                    $doApiUriWithID = '{0}{1}' -f $doApiUri,$droplet
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithID -Headers $sessionHeaders -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'DropletID' = $info.droplet.id
                        'Name' = $info.droplet.name
                        'Memory' = $info.droplet.memory
                        'CPU' = $info.droplet.vcpus
                        'DiskGB' = $info.droplet.disk
                        'Locked' = $info.droplet.locked
                        'Status' = $info.droplet.status
                        'CreatedAt' = $info.droplet.created_at
                        'Features' = $info.droplet.features
                        'Kernel' = $info.droplet.kernel
                        'NextBackupWindow' = $info.droplet.next_backup_window
                        'BackupID' = $info.droplet.backup_ids
                        'SnapshotID' = $info.droplet.snapshot_ids
                        'Image' = $info.droplet.image
                        'Size' = $info.droplet.size_slug
                        'Network' = $info.droplet.networks
                        'Region' = $info.droplet.region
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Droplet'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Could not pull the droplet information for $droplet.`n`r$errorDetail"
                }
            }
        }
    }
}