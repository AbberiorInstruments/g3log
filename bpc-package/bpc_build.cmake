if( EXISTS "${CMAKE_CURRENT_LIST_DIR}/../CMakeModules" )
	include( "${CMAKE_CURRENT_LIST_DIR}/../CMakeModules/BpcCreateBuildDirs.cmake" )
else()
	include( "${CMAKE_CURRENT_LIST_DIR}/BpcCreateBuildDirs.cmake" )
endif()

message( "bpc_build BUILD_ARGS: ${BUILD_ARGS}" )
bpc_build( ${BUILD_ARGS} )