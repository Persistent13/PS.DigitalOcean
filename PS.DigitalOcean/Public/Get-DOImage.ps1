function Get-DOImage
{
<#
.Synopsis
   The Get-DOAction cmdlet pulls action information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DOAction cmdlet pulls action information from the Digital Ocean cloud.
   Results are limited to 25 by default, to override this specifiy a larger number
   to return with the Limit paramter.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DOAction -ActionID 36804636

   ActionID     : 36804636
   Status       : completed
   Type         : create
   StartedAt    : 2014-11-14T16:29:21Z
   CompletedAt  : 2014-11-14T16:30:06Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   The example above returns the specfied action for the current API bearer.

.EXAMPLE
   PS C:\>Get-DOAction -ActionID 36804636, 36804637, 36804638

   ActionID     : 36804636
   Status       : completed
   Type         : create
   StartedAt    : 2014-11-14T16:29:21Z
   CompletedAt  : 2014-11-14T16:30:06Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804637
   Status       : completed
   Type         : destroy
   StartedAt    : 2014-11-14T16:32:11Z
   CompletedAt  : 2014-11-14T16:34:16Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804638
   Status       : completed
   Type         : transfer
   StartedAt    : 2014-11-14T16:37:51Z
   CompletedAt  : 2014-11-14T17:09:03Z
   ResourceID   : 3164445
   ResourceType : droplet
   Region       : nyc3

   The example above returns the specfied actions for the current API bearer if available.

.EXAMPLE
   PS C:\>Get-DOAction -Limit 3

   ActionID     : 36804636
   Status       : completed
   Type         : create
   StartedAt    : 2014-11-14T16:29:21Z
   CompletedAt  : 2014-11-14T16:30:06Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804637
   Status       : completed
   Type         : destroy
   StartedAt    : 2014-11-14T16:32:11Z
   CompletedAt  : 2014-11-14T16:34:16Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804638
   Status       : completed
   Type         : transfer
   StartedAt    : 2014-11-14T16:37:51Z
   CompletedAt  : 2014-11-14T17:09:03Z
   ResourceID   : 3164445
   ResourceType : droplet
   Region       : nyc3

   The example above returns the specfied actions for the current API bearer if available.

.EXAMPLE
   PS C:\>Get-DOAction -ActionID 36804636 -APIKey b7d03a6947b217efb6f3ec3bd3504582

   ActionID     : 36804636
   Status       : completed
   Type         : create
   StartedAt    : 2014-11-14T16:29:21Z
   CompletedAt  : 2014-11-14T16:30:06Z
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   The example above returns all avaiable actions for the current API bearer without
   authenticating via Connect-DOCloud first.

.INPUTS
   System.String
        
       This cmdlet requires the API key to be passed as a string.

   System.UInt64
       
       This cmdlet requires the action ID to be passed as an unsigned, 16-bit interger.
.OUTPUTS
   PS.DigitalOcean.Action

       A PS.DigitalOcean.Action object holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdoa')]
    [OutputType('PS.DigitalOcean.Action')]
    Param
    (
        # Used to get a specific action with the action ID.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID','SnapshotID','BackupID')]
        [UInt64[]]$ImageID,
        # Used to override the default limit of 20.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Total','Size')]
        [UInt64]$Limit,
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=2)]
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
        if(-not $Limit)
        {
            [Uri]$doApiUri = 'https://api.digitalocean.com/v2/images/'
        }
        else
        {
            [Uri]$doApiUri = "https://api.digitalocean.com/v2/images?per_page=$Limit"
        }
    }
    Process
    {
        if(-not $ImageID)
        {
            try
            {
                $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
                foreach($info in $doInfo.images)
                {
                    $doReturnInfo = [PSCustomObject]@{
                        'ImageID' = $info.id
                        'Name' = $info.name
                        'Distribution' = $info.distribution
                        'Slug' = $info.slug
                        'Public' = $info.public
                        'Regions' = $info.regions
                        'CreatedAt' = $info.created_at
                        'Type' = $info.type
                        'MinimumDiskSize' = $info.min_disk_size
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Action'
                }
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Could not find any action information.`n`r$errorDetail"
            }
        }
        else
        {
            foreach($id in $ImageID)
            {
                try
                {
                    $doApiUriWithID = '{0}{1}' -f $doApiUri,$id
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithID -Headers $sessionHeaders -ErrorAction Stop
                    $doReturnInfo = [PSCustomObject]@{
                        'ImageID' = $doInfo.images.id
                        'Name' = $doInfo.images.name
                        'Distribution' = $doInfo.images.distribution
                        'Slug' = $doInfo.images.slug
                        'Public' = $doInfo.images.public
                        'Regions' = $doInfo.images.regions
                        'CreatedAt' = $doInfo.images.created_at
                        'Type' = $doInfo.images.type
                        'MinimumDiskSize' = $doInfo.images.min_disk_size
                    }
                    # DoReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Action'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Could not find any action information for ID $id.`n`r$errorDetail"
                }
            }
        }
    }
}