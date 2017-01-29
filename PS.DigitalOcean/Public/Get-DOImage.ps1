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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
   CompletedAt  : Friday, November 14, 2014 8:30:06 AM
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   The example above returns the specfied action for the current API bearer.

.EXAMPLE
   PS C:\>Get-DOAction -ActionID 36804636, 36804637, 36804638

   ActionID     : 36804636
   Status       : completed
   Type         : create
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
   CompletedAt  : Friday, November 14, 2014 8:30:06 AM
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804637
   Status       : completed
   Type         : destroy
   StartedAt    : Friday, November 14, 2014 8:32:11 AM
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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
   CompletedAt  : Friday, November 14, 2014 8:30:06 AM
   ResourceID   : 3164444
   ResourceType : droplet
   Region       : nyc3

   ActionID     : 36804637
   Status       : completed
   Type         : destroy
   StartedAt    : Friday, November 14, 2014 8:32:11 AM
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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
   CompletedAt  : Friday, November 14, 2014 8:30:06 AM
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
   PS.DigitalOcean.Snapshot

       A PS.DigitalOcean.Snapshot object holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true,
                   DefaultParameterSetName='All')]
    [Alias('gdoa')]
    [OutputType('PS.DigitalOcean.Image')]
    Param
    (
        # List only distribution images.
        [Parameter(Mandatory=$false,ParameterSetName='Distribution')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Distribution,
        # List only application images.
        [Parameter(Mandatory=$false,ParameterSetName='Application')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Application,
        # List only private, user create images.
        [Parameter(Mandatory=$false,ParameterSetName='Private')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Private,
        # List only a specific image ID.
        [Parameter(Mandatory=$false,ParameterSetName='ImageID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID','SnapshotID','BackupID')]
        [UInt64[]]$ImageID,
        # List only a specific image slug.
        [Parameter(Mandatory=$false,ParameterSetName='ImageSlug')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Slug')]
        [String[]]$ImageSlug,
        # Used to override the default limit of 20.
        [Parameter(Mandatory=$false,ParameterSetName='Distribution')]
        [Parameter(Mandatory=$false,ParameterSetName='Application')]
        [Parameter(Mandatory=$false,ParameterSetName='Private')]
        [Parameter(Mandatory=$false,ParameterSetName='All')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt64]$Limit = 20,
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
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}

        switch($PSCmdlet.ParameterSetName)
        {
            # We use "; break" to make sure that only one option is taken
            'Distribution' { [Uri]$doApiUri = "https://api.digitalocean.com/v2/images?page=1&per_page=$Limit&distribution=true"; break }
            'Application' { [Uri]$doApiUri = "https://api.digitalocean.com/v2/images?page=1&per_page=$Limit&application=true"; break }
            'Private' { [Uri]$doApiUri = "https://api.digitalocean.com/v2/images?page=1&per_page=$Limit&private=true"; break }
            'ImageID' { [UInt64[]]$image = $ImageID; break }
            'ImageSlug' { [String[]]$image = $ImageSlug; break }
            Default { [Uri]$doApiUri = "https://api.digitalocean.com/v2/images?page=1&per_page=$Limit"; break }
        }
    }
    Process
    {
        try
        {
            if($PSCmdlet.ParameterSetName -in @('Distribution','Application','Private','All'))
            {
                $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders
                foreach($info in $doInfo.images)
                {
                    $doReturnInfo = [PSCustomObject]@{
                        'PSTypeName' = 'PS.DigitalOcean.Image'
                        'ImageID' = $info.id
                        'Name' = $info.name
                        'Distribution' = $info.distribution
                        'Slug' = $info.slug
                        'Public' = $info.public
                        'Region' = $info.regions
                        'CreatedAt' = [datetime]$info.created_at
                        'Type' = $info.type
                        'MinimumDiskSize' = $info.min_disk_size
                        #'Index' = [Array]::IndexOf($doInfo.images,$info) + 1
                        #Add the count in the ps1xml format!!!!
                    }
                    # Send object to pipeline.
                    Write-Output $doReturnInfo
                }
            }
            else
            {
                foreach($i in $image)
                {
                    [Uri]$doApiUri = "https://api.digitalocean.com/v2/images/$i"
                    $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders
                    $doReturnInfo = [PSCustomObject]@{
                        'PSTypeName' = 'PS.DigitalOcean.Image'
                        'ImageID' = $doInfo.image.id
                        'Name' = $doInfo.images.name
                        'Distribution' = $doInfo.image.distribution
                        'Slug' = $doInfo.image.slug
                        'Public' = $doInfo.image.public
                        'Region' = $doInfo.image.regions
                        'CreatedAt' = [datetime]$doInfo.image.created_at
                        'Type' = $doInfo.image.type
                        'MinimumDiskSize' = $doInfo.image.min_disk_size
                        'SizeGB' = $doInfo.image.size_gigabytes
                    }
                    # Send object to pipeline.
                    Write-Output $doReturnInfo
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