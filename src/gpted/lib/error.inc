#!/bin/bash -e
# Function library for generating errors.

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

[ $ERRORINC ] && return || ERRORINC=1
import std

E_BADARG=101    # command called with incorrect/missing arguments

# generate an error
# Usage:
#   error <msg> [<status>]
# Examples:
#   error "Something went wrong"    # prints to stderr; exits with 1
#   error "Another problem" 100     # prints to stderr; exits with 100
error () {
    local status=${2:-1}
    err "$1"
    exit $status
}
