#!/bin/bash -e
# Usage: gpted zero:<size>
# Generate bytes of zeroes. Size should be in bytes or in a standard metric
# format for data.
# 
# Metric Sizes
#   Base-10 prefixes: k M G T
#   Base-2 prefixes: Ki Mi Gi Ti
#   Standard unit for byte: B
#   Standard unit for bit: b

! $(return >/dev/null 2>&1) \
    && echo "`basename $0`: don't run directly" 1>&2 \
    && exit 1

import metric
bytes=`metric_eval $cmdarg`

dd if=/dev/zero bs=1 count=$bytes
