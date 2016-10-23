function Remove-DOImage
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
                   PositionalBinding=$true)]
    [Alias('rdoi')]
    [OutputType()]
    Param
    (
        # Uniqe ID of the image to update.
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
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/images/"
    }
    Process
    {
        foreach($image in $ImageID)
        {
            if($Force -or $PSCmdlet.ShouldProcess($image))
            {
                try
                {
                    $doApiUriWithImageID = '{0}{1}' -f $doApiUri,$image
                    Invoke-RestMethod -Method POST -Uri $doApiUriWithImageID -Headers $sessionHeaders | Out-Null
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