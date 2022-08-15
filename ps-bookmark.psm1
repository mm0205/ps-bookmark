
Function Get-BookmarkItem {
    [CmdletBinding()]
    Param (
    )
    Begin {
    }
    Process {
        Get-ChildItem ~/.bookmarks | Where-Object {
            -not [String]::IsNullOrWhiteSpace($_.LinkTarget)
        } | Select-Object -Property Name, LinkTarget | Format-Table -HideTableHeaders
    }
    End {
    }
}

Function MyArgumentCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )
    if ([System.String]::IsNullOrWhiteSpace($wordToComplete)) {
        Get-ChildItem "~/.bookmarks/" | ForEach-Object {
            $_.Name 
        }
    }
    else {
        Get-ChildItem "~/.bookmarks/" | ForEach-Object {
            $_.Name 
        } | Where-Object { $_ -like "$wordToComplete*" } 
    }
}

Function Select-BookmarkItem {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ArgumentCompleter( { MyArgumentCompleter @args })]
        [String] $Path
    )
    cd $(readlink "/Users/munenaga/.bookmarks/${Path}")
}

Function Add-BookmarkItem {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String] $Path,
        [String] $Name
    )
    $fullPath = Resolve-Path $Path
    if ( -not [System.IO.Directory]::Exists($fullPath) ) {
        Write-Warning "Directory does not exist"
        Return
    }

    $currentLocation = Get-Location | Resolve-Path

    $bookmarkPath = Resolve-Path "~/.bookmarks"
    if ( -not [System.IO.Directory]::Exists($bookmarkPath) ) {
        Write-Warning "Bookmark Directory does not exist"
        Write-Warning "Please execute following commands:"
        Write-Warning "`tNew-Item -Path $bookmarkPath  -ItemType Directory"
        Return
    }

    if ([String]::IsNullOrWhiteSpace($Name)) {
        $Name = Split-Path -Leaf $Path
    }
    
    Set-Location $bookmarkPath

    ln -s $fullPath $Name

    Set-Location $currentLocation

    Get-ChildItem -Path $bookmarkPath | Where-Object { $_.Name -eq $Name }
}

Function Show-BookmarkItem {
    [CmdletBinding()]
    Param(
        [switch]$ShowName,
        [switch]$ShowPath
    )
    Begin {}
    Process {
        $formatCommand = "awk '{print $1}"
        if ( $ShowName -and $ShowPath ) {
            Get-BookmarkItem | fzf | awk '{print $1,$2}'
            Return
        }
        elseif ( $ShowName ) {
            Get-BookmarkItem | fzf | awk '{print $1}'
            Return
        }
        else {
            Get-BookmarkItem | fzf | awk '{print $2}'
        }
    }
    End {}
}


New-Alias -Name bm-ls -Value Get-BookmarkItem
New-Alias -Name bm-cd -Value Select-BookmarkItem 
New-Alias -Name bm-add -Value Add-BookmarkItem 
New-Alias -Name bm-fzf -Value Show-BookmarkItem 


Export-ModuleMember -Function * -Alias *
