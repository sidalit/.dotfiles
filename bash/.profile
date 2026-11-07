# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

###############################################################################
#                                   colors                                    #
###############################################################################

nord0="#2E3440"
nord1="#3B4252"
nord2="#434C5E"
nord3="#4C566A"
nord3_5="#717889"
nord4="#D8DEE9"
nord5="#E5E9F0"
nord6="#ECEFF4"
nord7="#8FBCBB"
nord8="#88C0D0"
nord9="#81A1C1"
nord10="#5E81AC"
nord11="#BF616A"
nord12="#D08770"
nord13="#EBCB8B"
nord14="#A3BE8C"
nord15="#B48EAD"

###############################################################################
#                        environment variables setting                        #
###############################################################################

# colored GCC warnings and errors
export GCC_COLORS="error=31:warning=38;5;208:note=34:caret=32:locus=37:quote=36"

# GTK theming to fix libadwaita
# export GTK_THEME=Qogir-Dark

# xdg config
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_DATA_DIRS="${XDG_DATA_HOME}:${XDG_DATA_DIRS}:/usr/share:/usr/local/share"

# common exports
export EDITOR="$(which nvim || which vim || which subl || which subl3)"
export GIT_EDITOR="${EDITOR}"
export BROWSER="$(which firefox || which google-chrome-stable || which opera)"

# set PATH so it includes user's private bin if it exists and remove duplicates
PATH="${PATH}:${HOME}/bin"
PATH="${PATH}:${HOME}/.cargo/bin"
PATH_TMP=$(printf %s "$PATH" |
           awk -v RS=: '{ if (!arr[$0]++) {printf("%s%s",!ln++?"":":",$0)}}' |
           tr -s ':')
export PATH="${PATH_TMP}"

# local language
export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"

# less configuration
export LESS='-R'
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
# export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

###############################################################################
#                                   zerobrew                                  #
###############################################################################

export ZEROBREW_DIR='/home/sidali/.zerobrew'
export ZEROBREW_BIN='/home/sidali/.local/bin'
export ZEROBREW_ROOT='/home/sidali/.local/share/zerobrew'
export ZEROBREW_PREFIX='/home/sidali/.local/share/zerobrew/prefix'
export PKG_CONFIG_PATH="$ZEROBREW_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# SSL/TLS certificates (only if ca-certificates is installed)
if [ -z "${CURL_CA_BUNDLE:-}" ] || [ -z "${SSL_CERT_FILE:-}" ]; then
  if [ -f "$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
  elif [ -f "$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
  elif [ -f "$ZEROBREW_PREFIX/etc/openssl/cert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
  elif [ -f "$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
  fi
fi

if [ -z "${SSL_CERT_DIR:-}" ]; then
  if [ -d "$ZEROBREW_PREFIX/etc/ca-certificates" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/ca-certificates"
  elif [ -d "$ZEROBREW_PREFIX/etc/openssl/certs" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/openssl/certs"
  elif [ -d "$ZEROBREW_PREFIX/share/ca-certificates" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/share/ca-certificates"
  fi
fi

# Helper function to safely append to PATH
_zb_path_append() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac;
}

_zb_path_append "$ZEROBREW_BIN"
_zb_path_append "$ZEROBREW_PREFIX/sbin"
_zb_path_append "$ZEROBREW_PREFIX/bin"

###############################################################################
#                                   zoxide                                    #
###############################################################################

export _ZO_EXCLUDE_DIRS="/mnt:/tmp"
export _ZO_DATA_DIR="${HOME}/.zoxide"
export _ZO_MAXAGE=5000

eval "$(zoxide init --no-cmd --hook pwd bash)"

###############################################################################
#                                   ripgrep                                   #
###############################################################################

export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"

###############################################################################
#                                    navi                                     #
###############################################################################

export NAVI_PATH="${XDG_CONFIG_HOME}/navi/cheats"
export NAVI_FZF_OVERRIDES=" --color=hl:${nord13},hl+:${nord13}"

###############################################################################
#                                     fzf                                     #
###############################################################################

export FZF_DEFAULT_OPTS="                                                     \
    --no-bold --no-mouse --height 70% --reverse --border=sharp --no-separator \
    --tiebreak=index --bind \"change:top\" --scheme=history                   \
    --preview-window=sharp --margin=0                                         \
    --bind \"ctrl-up:preview-up,ctrl-down:preview-down\"                      \
    --color=border:${nord3},bg+:${nord1},bg:${nord0},spinner:${nord14}        \
    --color=hl:${nord14},fg:${nord3_5},header:${nord12},info:${nord3}         \
    --color=pointer:${nord11},marker:${nord8},fg+:${nord4},gutter:${nord0}    \
    --color=preview-fg:${nord4},preview-bg:${nord0}                           \
    --color=prompt:${nord9},hl+:${nord14}"

export FZF_DEFAULT_COMMAND="rg                                                \
    --files --hidden --no-messages --no-ignore-vcs --follow --no-messages"

###############################################################################
#                                   bashrc                                    #
###############################################################################

[ -s "${HOME}/.bashrc" ] && source "${HOME}/.bashrc"

