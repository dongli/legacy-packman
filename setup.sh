#!/usr/bin/env bash

PACKMAN_ROOT=$(cd $(dirname $BASH_SOURCE) && pwd)
OLD_DIR=$(pwd)

# Keep compatible with previous version.
if [[ ! -z "$BASH_ARGV" ]]; then
	source $PACKMAN_ROOT/bashrc
	return
fi

# Check Ruby availability.
RUBY_URL=http://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz
RUBY_SHA1=2dfcf7f33bda4078efca30ae28cb89cd0e36ddc4
RUBY_PACKAGE=$(basename $RUBY_URL)
RUBY_PACKAGE_DIR=$(basename $RUBY_PACKAGE .tar.gz)

if which shasum 2>&1 1> /dev/null 2>&1; then
    SHASUM=shasum
elif which sha1sum 2>&1 1> /dev/null 2>&1; then
    SHASUM=sha1sum
else
    SHASUM=none
fi

function install_ruby
{
    if [[ ! -d "$PACKMAN_ROOT/ruby" ]]; then
        mkdir "$PACKMAN_ROOT/ruby"
    fi
    cd $PACKMAN_ROOT/ruby
    if [[ ! -f $RUBY_PACKAGE ]]; then
        wget $RUBY_URL -O $RUBY_PACKAGE
    fi
    if [[ "$SHASUM" == 'none' || "$($SHASUM $RUBY_PACKAGE | cut -d ' ' -f 1)" != "$RUBY_SHA1" ]]; then
        echo '[Error]: Ruby is not downloaded successfully!'
        exit 1
    fi
    rm -rf $RUBY_PACKAGE_DIR
    tar -xzf $RUBY_PACKAGE
    cd $RUBY_PACKAGE_DIR
    echo "[Notice]: Building Ruby, please wait for a moment! If anything is wrong, please see $PACKMAN_ROOT/ruby/out!"
    if ! which gcc 2>&1 1> /dev/null 2>&1; then
        echo '[Error]: There is no GCC compiler!'
        exit 1
    fi
    CC=gcc CFLAGS=-fPIC ./configure --prefix=$PACKMAN_ROOT/ruby --disable-install-rdoc 1> $PACKMAN_ROOT/ruby/out 2>&1
    make install 1>> $PACKMAN_ROOT/ruby/out 2>&1
    cd $PACKMAN_ROOT/ruby
    rm -rf $RUBY_PACKAGE_DIR

    if [[ -d "$PACKMAN_ROOT/ruby/bin" ]]; then
        export PATH=$PACKMAN_ROOT/ruby/bin:$PATH
    fi
}

if ! which ruby 2>&1 1> /dev/null 2>&1; then
    echo '[Warning]: System does not provide a Ruby! PACKMAN will install one for you!'
    install_ruby
fi

RUBY_VERSION=$(ruby -v | cut -d ' ' -f 2)
if [[ $RUBY_VERSION =~ $(echo '^1\.8') || $RUBY_VERSION =~ $(echo '^1\.9') ]]; then
    echo "[Warning]: Ruby version is too old, PACKMAN will install a newer one for you!"
    install_ruby
fi

cd "$OLD_DIR"

# Check .bashrc in HOME.
if [[ "$SHELL" =~ "bash" ]]; then
	LINE="source $PACKMAN_ROOT/bashrc"
	if ! grep "$LINE" ~/.bashrc 1>/dev/null; then
		echo $LINE >> ~/.bashrc
		echo "[Notice]: Append \"$LINE\" into ~/.bashrc. Reopen or relogin to the terminal please."
	fi
elif [[ "$SHELL" =~ "fish" ]]; then
    LINE="source $PACKMAN_ROOT/config.fish"
    if ! grep "$LINE" ~/.config/fish/config.fish 1> /dev/null; then
        echo $LINE >> ~/.config/fish/config.fish
		echo "[Notice]: Append \"$LINE\" into ~/.config/fish/config.fish. Reopen or relogin to the terminal please."
    fi
else
	echo "[Error]: Shell $SHELL is not supported currently!"
	exit 1
fi
