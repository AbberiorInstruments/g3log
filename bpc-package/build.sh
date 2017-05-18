#!/bin/bash

mydir=`dirname $0`
workd=`pwd`

echo $#
if   [ "$#" -eq 0 ]; then
    cmake -DBUILD_ARGS:STRING="BUILD_ROOT;$workd" -P $mydir/bpc_build.cmake
elif [ "$#" -eq 1 ]; then
	cmake -DBUILD_ARGS:STRING="BUILD_ROOT;$workd;SOURCE_DIR;$1" -P $mydir/bpc_build.cmake
fi


