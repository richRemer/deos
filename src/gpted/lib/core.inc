#!/bin/bash -e
# Core functions and settings.

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

[ $COREINC ] && return || COREINC=1

# generate an error if the environment variable is not set
# Usage:
#   needenv <var>
# Example:
#   needenv foo || echo "Missing foo"
needenv () {
    local var="$1"
    local val=`eval echo \\$$var`
    [ -n "$val" ]
}

# import module
# Usage:
#   import <module>
# Example:
#   import std      # import 'std' module
import () {
    local module=$1
    
    [ -e $lib/$module.inc ]
    . $lib/$module.inc
}

