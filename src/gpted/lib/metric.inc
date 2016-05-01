#!/bin/bash -e
# Function library for working with metric data sizes.

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

[ $METRICINC ] && return || METRICINC=1
import std

# evaluates metric data size and prints number of bytes
# Usage:
#   metric_eval [--pretty] <size>
# Examples:
#   metric_eval 1KiB            # prints 1024
#   metric_eval --pretty 1KiB   # prints 1,024
metric_eval () {
    local pretty
    local size
    local prefix
    local unit=B
    local scale=1
    local sep=0

    [ "$1" == --pretty ] && pretty=1 && shift
    size=$1

    case $size in
        *B) unit=B; size=${size:0:-1};;
        *b) unit=b; size=${size:0:-1};;
    esac
    
    case $size in
        *k) prefix=k; let scale='10**3'; size=${size:0:-1};;
        *Ki) prefix=Ki; let scale='2**10'; size=${size:0:-2};;
        *M) prefix=M; let scale='10**6'; size=${size:0:-1};;
        *Mi) prefix=Mi; let scale='2**20'; size=${size:0:-2};;
        *G) prefix=G; let scale='10**9'; size=${size:0:-1};;
        *Gi) prefix=Gi; let scale='2**30'; size=${size:0:-2};;
        *T) prefix=T; let scale='10**12'; size=${size:0:-1};;
        *Ti) prefix=Ti; let scale='2**40'; size=${size:0:-2};;
    esac
    
    size=${size-1}
    echo $size | grep [^0-9] && error "Unrecognized size format" $E_BADARG

    let size='size*scale'
    [ $unit == b ] && (( $size % 8 != 0 )) \
        && error "Non-whole number of bytes" $E_BADARG
    [ $unit == b ] && let size='size/8'

    if [ $pretty ]; then
        size=`echo $size | rev`
        while ((${#size} > sep*4+3)); do
            size=${size:0:((sep*4+3))},${size:((sep*4+3))}
            let sep='sep+1'
        done
        size=`echo $size | rev`
    fi
    
    out "$size"
}
