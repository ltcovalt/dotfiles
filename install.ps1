# install.ps1
$ErrorActionPreference = 'Stop'

function Link-Dir($source, $dest) {
    # ensure parent directories exist
    $parent = Split-Path -Parent $dest
    if ($parent) { 
      New-Item -ItemType Directory -Force -Path $parent | Out-Null 
    }

    # if destination directory already exists and isn't a link, back it up
    if (Test-Path $dest -PathType Container) {
        $item = Get-Item $dest -Force
        if (-not $item.LinkType) {
            Write-Host "backing up existing directory: $dest"
            Rename-Item $dest "$($dest).backup.$(Get-Date -Format yyyyMMddHHmmss)"
        }
    }

    # create the symlink
    New-Item -ItemType SymbolicLink -Path $dest -Target $source -Force | Out-Null
    Write-Host "symlink created: $dest -> $source"
}

function Link-File($source, $dest) {
    # ensure parent directories exist
    $parent = Split-Path -Parent $dest
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }

    # handle existing files or dirs
    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.PSIsContainer) {
            Write-Error "'$dest' is a directory, expected a file."
            return
        }
        if (-not $item.LinkType) {
            Write-Host "backing up existing file: $dest"
            Rename-Item $dest "$($dest).backup.$(Get-Date -Format yyyyMMddHHmmss)"
        }
    }

    # create the symlink
    New-Item -ItemType SymbolicLink -Path $dest -Target $source -Force | Out-Null
    Write-Host "symlink created: $dest -> $source"
}

# create symlinks
$repo = $PSScriptRoot

Link-Dir "$repo\nvim" "$env:LOCALAPPDATA\nvim"
