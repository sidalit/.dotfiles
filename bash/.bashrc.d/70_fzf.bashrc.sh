#!/usr/bin/env bash

source ${HOME}/bin/.lib/git.lib.sh

###############################################################################
#                                    utils                                    #
###############################################################################

# insert at current cursor the command
__readline_insert__() {
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${@}${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=${#READLINE_LINE}
}

# replace whole command line
__readline_replace__() {
    READLINE_LINE="${1}"
    READLINE_POINT="${#1}"
}

###############################################################################
#                                    FZF                                      #
###############################################################################

# use fzf to go through bash history
# binding: CTRL-R
__fzf_history() {
    local cmd
    cmd=$(HISTTIMEFORMAT= history | fzf --tac --sync -n2.. -q "'" |
          sed 's/^ *\([0-9]*\)\** *//')
    [ -n "${cmd}" ] && __readline_replace__ "${cmd}"
}

# open files using `fzf` and `rg`
# binding: CTRL-O
__fzf_files_open() {
    local files
    files=($(rg --files-with-matches "" |
             fzf --tiebreak=length,end -q "'" -m -1 -0 --preview="bat {}"))
    [ -n "${files}" ] && ${EDITOR:-nvim} "${files[@]}"
}

# print files using `fzf` and `rg`
# binding: ALT-F
__fzf_files_print() {
    local files
    files=($(fzf --tiebreak=length,end -n -1.. -d / -q "'" -m -1 -0))
    [ -n "${files}" ] && __readline_insert__ "${files[@]}"
}

# print the most used directory (using `zoxide`) and filter using `fzf`
# binding: ALT-D
__fzf_dir_mru() {
    local dir
    dir=($(zoxide query -l | fzf --tiebreak=length,end -1 -0 -m -q "'"))
    [[ -n "${dir[@]}" ]] && __readline_insert__ "${dir[@]}"
}

# cd to selected directory using `fzf`
# binding: ALT-C
__fzf_dir_cd() {
    local dir
    dir=$(command fd --type d --hidden --no-ignore-vcs |
          fzf --tiebreak=length,end -n -1.. -d / -q "'" -1 -0 +m) &&
    cd "${dir}" || return 1
}

# grep (using rg) in the current dir
# binding: CTRL-F
__fzf_find() {
    local files
    # invert match on empty lines to avoid them
    # --delimiter=: --nth -1.. looks only for search results and not filenames
    local -r regex="(^$|^.$|^(\s+|\"\s+)\})"
    files=$(rg --column --no-heading -v "${regex}" --color=always    |
            fzf -0 -m --ansi -n 3.. -d : -q "'${*:-}"                \
                --preview 'bat --highlight-line {2} {1}'             \
                --preview-window +{2}-/2                             |
            awk -F: '{print ":e "$1"|:"$2}')

    # replace '%' by '\%'
    # files="${files[@]/\%/\\%}"

    [ -n "${files}" ] && ${EDITOR:-nvim} -c "${files}"
}

###############################################################################
#                                FZF Functions                                #
###############################################################################

# jump to recent folders using `zoxide`
f() {
    local dir
    dir="$(zoxide query -l "${1}" | fzf -1 -0 +m -q "'")" &&
        cd "${dir}" || return 1
}

# cd into the directory of the selected file using `fzf`
ff() {
    local file
    file=$(fzf --tiebreak=length,end -n -1.. -d / +m -q "'" -1 -0) &&
           cd "$(dirname "${file}")" || return 1
}

# cd to selected parent directory using `fzf`
fp() {
    local declare dirs=()
    get_parent_dirs() {
        if [ -d "${1}" ]; then dirs+=("${1}"); else return; fi
        if [ "${1}" == '/' ]; then
            for _dir in "${dirs[@]}"; do echo $_dir; done
        else
            get_parent_dirs $(dirname "${1}")
        fi
    }
    local dir=$(get_parent_dirs $(realpath "${1:-${PWD}}") | fzf --tac -1 -0)
    cd "${dir}"
}

# kill process using `fzf`
# FIXME: show only command on preview
fkill() {
    local pid
    pids=$(ps -ef | sed 1d |
           fzf -m -q "'" --preview 'echo {}' --preview-window down:2:wrap \
           -d ' ' -n 8.. --tiebreak=length,end | awk '{print $2}')

    # default use SIGKILL=9
    [ -n "${pids}" ] && kill -${1:-9} ${pids}
}

###############################################################################
#                                  FZF & GIT                                  #
###############################################################################

# commit selection using fzf
# binding: ALT-G
__fzf_commit() {
    __is_git_repo__ || return 1

    local commits

    commits=($(git lg -100 |
        fzf --query="'" --ansi --multi                                      \
        --header "<C-P> to toggle preview | <C-S> to print message"         \
        --bind "ctrl-p:toggle-preview"                                      \
        --bind "ctrl-s:execute(git show -s --format=%s%b {+1})+abort"       \
        --bind "enter:execute(echo {+1})+abort"                             \
        --preview="git show-name {+1}; git show --pretty='' {+1} | diff-so-fancy" \
    ))

    # echo "array len: ${#commits[@]}"
    # for commit in "${commits[@]}"; do
    #     __readline_insert__ "${commit} "
    # done
    [[ -n "${commits[@]}" ]] && __readline_insert__ "${commits[@]}"
}

###############################################################################
#                               FZF & GIT [WIP]                               #
###############################################################################

# __fzf_git_add - git add with preview
__fzf_git_add() {
    git status -s |
        fzf --query="'" --multi --ansi --preview="git diff {+2} | diff-so-fancy" \
        --header "<C-P> to toggle preview | <C-S> to checkout file | <C-A> to add files" \
        --bind "ctrl-p:toggle-preview" \
        --bind "ctrl-a:execute(echo {} | xargs -I % sh -c 'git add %')+accept" \
        --bind "enter:ignore"
}

# __fzf_git_log - git commit browser
__fzf_git_log() {
    local commit="echo {} | sed 's/ .*//'"
    git lg |
        fzf --query="'" --ansi --preview="${commit} | xargs git show | diff-so-fancy" \
        --header "<C-P> to toggle preview | <C-S> to show commit | <C-R> to hard reset" \
        --bind "ctrl-p:toggle-preview" \
        --bind "ctrl-s:execute(${commit} | xargs git show)" \
        --bind "ctrl-r:execute-silent(${commit} | xargs git reset --hard)+accept" \
        --bind "enter:ignore"
}

# __fzf_git_cherrypick - git cherry-pick
__fzf_git_cherrypick() {
    local commit
    local cp_dir=$(realpath ${1})
    local pwd_dir="$(git root)"
    [ ! -d ${cp_dir} ] && echo "fatal: folder ${cp_dir} does not exist" && return 1
    [ "${cp_dir}" = "${pwd_dir}" ] && echo "provided directory cannot be current directory" && return 1

    __is_git_repo__ || return 1
    __is_git_repo__ ${cp_dir} || return 1

    [ "$(git -C ${pwd_dir} root)" = "$(git -C ${cp_dir} root)" ] && \
        echo "fatal: same git directories provided" && return 1

    current_commit=$(git -C ${pwd_dir} log --format='%Cgreen[%h]%Creset %C(dim white)- %s' -1)
    commit=$(git -C ${cp_dir} lg | fzf -m --ansi \
        --header "Provide correct commit order - current: $current_commit" \
        --bind "tab:toggle+up" \
        --bind "shift-tab:toggle+down")
    selected_commits=$(echo "${commit}" | sed "s/ .*//" | sed 's/[][]//g')

    for cmt in ${selected_commits}; do
        git -C "${cp_dir}" format-patch -k -1 --stdout "${cmt}" | git am -3 -k;
        [ $? -ne 0 ] && return 1
    done
}


# __fzf_git_formatpatch - git format-patch
__fzf_git_formatpatch() {
    __is_git_repo__ || return 1
    local commit

    commit=$(git lg | fzf -m --ansi --header "Select commit(s) to generate format-patch")
    selected_commits=$(echo "${commit}" | sed "s/ .*//")
    for _commit in ${selected_commits}; do
        git format-patch -k -1 ${_commit}
    done
}

###############################################################################
#                                  BINDINGS                                   #
###############################################################################

###################
#  CTRL bindings  #
###################

# CTRL-R - Paste the selected command from history into the command line
bind -x '"\C-r": "__fzf_history"'

# CTRL-O - Open any file(s) in directory
bind -x '"\C-o": "__fzf_files_open"'

# CTRL-F - Interactive ripgrep search files
bind -x '"\C-f": "__fzf_find"'

##################
#  ALT bindings  #
##################

# ALT-D - Paste last used directory
bind -x '"\M-d": "__fzf_dir_mru"'

# ALT-F - Print selected file(s)
bind -x '"\M-f": "__fzf_files_print"'

# ALT-G - Paste the selected commit from git log into the command line
bind -x '"\M-g": "__fzf_commit"'

# ALT-C - Navigate into the selected directory
bind '"\M-c": "__fzf_dir_cd\C-m"'

