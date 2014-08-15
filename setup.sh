#!/bin/bash

export PACKMAN_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export PATH=$PACKMAN_ROOT:$PATH
