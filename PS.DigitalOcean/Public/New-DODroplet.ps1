function New-DODroplet
{
<#
.Synopsis
   The New-DODroplet cmdlet creats a new droplet in the Digital Ocean cloud.
   Access to droplets over 2gb must be requted from Digital Ocean support.
.DESCRIPTION
   The New-DODroplet cmdlet creats a new droplet in the Digital Ocean cloud.
   Access to droplets over 2gb must be requted from Digital Ocean support.

   An API key is required to use this cmdlet.
.EXAMPLE
   New-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582 -Name example.com -region nyc3 -Size 512mb -Image ubuntu-15-04-x64

   id           : 3164494
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : True
   status       : new
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:36:31Z
   features     : {virtio}
   backup_ids   : {}
   snapshot_ids : {}
   image        :
   size         :
   size_slug    : 512mb
   networks     :
   region       :

   The example above creates a droplet with the name of example.com, with a size of 512mb, with an Ubuntu 15.05 64-bit image and is located in the New York City 3 region. The root password will be emailed to you.

.EXAMPLE
   PS C:\>New-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582 -Name example.com -region nyc3 -Size 2gb -Image ubuntu-15-04-x64 -SSHKey 'ad:83:97:e7:f6:84:5f:72:d0:1f:13:55:86:93:8c:35','d1:c4:d1:27:21:bd:ca:5d:b4:2d:be:75:90:ef:77:a1'

   id           : 3164494
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : True
   status       : new
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:36:31Z
   features     : {virtio}
   backup_ids   : {}
   snapshot_ids : {}
   image        :
   size         :
   size_slug    : 512mb
   networks     :
   region       :

   The example above creates a droplet with the name of example.com, with a size of 512mb, with an Ubuntu 15.05 64-bit image, it is located in the New York City 3 region, and addes two SSH keys specified by their fingerprints.
   The SSH keys must already be available in the digital ocean cloud to be used. No root password will be emailed when a SSH key is specified.

.EXAMPLE
   PS C:\>New-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582 -Name example.com -region nyc3 -Size 2gb -ImageID 6376601

   id           : 3164495
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : True
   status       : new
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:36:31Z
   features     : {virtio}
   backup_ids   : {}
   snapshot_ids : {}
   image        :
   size         :
   size_slug    : 512mb
   networks     :
   region       :

   The example above creates a droplet from the private snapshot image with the ID of 6376601. The droplet must be created in the same region the snapshot inhabits or else the cmdlet will fail.

.INPUTS
   System.String
        
       This cmdlet requires the API key, domain name, record type, target, and domain record to be passed as strings.

   System.UInt16

       This cmdlet requires the priority, port, and weigth to be passed as 16-bit, unsiged integers.
.OUTPUTS
   PS.DigitalOcean.Droplet

       A PS.DigitalOcean.Droplet object holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Low',
                   PositionalBinding=$true)]
    [Alias('ndovm')]
    [OutputType('PS.DigitalOcean.Droplet')]
    Param
    (
        # Used to specify the name of the droplet.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        # Used to specify the regin the droplet is created.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ams1','ams2','ams3','fra1','lon1','nyc1','nyc2','nyc3','sfo1','sgp1','tor1')]
        [String]$Region,
        # Used to specify the size of the droplet.
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('512mb','1gb','2gb','4gb','8gb','16gb','32gb','48gb','64gb')]
        [String]$Size,
        # Used to specify the image installed to the droplet.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('centos-5-8-x32','centos-5-8-x64','centos-6-5-x32','centos-6-5-x64','coreos-beta',`
                     'debian-6-0-x32','debian-6-0-x64','debian-7-0-x32','debian-7-0-x64','debian-8-x32','debian-8-x64',`
                     'fedora-21-x64','fedora-22-x64','freebsd-10-1-x64','ubuntu-12-04-x32','ubuntu-12-04-x64',`
                     'ubuntu-14-04-x32','ubuntu-14-04-x64','ubuntu-15-04-x32','ubuntu-15-04-x64','ubuntu-15-10-x32',`
                     'ubuntu-15-10-x64')]
        [String]$Image,
        # Used to specify the image ID installed to the droplet.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64]$ImageID,
        # Used to specify the public SSH keys added to the droplet.
        [Parameter(Mandatory=$false,
                   Position=5)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$SSHKey,
        # Used to specify if automatic backups are enabled for the droplet.
        [Parameter(Mandatory=$false,
                   Position=6)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Backups,
        # Used to specify if IPv6 is enabled for the droplet.
        [Parameter(Mandatory=$false,
                   Position=7)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$IPv6,
        # Used to specify if private networking is enabled for the droplet.
        [Parameter(Mandatory=$false,
                   Position=8)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$PrivateNetworking,
        # Used to specify user data for the droplet.
        [Parameter(Mandatory=$false,
                   Position=9)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$UserData,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=10)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false,
                   Position=11)]
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
        if(-not $Image -and -not $ImageID)
        {
            throw 'You must specifiy either an image or image ID.'
        }
        [Hashtable]$sessionBodyBuild = @{}
        if($Image)
        {
            $sessionBodyBuild += @{'image'=$Image}
        }
        if($ImageID)
        {
            $sessionBodyBuild += @{'image'=$ImageID}
        }
        if($SSHKey)
        {
            $sessionBodyBuild += @{'ssh_keys'=$SSHKey}
        }
        else
        {
            $SSHKey = $false
        }
        if($Backups)
        {
            $sessionBodyBuild += @{'backups'=$true}
        }
        if($IPv6)
        {
            $sessionBodyBuild += @{'ipv6'=$true}
        }
        if($PrivateNetworking)
        {
            $sessionBodyBuild += @{'private_networking'=$true}
        }
        if($UserData)
        {
            $sessionBodyBuild += @{'user_data'=$UserData}
        }
        $sessionBodyBuild += @{'region'=$Region;'size'=$Size}
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        foreach($droplet in $Name)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Droplet creation with Name: $droplet Image: $Image$ImageID Region: $Region Size: $Size SSH Key: $SSHKey Backups: $Backups IPv6: $IPv6 PrivateNetworking: $PrivateNetworking UserData: $UserData"))
            {
                try
                {
                    [String]$sessionBodyWithName = $sessionBodyBuild + @{'name'=$droplet} | ConvertTo-Json
                    $doInfo = Invoke-RestMethod -Method POST -Uri $doApiUri -Headers $sessionHeaders -Body $sessionBodyWithName -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'DropletID' = $doInfo.droplet.id
                        'Name' = $doInfo.droplet.name
                        'Memory' = $doInfo.droplet.memory
                        'CPU' = $doInfo.droplet.vcpus
                        'DiskGB' = $doInfo.droplet.disk
                        'Locked' = $doInfo.droplet.locked
                        'Status' = $doInfo.droplet.status
                        'CreatedAt' = $doInfo.droplet.created_at
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
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Unable to create the droplet.`n`r$errorDetail"
                }
            }
        }
    }
}