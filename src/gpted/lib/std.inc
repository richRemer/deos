#!/bin/bash -e
# Function library for writing to standard streams.

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

[ $STDINC ] && return || STDINC=1

# write to STDOUT
# Usage:
#   out <msg>
# Example:
#   out "FYI, blah blah..."     # prints to STDOUT
out () {
    echo "$1"
}

# write to STDERR
# Usage:
#   err <msg>
# Example:
#   err "Bad stuff..."          # prints to STDERR
err () {
    echo "$1" 1>&2
}

