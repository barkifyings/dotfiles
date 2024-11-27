# ============================
# Aliases
# ============================

# Package management
function Update-System {
    choco upgrade all -y
}
function Install-Package {
    param([string]$PackageName)
    choco install $PackageName -y
}
function Remove-Package {
    param([string]$PackageName)
    choco uninstall $PackageName -y
}
function Search-Package {
    param([string]$PackageName)
    choco search $PackageName
}

# Navigation & files
function Go-Up { 
    Set-Location .. 
}

function rmf {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path,
        [switch]$Force
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
function Clone-Dotfiles {
    git clone https://github.com/barkifyings/dotfiles.git
}

# System commands
function Restart-ComputerForce { 
    Restart-Computer -Force 
}
function Stop-ComputerForce { 
    Stop-Computer -Force 
}

function info { 
    systeminfo 
}

# yt-dlp aliases
function Download-YTPlaylist {
    yt-dlp -cio '%(autonumber)s-%(title)s.%(ext)s'
}

# yt-dlp audio download functions
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

# Audio download aliases
foreach ($format in $audioFormats.Keys) {
    New-Alias -Name "yta-$format" -Value "Download-YTAudio$format" -Force
}

## Video download functions with argument passthrough
function Download-YTBest {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestvideo+bestaudio @Arguments
}

function Download-YTVideo {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestvideo @Arguments
}

function Download-YTAudio {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -f bestaudio @Arguments
}

function Download-YTPlaylist {
    param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
    yt-dlp -cio '%(autonumber)s-%(title)s.%(ext)s' @Arguments
}

# Create aliases that won't conflict with built-in commands
New-Alias -Name update -Value Update-System -Force
New-Alias -Name install -Value Install-Package -Force
New-Alias -Name remove -Value Remove-Package -Force
New-Alias -Name search -Value Search-Package -Force
New-Alias -Name reboot -Value Restart-ComputerForce -Force
New-Alias -Name poweroff -Value Stop-ComputerForce -Force
New-Alias -Name '..' -Value Go-Up -Force
New-Alias -Name yt-playlist -Value Download-YTPlaylist -Force
New-Alias -Name yt -Value yt-dlp -Force
New-Alias -Name yt-best -Value Download-YTBest -Force
New-Alias -Name ytv -Value Download-YTVideo -Force
New-Alias -Name yta -Value Download-YTAudio -Force
New-Alias -Name downloadchannel -Value Download-YTChannel -Force
New-Alias -Name ex -Value Extract-Archive -Force

# ============================
# Shell Behavior and Prompt
# ============================

# Import the Chocolatey Profile to enable tab-completions to function
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


# Shell prompt
function Prompt {
    $host.UI.RawUI.ForegroundColor = 'Red'
    Write-Host -NoNewline "["
    $host.UI.RawUI.ForegroundColor = 'Yellow'
    Write-Host -NoNewline "$env:USERNAME"
    $host.UI.RawUI.ForegroundColor = 'Green'
    Write-Host -NoNewline "@"
    $host.UI.RawUI.ForegroundColor = 'Cyan'
    Write-Host -NoNewline "$env:COMPUTERNAME"
    $host.UI.RawUI.ForegroundColor = 'Magenta'
    Write-Host -NoNewline " $(Get-Location)"
    $host.UI.RawUI.ForegroundColor = 'Red'
    Write-Host "]" -NoNewline
    $host.UI.RawUI.ForegroundColor = 'White'
    return "> "
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
        [string]$OutputDir = "frames"
    )

    if (!(Test-Path $InputFile)) {
        Write-Error "Input file '$InputFile' does not exist"
        return
    }

    # Ensure output directory exists
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    # Get video information
    $fpsRaw = (ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 $InputFile)
    $duration = (ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $InputFile)

    # Parse FPS (handle fraction)
    $fpsParts = $fpsRaw -split '/'
    $fps = if ($fpsParts.Count -eq 2) { 
        [double]$fpsParts[0] / [double]$fpsParts[1] 
    } else { 
        [double]$fpsRaw 
    }

    $expectedFrames = [math]::Floor($fps * $duration)

    Write-Host "Video FPS: $fps"
    Write-Host "Duration: $duration seconds"
    Write-Host "Expected number of frames: $expectedFrames"

    # Extract frames
    ffmpeg -i $InputFile -fps_mode vfr "$OutputDir/frame_%d.png"

    # Count extracted frames
    $extractedFrames = (Get-ChildItem "$OutputDir/frame_*.png" | Measure-Object).Count

    Write-Host "Extracted frames: $extractedFrames"

    if ($extractedFrames -eq $expectedFrames) {
        Write-Host "✅ Extraction complete - all frames were extracted"
    }
    else {
        Write-Warning "Number of extracted frames differs from expected frames"
        Write-Warning "This might be normal if the video has variable frame rate (VFR)"
    }
}