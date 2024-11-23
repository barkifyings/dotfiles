#!/bin/bash
# if not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

# aliases
alias update='doas pkg update && doas pkg upgrade && doas pkg autoremove' 
alias install='doas pkg install -y'
alias remove='doas pkg delete -y'
alias search='doas pkg search'
alias descsearch='pkg search -D'
alias reboot='doas reboot'
alias poweroff='doas poweroff'
alias ls='eza -l --color=always --group-directories-first'
alias la='eza -al --color=always --group-directories-first'
alias lt='eza -aT --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
alias weather='curl wttr.in'
alias hisgrep='history | grep --color=auto'
alias df='df -h'
alias find='doas find'
alias ..='cd ..'
alias ...='cd ../..'
alias dotfiles='git clone https://github.com/barkifyings/dotfiles.git'
alias gp='git pull'
alias gs='git status'
alias gc='git clone'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias kx='killall xfe'
alias linfo='inxi -Fxxxrza'
alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'
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

# exports
export VISUAL=vim
export EDITOR="$VISUAL"

PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

# archive extractor, usage: ex <file>
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

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"