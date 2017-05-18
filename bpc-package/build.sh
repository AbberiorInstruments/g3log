#!/bin/bash

mydir=`dirname $0`
workd=`pwd`

cmake -DBUILD_ARGS:STRING="BUILD_ROOT;$workd" -P $mydir/bpc_build.cmake

