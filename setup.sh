#!/usr/bin/env bash

export PACKMAN_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export PATH=$PACKMAN_ROOT:$PATH

OS=$(uname -o 2> /dev/null || uname -s 2> /dev/null)

# Set command line completion for packman command
if [[ $OS =~ 'Cygwin' ]]; then
    # Cygwin is very slow when dynamically get the subcommands from codes, so I
    # just fix subcommands.
    # In addition, available_package_names and installed_package_names are also
    # not available anymore.
    subcommands="config collect install remove switch mirror update help report start stop status"
else
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

    available_package_names=""
    for file in $(ls "$PACKMAN_ROOT/packages"); do
        available_package_names="$available_package_names $(basename "$file" .rb)"
    done

    if [[ -f "$PACKMAN_ROOT/packman.config" ]]; then
        install_root=$(awk '/install_root/ { print substr($3, 2, length($3)-2) }' "$PACKMAN_ROOT/packman.config")
    fi
    installed_package_names=""
    if [[ -d "$install_root" ]]; then
        for dir in $(ls "$install_root"); do
            if [[ ! -d "$install_root/$dir" ]]; then
                continue
            fi
            if [[ ! $available_package_names =~ $dir ]]; then
                continue
            fi
            installed_package_names="$installed_package_names $dir"
        done
    fi
fi

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
    "packman")
        completed_words=$subcommands
        ;;
    "config" | "switch" | "mirror" | "update" | "help" | "report")
        completed_words=$(eval "echo \$${prev_word##*/}_options")
        ;;
    "collect" | "install")
        completed_words="$(eval "echo \$${prev_word##*/}_options") $available_package_names"
        ;;
    "remove" | "start" | "stop" | "status")
        completed_words="$(eval "echo \$${prev_word##*/}_options") $installed_package_names"
        ;;
    *)
        if [[ $subcommand ]]; then
            if [[ "remove start stop status" =~ $subcommand ]]; then
                completed_words="$(eval "echo \$${subcommand}_options") $available_package_names"
            elif [[ "install" =~ $subcommand ]]; then
                completed_words="$(eval "echo \$${subcommand}_options") $installed_package_names"
            fi
        fi
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_word))
}

complete -o bashdefault -F complete_packman packman


# Check if Ruby is available or not, and it must be >= 1.9.
RUBY_URL=http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.gz
RUBY_PACKAGE=ruby-2.2.0.tar.gz
RUBY_PACKAGE_DIR=$(basename $RUBY_PACKAGE .tar.gz)

function install_ruby
{
    if [[ ! -d "$PACKMAN_ROOT/ruby" ]]; then
        mkdir "$PACKMAN_ROOT/ruby"
    fi
    cd $PACKMAN_ROOT/ruby
    if [[ ! -f $RUBY_PACKAGE ]]; then
        wget $RUBY_URL -O $RUBY_PACKAGE
    fi
    rm -rf $RUBY_PACKAGE_DIR
    tar -xjf $RUBY_PACKAGE
    cd $RUBY_PACKAGE_DIR
    echo "[Notice]: Building Ruby, please wait for a moment! If anything is wrong, please see $PACKMAN_ROOT/ruby/out!"
    if ! which gcc 1> /dev/null; then
        echo '[Error]: There is no GCC compiler!'
        exit
    fi
    CC=gcc ./configure --prefix=$PACKMAN_ROOT/ruby --disable-install-doc 1> $PACKMAN_ROOT/ruby/out 2>&1
    make install 1>> $PACKMAN_ROOT/ruby/out 2>&1
    cd $PACKMAN_ROOT/ruby
    rm -rf $RUBY_PACKAGE_DIR
}

if [[ -d "$PACKMAN_ROOT/ruby/bin" ]]; then
    export PATH=$PACKMAN_ROOT/ruby/bin:$PATH
fi

old_dir=$(pwd)
if ! which ruby 1> /dev/null; then
    echo '[Warning]: System does not provide a Ruby! PACKMAN will install one for you!'
    install_ruby
fi
RUBY_VERSION=$(ruby -v | cut -d ' ' -f 2)
if [[ $RUBY_VERSION =~ $(echo '^1\.8') || $RUBY_VERSION =~ $(echo '^1\.9') ]]; then
    echo "[Warning]: Ruby version is too old, PACKMAN will install a newer one for you!"
    install_ruby
fi
cd "$old_dir"
