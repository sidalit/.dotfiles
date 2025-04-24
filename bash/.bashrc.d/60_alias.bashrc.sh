#!/usr/bin/env bash

# enable color support of ls and also add handy aliases
if [ -x $(command -v dircolors) ]; then
    [ -f ~/.dir_colors ] && eval "$(dircolors ~/.dir_colors)"

    alias ls='LC_COLLATE=C ls --color=auto'
    alias grep='grep --color=auto'
    alias ip='ip --color=auto'
    alias diff='diff --color=auto'
    alias hexedit='hexedit --color'
fi

# ls aliases
# -A : all files without ./ and ../
# -l : long list format
# -F : append operator to entries
# -h : human size
# LC_COLLATE=C : sort dot first
alias ll='ls -Al --group-directories-first'
alias lls='ls -hAl --group-directories-first'

# alias mount='mount | column -t'
alias mkdir='mkdir -pv'
alias ussh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias ping='ping -c 3'
alias lsblka='lsblk -p -o NAME,FSTYPE,LABEL,PARTLABEL,UUID,PARTUUID,FSSIZE,FSAVAIL,FSUSE%,MOUNTPOINTS'
alias lsblk='lsblk -p -o NAME,FSTYPE,PARTLABEL,FSSIZE,FSAVAIL,FSUSE%,MOUNTPOINTS'

alias m='[ -f "Makefile" ] && make -s -j`getconf _NPROCESSORS_ONLN`'
alias tree='LC_COLLATE=C tree -aC -I ".git|node_modules|bower_components|plugged|__pycache__|CMakeFiles" --dirsfirst'
alias gtree='git ls-tree -r --name-only HEAD | LC_COLLATE=C \tree -aC --fromfile --dirsfirst'
alias dtrx='ouch decompress'

# -rr - read-only mode (prevents delete and spawn shell)
alias ncdu='ncdu -rr -x -X ~/.ignore'
alias gdu='gdu -x -p -c -i /root,/mnt'

# fix typos
alias l='ll'
alias lll='ll'
