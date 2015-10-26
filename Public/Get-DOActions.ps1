function Get-DOAction
{
<#
.Synopsis
   The Get-DOAction cmdlet pulls action information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DOAction cmdlet pulls action information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DOAction -APIKey b7d03a6947b217efb6f3ec3bd3504582

   id            : 36804636
   status        : completed
   type          : create
   started_at    : 2014-11-14T16:29:21Z
   completed_at  : 2014-11-14T16:30:06Z
   resource_id   : 3164444
   resource_type : droplet
   region        : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=True}
   region_slug   : nyc3

   The example above returns all avaiable actions for the current API bearer.

.EXAMPLE
   PS C:\>Get-DOAction -APIKey b7d03a6947b217efb6f3ec3bd3504582 -ActionID 36804636, 36804637, 36804638

   id            : 36804636
   status        : completed
   type          : create
   started_at    : 2014-11-14T16:29:21Z
   completed_at  : 2014-11-14T16:30:06Z
   resource_id   : 3164444
   resource_type : droplet
   region        : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=True}
   region_slug   : nyc3

   id            : 36804637
   status        : completed
   type          : destroy
   started_at    : 2014-11-14T16:32:11Z
   completed_at  : 2014-11-14T16:34:16Z
   resource_id   : 3164444
   resource_type : droplet
   region        : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=True}
   region_slug   : nyc3

   id            : 36804638
   status        : completed
   type          : transfer
   started_at    : 2014-11-14T16:37:51Z
   completed_at  : 2014-11-14T17:09:03Z
   resource_id   : 3164445
   resource_type : droplet
   region        : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=True}
   region_slug   : nyc3

   The example above returns the specfied actions for the current API bearer if available.

.INPUTS
   System.String
        
       This cmdlet requires the API key to be passed as a string.

   System.UInt16
       
       This cmdlet requires the action ID to be passed as an unsigned, 16-bit interger.
.OUTPUTS
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the action info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdoa')]
    [OutputType([PSCustomObject])]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey,
        # Used to get a specific action with the action ID.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$ActionID
    )

    Begin
    {
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/actions/'
    }
    Process
    {
        if(-not $ActionID)
        {
            try
            {
                $doReturnInfo = Invoke-RestMethod -Method GET -Uri $doApiUri -Headers $sessionHeaders -ErrorAction Stop
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Warning "Could not find any action information.`n`r$errorDetail"
            }
        }
        else
        {
            $doReturnInfo = @()
            foreach($id in $ActionID)
            {
                try
                {
                    $doApiUriWithID = '{0}{1}' -f $doApiUri,$id
                    $doReturnInfo += Invoke-RestMethod -Method GET -Uri $doApiUriWithID -Headers $sessionHeaders -ErrorAction Stop
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Could not find any action information for ID $id.`n`r$errorDetail"
                }
            }
        }
    }
    End
    {
        if(-not $ActionID)
        {
            Write-Output $doReturnInfo.actions
        }
        else
        {
            Write-Output $doReturnInfo.action
        }
    }
}