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
                   PositionalBinding=$false,
                   DefaultParameterSetName='ImageSlug')]
    [Alias('ndovm')]
    [OutputType('PS.DigitalOcean.Droplet')]
    Param
    (
        # Used to specify the name of the droplet.
        [Parameter(Mandatory,Position=0,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=0,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        # Used to specify the image ID installed to the droplet.
        [Parameter(Mandatory=$false,Position=1,
                   ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64]$ImageID,
        # Used to specify the public SSH keys added to the droplet.
        [Parameter(Mandatory=$false,Position=2,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=4,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$SSHKey,
        # Used to specify if automatic backups are enabled for the droplet.
        [Parameter(Mandatory=$false,Position=3,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=5,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Backups,
        # Used to specify if IPv6 is enabled for the droplet.
        [Parameter(Mandatory=$false,Position=4,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=6,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$IPv6,
        # Used to specify if private networking is enabled for the droplet.
        [Parameter(Mandatory=$false,Position=5,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=7,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$PrivateNetworking,
        # Used to specify user data for the droplet.
        [Parameter(Mandatory=$false,Position=6,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=8,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$UserData,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,Position=7,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=9,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false,Position=8,
                   ParameterSetName='ImageID')]
        [Parameter(Mandatory=$false,Position=10,
                   ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey
    )

    DynamicParam {
        if($PSCmdlet.ParameterSetName -eq 'ImageSlug')
        {
            $sizes = Get-DOSize -APIKey $script:SavedDOAPIKey -ErrorAction Stop
            $images = Get-DOImage -Limit ([Int]::MaxValue) -APIKey $script:SavedDOAPIKey -ErrorAction Stop
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $regionParam = @{
                Name = 'Region'
                Type = [String]
                ValidateSet = $sizes.region | Sort-Object -Unique
                Mandatory = $true
                ParameterSetName = 'ImageSlug'
                Position = 1
                HelpMessage = 'Used to specify the regin the droplet is created.'
                DPDictionary = $Dictionary
            }
            $sizeParam = @{
                Name = 'Size'
                Type = [String]
                ValidateSet = $sizes.slug
                Mandatory = $true
                ParameterSetName = 'ImageSlug'
                Position = 2
                HelpMessage = 'Used to specify the size of the droplet.'
                DPDictionary = $Dictionary
            }
            $imageParam = @{
                Name = 'ImageSlug'
                Type = [String]
                ValidateSet = $images.slug | Sort-Object -Unique
                Mandatory = $true
                ParameterSetName = 'ImageSlug'
                Position = 3
                HelpMessage = 'Used to specify the image installed to the droplet.'
                DPDictionary = $Dictionary
            }

            New-DynamicParam @regionParam
            New-DynamicParam @sizeParam
            New-DynamicParam @imageParam

            return $Dictionary
        }
    }

    Begin
    {
        if(-not $APIKey){ throw 'Use Connect-DOCloud to specifiy the API key.' }
        #region
        # Here we add the variables for the dynamic parameters to the cmdlet's scope
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
        # Here we create the new VM request body
        [Hashtable]$sessionBodyBuild = @{}
        if($SSHKey){ $sessionBodyBuild += @{'ssh_keys'=$SSHKey} }
        if($Backups){ $sessionBodyBuild += @{'backups'=$true} }
        if($IPv6){ $sessionBodyBuild += @{'ipv6'=$true} }
        if($PrivateNetworking){ $sessionBodyBuild += @{'private_networking'=$true} }
        if($UserData){ $sessionBodyBuild += @{'user_data'=$UserData} }
        $sessionBodyBuild += @{'region'=$Region;'size'=$Size;'image'="$Image$ImageID"}# ImageID and Image should never be allowed to be set at the same time
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
        #endregion
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
                        'PSTypeName' = 'PS.DigitalOcean.Droplet'
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
                        'NextBackupWindow' = [nullable[datetime]]$doInfo.droplet.next_backup_window
                        'BackupID' = $doInfo.droplet.backup_ids
                        'SnapshotID' = $doInfo.droplet.snapshot_ids
                        'Image' = $doInfo.droplet.image
                        'Size' = $doInfo.droplet.size_slug
                        'Network' = $doInfo.droplet.networks
                        'Region' = $doInfo.droplet.region
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