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