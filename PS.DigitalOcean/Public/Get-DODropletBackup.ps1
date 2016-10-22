function Get-DODropletBackup
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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
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
   StartedAt    : Friday, November 14, 2014 8:29:21 AM
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
   PS.DigitalOcean.Backup

       A PS.DigitalOcean.Backup object holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdodb')]
    [OutputType('PS.DigitalOcean.Backup')]
    Param
    (
        # Used to get a specific action with the action ID.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64]$DropletID,
        # Used to override the default limit of 20.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Total','Size')]
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
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/droplets/$DropletID/backups?per_page=$Limit"
    }
    Process
    {
        try
        {
            $doInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
            foreach($info in $doInfo.backups)
            {
                $doReturnInfo = [PSCustomObject]@{
                    'BackupID' = $info.id
                    'Name' = $info.name
                    'Distribution' = $info.distribution
                    'Slug' = $info.slug
                    'Public' = $info.public
                    'Region' = $info.regions
                    'CreatedAt' = [datetime]$info.created_at
                    'Type' = $info.type
                    'MinimumDiskSize' = $info.min_disk_size
                }
                # DoReturnInfo is returned after Add-ObjectDetail is processed.
                Add-ObjectDetail -InputObject $doReturnInfo -TypeName 'PS.DigitalOcean.Backup'
            }
        }
        catch
        {
            $errorDetail = (Resolve-HTTPResponse -Responce $_.Exception.Responce) | ConvertFrom-Json
            Write-Error $errorDetail.message
        }
    }
}