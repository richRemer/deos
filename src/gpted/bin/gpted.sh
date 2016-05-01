#!/bin/bash -e
# Usage: gpted <command> [<command> ...]
# Generate disk image.

. `readlink -f \`dirname $0\``/../bootstrap.inc

while [ $# -gt 0 ]; do
    cmdsource=$1
    shift
    
    cmd=${cmdsource%%:*}
    [ "$cmdsource" != "$cmd" ] && cmdarg=${cmdsource#*:} || cmdarg=

    . $lib/$cmd.command
done
