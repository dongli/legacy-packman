#!/bin/bash

export PACKMAN_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export PATH=$PACKMAN_ROOT:$PATH

# Set command line completion for packman command
subcommands="config collect install remove switch mirror update help report start stop status"
config_options="-debug"
collect_options="-debug -all"
install_options="-debug -verbose"
remove_options="-debug -all"
switch_options="-debug -compiler_set_index"
mirror_options="-debug -init -start -status -stop -sync"
update_options="-debug"
help_options="-debug"
report_options="-debug"
start_options="-debug"
stop="-debug"
status="-debug"

package_names=""
for file in $(ls $PACKMAN_ROOT/packages); do
    package_names="$package_names $(basename $file .rb)"
done

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
    "config" | "collect" | "switch" | "mirror" | "update" | "help" | "report")
        completed_words=$(eval "echo \$${prev_word##*/}_options")
        ;;
    "install" | "remove" | "start" | "stop" | "status")
        completed_words="$(eval "echo \$${prev_word##*/}_options") $package_names"
        ;;
    *)
        if [[ $subcommand ]]; then
            if [[ "install remove start stop" =~ $subcommand ]]; then
                completed_words="$(eval "echo \$${subcommand}_options") $package_names"
            fi
        fi
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_word))
}

complete -o bashdefault -F complete_packman packman


# Check if Ruby is available or not, and it must be >= 1.9.
RUBY_URL=http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.bz2
RUBY_PACKAGE=ruby-2.1.3.tar.bz2
RUBY_PACKAGE_DIR=$(basename $RUBY_PACKAGE .tar.bz2)

function install_ruby
{
    if [[ ! -d "$PACKMAN_ROOT/ruby" ]]; then
        mkdir "$PACKMAN_ROOT/ruby"
    fi
    cd $PACKMAN_ROOT/ruby
    if [[ ! -f $RUBY_PACKAGE ]]; then
        wget $RUBY_URL
    fi
    rm -rf $RUBY_PACKAGE_DIR
    tar -xjf $RUBY_PACKAGE
    cd $RUBY_PACKAGE_DIR
    echo "[Notice]: Building Ruby, please wait for a moment! If anything is wrong, please see $PACKMAN_ROOT/ruby/out!"
    ./configure --prefix=$PACKMAN_ROOT/ruby --disable-install-doc 1> $PACKMAN_ROOT/ruby/out 2>&1
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
if [[ $RUBY_VERSION =~ $(echo '^1\.8') ]]; then
    echo "[Warning]: Ruby version is too old, PACKMAN will install a newer one for you!"
    install_ruby
fi
cd "$old_dir"
