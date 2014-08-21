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
        completed_words="collect install update help"
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_argv))
}

complete -o default -F _packman_ packman

OS=$(uname)

RUBY_URL=http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
RUBY_PACKAGE=ruby-2.1.2.tar.gz
RUBY_PACKAGE_DIR=$(basename $RUBY_PACKAGE .tar.gz)

function install_ruby
{
    if [[ ! -d "$PACKMAN_ROOT/ruby" ]]; then
        mkdir "$PACKMAN_ROOT/ruby"
    fi
    cd $PACKMAN_ROOT/ruby
    if [[ ! -f $RUBY_PACKAGE ]]; then
        wget $RUBY_URL
    fi
    tar xf $RUBY_PACKAGE
    cd $RUBY_PACKAGE_DIR
    ./configure --prefix=$PACKMAN_ROOT/ruby
    make install
    cd $PACKMAN_ROOT/ruby
    rm -rf $RUBY_PACKAGE_DIR
}

if [[ -d "$PACKMAN_ROOT/ruby/bin" ]]; then
    export PATH=$PACKMAN_ROOT/ruby/bin:$PATH
fi

# Check if Ruby is available or not, and it must be >= 2.0.
if ! which ruby 1> /dev/null; then
    echo '[Warning]: System does not provide a Ruby! PACKMAN will install one for you!'
    install_ruby
fi
RUBY_VERSION=$(ruby -v | cut -d ' ' -f 2)
if [[ $RUBY_VERSION =~ $(echo '^1\.') ]]; then
    echo "[Warning]: Ruby version is too old, PACKMAN will install a newer one for you!"
    install_ruby
fi