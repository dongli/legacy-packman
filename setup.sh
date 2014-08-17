#!/bin/bash

export PACKMAN_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export PATH=$PACKMAN_ROOT:$PATH

# command line completion
function _packman_()
{
    local prev_argv=${COMP_WORDS[COMP_CWORD-1]}
    local curr_argv=${COMP_WORDS[COMP_CWORD]}
    completed_words=""
    case "${prev_argv##*/}" in
    "packman")
        completed_words="collect install"
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_argv))
}

complete -o default -F _packman_ packman