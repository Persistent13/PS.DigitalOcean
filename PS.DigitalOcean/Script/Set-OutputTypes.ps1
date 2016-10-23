if(-not $(Get-TypeData -TypeName 'PS.DigitalOcean.*'))
{
    #Adds action OutputType
    $action = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Action'
        Value = $null
    }

    Update-TypeData @action -MemberName ActionID
    Update-TypeData @action -MemberName Status
    Update-TypeData @action -MemberName Type
    Update-TypeData @action -MemberName StartedAt
    Update-TypeData @action -MemberName CompletedAt
    Update-TypeData @action -MemberName ResourceID
    Update-TypeData @action -MemberName ResourceType
    Update-TypeData @action -MemberName Region

    #Adds domain OutputType
    $domain = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Domain'
        Value = $null
    }

    Update-TypeData @domain -MemberName Name
    Update-TypeData @domain -MemberName TTL
    Update-TypeData @domain -MemberName ZoneFile

    #Adds domain record OutputType
    $domainRecord = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.DomainRecord'
        Value = $null
    }

    Update-TypeData @domainRecord -MemberName ID
    Update-TypeData @domainRecord -MemberName Type
    Update-TypeData @domainRecord -MemberName Name
    Update-TypeData @domainRecord -MemberName Data
    Update-TypeData @domainRecord -MemberName Priority
    Update-TypeData @domainRecord -MemberName Port
    Update-TypeData @domainRecord -MemberName Weight

    #Adds droplet OutputType
    $droplet = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Droplet'
        Value = $null
    }

    Update-TypeData @droplet -MemberName DropletID
    Update-TypeData @droplet -MemberName Name
    Update-TypeData @droplet -MemberName Memory
    Update-TypeData @droplet -MemberName CPU
    Update-TypeData @droplet -MemberName DiskGB
    Update-TypeData @droplet -MemberName Locked
    Update-TypeData @droplet -MemberName Status
    Update-TypeData @droplet -MemberName CreatedAt
    Update-TypeData @droplet -MemberName Features
    Update-TypeData @droplet -MemberName Kernel
    Update-TypeData @droplet -MemberName NextBackupWindow
    Update-TypeData @droplet -MemberName BackupID
    Update-TypeData @droplet -MemberName SnapshotID
    Update-TypeData @droplet -MemberName Image
    Update-TypeData @droplet -MemberName Size
    Update-TypeData @droplet -MemberName Network
    Update-TypeData @droplet -MemberName Region

    #Adds account OutputType
    $account = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Account'
        Value = $null
    }

    Update-TypeData @account -MemberName DropletLimit
    Update-TypeData @account -MemberName FloatingIPLimit
    Update-TypeData @account -MemberName Email
    Update-TypeData @account -MemberName UUID
    Update-TypeData @account -MemberName EmailVerified
    Update-TypeData @account -MemberName Status
    Update-TypeData @account -MemberName StatusMessage

    #Adds kernel OutputType
    $kernel = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Kernel'
        Value = $null
    }

    Update-TypeData @kernel -MemberName KernelID
    Update-TypeData @kernel -MemberName Name
    Update-TypeData @kernel -MemberName Version

    #Adds image OutputType
    $image = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Image'
        Value = $null
    }

    Update-TypeData @image -MemberName ImageID
    Update-TypeData @image -MemberName Name
    Update-TypeData @image -MemberName Distribution
    Update-TypeData @image -MemberName Slug
    Update-TypeData @image -MemberName Public
    Update-TypeData @image -MemberName Region
    Update-TypeData @image -MemberName CreatedAt
    Update-TypeData @image -MemberName Type
    Update-TypeData @image -MemberName SizeGB
    Update-TypeData @image -MemberName MinimumDiskSize

    #Adds size OutputType
    $size = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.DigitalOcean.Size'
        Value = $null
    }

    Update-TypeData @size -MemberName Slug
    Update-TypeData @size -MemberName Memory
    Update-TypeData @size -MemberName vCPU
    Update-TypeData @size -MemberName Disk
    Update-TypeData @size -MemberName Transfer
    Update-TypeData @size -MemberName PriceMonthly
    Update-TypeData @size -MemberName PriceHourly
    Update-TypeData @size -MemberName Region
    Update-TypeData @size -MemberName Available
}