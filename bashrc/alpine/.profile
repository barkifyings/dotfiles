#!/bin/sh
# Exit if not running interactively
case "$-" in
  *i*) ;;
  *) return ;;
esac

# ============================
# Aliases
# ============================

# Package management
alias update='doas apk update && doas apk upgrade && doas apk cache clean'
alias install='doas apk add'
alias remove='doas apk del'
alias search='apk search'

# System commands
alias reboot='doas reboot'
alias poweroff='doas poweroff'
alias info='inxi -Fxxxrza'

# Navigation & files
alias ls='ls -lh --color=auto --group-directories-first'
alias la='ls -lAh --color=auto --group-directories-first'
alias ..='cd ..'
alias rm='rm -iv'

# Git aliases
alias gc='git clone'
alias dotfiles='git clone https://github.com/barkifyings/dotfiles.git'

# yt-dlp aliases
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
# Shell Prompt
# ============================

# Shell prompt
PS1="\033[1;31m[\033[33m\u\033[32m@\033[34m\h \033[35m\W\033[31m]\033[37m\$ \033[0m"

# ====================
# Scripts
# ====================

# Archive extractor
ex() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2|*.tbz2)    tar xjf "$1"       ;;
      *.tar.gz|*.tgz)      tar xzf "$1"       ;;
      *.tar|*.tar.xz)      tar xf "$1"        ;;
      *.bz2)               bunzip2 "$1"       ;;
      *.rar)               unrar x "$1"       ;;
      *.gz)                gunzip "$1"        ;;
      *.zip)               unzip "$1"         ;;
      *.Z)                 uncompress "$1"    ;;
      *.7z)                7z x "$1"          ;;
      *.lzma)              lzma -d "$1"       ;;
      *.deb)               ar x "$1"          ;;
      *.xz)                unxz "$1"          ;;
      *.tar.zst)           unzstd "$1"        ;;
      *)                   echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Video frame extractor
extract-frames() {
  input_file="$1"
  base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
  output_dir="${2:-${base_name}_frames}"

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

  # Create output directory if it doesn't exist
  mkdir -p "$output_dir"

  # Extract frames using ffmpeg
  echo "Extracting frames..."
  ffmpeg -i "$input_file" "$output_dir/frame_%d.png"

  echo "Extraction complete"
}
