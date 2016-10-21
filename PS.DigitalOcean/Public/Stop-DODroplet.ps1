function Stop-DODroplet
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
   PS.DigitalOcean.Action

       A PS.DigitalOcean.Action object holding the domain info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Medium',
                   PositionalBinding=$true)]
    [Alias('sdovm')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Used to specify the name of the droplet.
        [Parameter(Mandatory,
                   ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64[]]$DropletID,
        # Used to force a shutdown of the droplet.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('PowerOff')]
        [Switch]$TurnOff,
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
        if($TurnOff)
        {
            [String]$sessionBody = @{'type'='power_off'} | ConvertTo-Json
        }
        else
        {
            [String]$sessionBody = @{'type'='shutdown'} | ConvertTo-Json
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        $doInfo = @()
        foreach($droplet in $DropletID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Stoping droplet ID: $droplet."))
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
                    $errorDetail = (Resolve-HTTPResponce -Responce $_.Exception.Response) | ConvertFrom-Json
                    Write-Error $errorDetail.message
                }
            }
        }
    }
}