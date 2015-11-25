#!/usr/bin/env bash

export PACKMAN_ROOT=$(cd $(dirname $BASH_SOURCE) && pwd)
export PATH=$PACKMAN_ROOT:$PATH

# Add autocompletion.
subcommands=$(awk '
    /PermittedSubcommands = {/ { start = 1 };
    { if (start == 1 && match($1, ":")) { print substr($1, 2, length($1)-1) } };
    /}.freeze/ { exit }' "$PACKMAN_ROOT/framework/command_line.rb")
for subcommand in $subcommands; do
    eval "${subcommand}_options=\$(awk -v subcommand=$subcommand '
        /PermittedCommonOptions = {/ { start = 1 };
        { if (start == 1 && match(\$1, \"-\")) { print substr(\$1, 2, length(\$1)-2) } };
        /}.freeze/ { if (start == 1) start = 0 };
        /PermittedOptions = {/ { start = 2 };
        { if (start == 2 && match(\$1, subcommand)) start = 3 };
        { if (start == 3 && match(\$1, \"-\")) { print substr(\$1, 2, length(\$1)-2) } };
        /}/ { if (start == 3) exit }' \"$PACKMAN_ROOT/framework/command_line.rb\")"
done

packages=""
for file in $(ls "$PACKMAN_ROOT/packages"); do
    packages="$packages $(basename "$file" .rb)"
done

unset subcommand
function find_subcommand()
{
    if [[ $subcommand ]]; then
        return
    fi
    for (( i = 0; i < $COMP_CWORD; ++i )); do
        if [[ $subcommands =~ ${COMP_WORDS[i]} ]]; then
            subcommand=${COMP_WORDS[i]}
        fi
    done
}

function complete_packman()
{
    find_subcommand
    local prev_word=${COMP_WORDS[COMP_CWORD-1]}
    local curr_word=${COMP_WORDS[COMP_CWORD]}
    completed_words=""
    case "${prev_word##*/}" in
    packman)
        completed_words=$subcommands
        ;;
    config | help | mirror | report | switch | update)
        completed_words=$(eval "echo \$${prev_word##*/}_options")
        ;;
    collect | edit | install | remove | start | status | stop | upgrade | link | unlink | store)
        completed_words="$(eval "echo \$${prev_word##*/}_options") $packages"
        ;;
    *)
        if [[ $subcommand ]]; then
            if [[ "collect edit install remove start status stop upgrade" =~ $subcommand ]]; then
                completed_words="$(eval "echo \$${subcommand}_options") $packages"
            fi
        fi
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_word))
}

complete -o bashdefault -F complete_packman packman

# Source packman.bashrc in <install_root> if there is.
if [[ -f "$PACKMAN_ROOT/packman.config" ]]; then
    install_root=$(grep install_root $PACKMAN_ROOT/packman.config | cut -d '=' -f 2 | cut -d "'" -f 2 | cut -d '"' -f 2)
    # Escape potential ~.
    active_root=${install_root/~\//$HOME/}/packman.active
    case $(uname) in
    Linux )
        ld_library_path_name=LD_LIBRARY_PATH
        ;;
    Darwin )
        ld_library_path_name=DYLD_LIBRARY_PATH
        ;;
    esac
    export PATH="$active_root/bin:$PATH"
    eval "export $ld_library_path_name=\"\$active_root/lib:\$active_root/lib64:\$$ld_library_path_name\""
    export MANPATH="$active_root/share/man:$MANPATH"
    export PKG_CONFIG_PATH="$active_root/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# Use ruby installed by PACKMAN if there is.
function use_packman_installed_ruby
{
    if [[ -d "$PACKMAN_ROOT/ruby/bin" ]]; then
        export PATH=$PACKMAN_ROOT/ruby/bin:$PATH
    else
        echo "[Error]: There is no Ruby for PACKMAN!"
        return 1
    fi
}

if ! which ruby 2>&1 1> /dev/null 2>&1; then
    use_packman_installed_ruby
else
    RUBY_VERSION=$(ruby -v | cut -d ' ' -f 2)
    if [[ $RUBY_VERSION =~ $(echo '^1\.8') || $RUBY_VERSION =~ $(echo '^1\.9') ]]; then
        use_packman_installed_ruby
    fi
fi
