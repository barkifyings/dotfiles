# ============================
# Aliases
# ============================

# Package management
function update {
    choco upgrade all -y
}
function install {
    param([string]$PackageName)
    choco install $PackageName -y
}
function remove {
    param([string]$PackageName)
    choco uninstall $PackageName -y
}
function search {
    param([string]$PackageName)
    choco search $PackageName
}

# Navigation & files
function .. { 
    Set-Location .. 
}

function rmf {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path
    )


    begin {
        $ErrorActionPreference = 'Continue'
    }

    process {
        foreach ($p in $Path) {
            try {
                # Use Remove-Item with -Recurse and -Force to handle nested directories and permissions
                Remove-Item -Path $p -Recurse -Force -ErrorAction Continue
            }
            catch {
                Write-Warning "Could not remove $p completely: $_"
            }
        }
    }
}

# Git aliases
function dotfiles {
    git clone https://github.com/barkifyings/dotfiles.git
}

# System commands
function restart { 
    Restart-Computer -Force 
}
function poweroff { 
    Stop-Computer -Force 
}

function info { 
    systeminfo 
}

# SSH aliases
function sshmacbook { 
    ssh barki@macbook
}

function sshveriton { 
    ssh barki@veriton 
}

# yt-dlp aliases
$audioFormats = @{
    'aac' = '--extract-audio --audio-format aac'
    'best' = '--extract-audio --audio-format best'
    'flac' = '--extract-audio --audio-format flac'
    'm4a' = '--extract-audio --audio-format m4a'
    'mp3' = '--extract-audio --audio-format mp3'
    'opus' = '--extract-audio --audio-format opus'
    'vorbis' = '--extract-audio --audio-format vorbis'
    'wav' = '--extract-audio --audio-format wav'
}

foreach ($format in $audioFormats.Keys) {
    $funcName = "Download-YTAudio$format"
    $command = "yt-dlp $($audioFormats[$format])"
    Invoke-Expression "function $funcName { $command @args }"
}

foreach ($format in $audioFormats.Keys) {
    New-Alias -Name "yta-$format" -Value "Download-YTAudio$format" -Force
}

function yt-best {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestvideo+bestaudio @Arguments
}

function ytv {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestvideo @Arguments
}

function yta {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestaudio @Arguments
}

function yt-playlist {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -cio '%(autonumber)s-%(title)s.%(ext)s' @Arguments
}

# ============================
# Shell Behavior and Prompt
# ============================

# Import the Chocolatey Profile to enable tab-completions to function
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


# Shell prompt
function prompt {
    $ESC = [char]27
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $location = Split-Path -Leaf -Path (Get-Location)
    
    "$ESC[1;31m[$ESC[33m$username$ESC[32m@$ESC[34m$hostname $ESC[35m$location$ESC[31m]$ESC[37m$ $ESC[0m"
}

# ====================
# Scripts
# ====================

# Archive extractor
function Extract-Archive {
    param([string]$Path)

    if (!(Test-Path $Path)) {
        Write-Error "'$Path' is not a valid file"
        return
    }

    $extension = [System.IO.Path]::GetExtension($Path)
    
    switch ($extension) {
        ".tar.bz2" { tar -xjf $Path }
        ".tbz2"    { tar -xjf $Path }
        ".tar.gz"  { tar -xzf $Path }
        ".tgz"     { tar -xzf $Path }
        ".tar"     { tar -xf $Path }
        ".tar.xz"  { tar -xf $Path }
        ".bz2"     { 7z x $Path }
        ".rar"     { 7z x $Path }
        ".gz"      { 7z x $Path }
        ".zip"     { Expand-Archive -Path $Path -DestinationPath (Split-Path $Path) }
        ".7z"      { 7z x $Path }
        default    { Write-Error "'$Path' cannot be extracted" }
    }
}

# Video frame extractor
function Extract-Frames {
    param(
        [string]$InputFile,
        [string]$OutputDir = ""
    )

    if (-not $InputFile) {
        Write-Error "Usage: Extract-Frames -InputFile <video_file> [-OutputDir <output_dir>]"
        return
    }

    if (-not (Test-Path $InputFile)) {
        Write-Error "Error: Input file '$InputFile' does not exist"
        return
    }

    if (-not $OutputDir) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
        $OutputDir = "${baseName}_frames"
    }

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    Write-Host "Extracting frames..."
    $ffmpegCommand = "ffmpeg -i `"$InputFile`" `"$OutputDir/frame_%d.png`""
    Invoke-Expression $ffmpegCommand

    Write-Host "✅ Extraction complete"
}