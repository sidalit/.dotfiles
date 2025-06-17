#!/usr/bin/env bash

#######################################################################
#                             completions                             #
#######################################################################

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# make sure to source bash_completion
source /usr/share/bash-completion/completions/dd

# _completion_loader dd
if command -v dds > /dev/null 2>&1; then
    _completion_loader dd
    complete -F _comp_cmd_dd -o nospace dds
fi

