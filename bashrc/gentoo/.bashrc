#!/bin/bash
# Exit if not running interactively
[[ $- != *i* ]] && return

# ============================
# Aliases
# ============================

# Package management
alias update='doas emerge --update --newuse --deep @world'
alias install='doas emerge'
alias remove='doas emerge --deselect'
alias search='doas emerge -s'
alias merge='doas emerge -auDN @world'
alias sync='doas ego sync'
alias searchdesc='emerge --searchdesc'
alias clean='doas emerge --clean'
alias depclean='doas emerge --depclean'

# System commands
alias reboot='doas reboot'
alias poweroff='doas poweroff'
alias info='inxi -Fxxxrza'
alias sudo='doas'
alias doas='doas --'
alias dc="doas dispatch-conf"

# Navigation & files
alias ls='eza -l --color=always --group-directories-first'
alias la='eza -al --color=always --group-directories-first'
alias ..='cd ..'
alias rm='rm -iv'

#Git aliases
alias gc='git clone'
alias dotfiles='git clone https://github.com/barkifyings/dotfiles.git'

#yt-dlp aliases
alias yt-playlist="yt -cio '%(autonumber)s-%(title)s.%(ext)s'"
alias yta-aac="yt --extract-audio --audio-format aac"
alias yta-best="yt --extract-audio --audio-format best"
alias yta-flac="yt --extract-audio --audio-format flac"
alias yta-m4a="yt --extract-audio --audio-format m4a"
alias yta-mp3="yt --extract-audio --audio-format mp3"
alias yta-opus="yt --extract-audio --audio-format opus"
alias yta-vorbis="yt --extract-audio --audio-format vorbis"
alias yta-wav="yt --extract-audio --audio-format wav"
alias yt-best="yt -f bestvideo+bestaudio"
alias yt='yt-dlp'
alias ytv='yt -f bestvideo'
alias yta='yt -f bestaudio'
alias downloadchannel='yt-best -ciw -o "%(title)s.%(ext)s"'

# ============================
# Shell Behavior and Prompt
# ============================

# Make tab cycle through completion options instead of just listing them
bind 'TAB:menu-complete'

# Show all completions on first tab press if there are multiple options
bind 'set show-all-if-ambiguous on'

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Ignore case in tab completion
bind "set completion-ignore-case on"


# Shell prompt
PS1="\[\e[1;31m\][\[\e[33m\]\u\[\e[32m\]@\[\e[34m\]\h \[\e[35m\]\W\[\e[31m\]]\[\e[37m\]\\$ \[\e[0m\]"

# ====================
# Scripts
# ====================

# Archive extractor
ex () {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2|*.tbz2)         tar xjf "$1"    ;;
      *.tar.gz|*.tgz)           tar xzf "$1"    ;;
      *.tar|*.tar.xz)           tar xf "$1"     ;;
      *.bz2)                    bunzip2 "$1"     ;;
      *.rar)                    unrar x "$1"     ;;
      *.gz)                     gunzip "$1"      ;;
      *.zip)                    unzip "$1"       ;;
      *.Z)                      uncompress "$1"  ;;
      *.7z)                     7z x "$1"        ;;
      *.lzma)                   lzma -d "$1"     ;;
      *.deb)                    ar x "$1"        ;;
      *.xz)                     unxz "$1"        ;;
      *.tar.zst)               unzstd "$1"      ;;
      *)                        echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}



# Video frame extractor
function extract-frames {
    local input_file="$1"
    local output_dir="${2:-frames}"
    
    # Check if input file was provided
    if [ -z "$input_file" ]; then
        echo "Usage: extract-frames <video_file> [output_dir]"
        return 1
    fi
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file \"$input_file\" does not exist"
        return 1
    fi
    
    # Get video information before extraction
    echo "Analyzing video..."
    local fps=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$input_file")
    local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
    local expected_frames=$(echo "$fps * $duration" | bc -l | cut -d'.' -f1)
    
    echo "Video FPS: $fps"
    echo "Duration: $duration seconds"
    echo "Expected number of frames: $expected_frames"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Extract frames using ffmpeg
    echo "Extracting frames..."
    ffmpeg -i "$input_file" -fps_mode vfr "$output_dir/frame_%d.png"
    
    # Count actual extracted frames
    local extracted_frames=$(ls -1 "$output_dir"/frame_*.png 2>/dev/null | wc -l)
    echo "Extracted frames: $extracted_frames"
    
    if [ "$extracted_frames" -eq "$expected_frames" ]; then
        echo "✅ Extraction complete - all frames were extracted"
    else
        echo "⚠️  Number of extracted frames differs from expected frames"
        echo "This might be normal if the video has variable frame rate (VFR)"
        echo "or if some frames are duplicates"
    fi
}