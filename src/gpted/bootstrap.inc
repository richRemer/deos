#!/bin/bash -e

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

gpted=$0
bin=`dirname $gpted`
lib=`readlink -f $bin/../lib`
script=`basename $gpted`

. $lib/core.inc
