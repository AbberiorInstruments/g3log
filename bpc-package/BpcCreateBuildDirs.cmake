set( MSBUILD_CMD "C:\\Program Files (x86)\\MSBuild\\14.0\\Bin\\MSBuild.exe" )

function( bpc_build )
	
	if( CMAKE_HOST_UNIX )
		message( "Cmake is running on linux!" )
		set( IS_LINUX_HOSTED True )
	endif()
	
	if( ARGN )
		cmake_parse_arguments( "BUILD" "KEEP_CACHE;RUN_CMAKE;SET_IPREFIX" "BUILD_ROOT;INSTALL_ROOT;SOURCE_DIR;PLATFORMS" "" ${ARGN} )
	endif()
	
	if( NOT BUILD_SOURCE_DIR )
		get_filename_component( BUILD_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY )
	endif()

	if( NOT BUILD_INSTALL_ROOT )
		if( CMAKE_HOST_UNIX )
			set( BUILD_INSTALL_ROOT "$ENV{HOME}/Libraries" )
		else()
			set( BUILD_INSTALL_ROOT "${BUILD_SOURCE_DIR}-install" )
		endif()
	endif()
	
	if( NOT BUILD_BUILD_ROOT)
		if( CMAKE_HOST_UNIX )
			get_filename_component( sourcedir_name ${BUILD_SOURCE_DIR} NAME )
			set( BUILD_BUILD_ROOT "$ENV{HOME}/Build/${sourcedir_name}" )
		else()
			set( BUILD_BUILD_ROOT "${BUILD_SOURCE_DIR}-build" )
		endif()
	else()
		if( ${BUILD_BUILD_ROOT} MATCHES "^${BUILD_SOURCE_DIR}.*" )
			message( FATAL_ERROR "Will not build inside source tree! Please call the script from the intended build root." )
		endif()
	endif()
		
	if( NOT BUILD_PLATFORMS )
		if( CMAKE_HOST_UNIX )
			# Default is gcc 4.7.4 at the moment
			set( BUILD_PLATFORMS "GNU-32-Linux-4.7.4" )
		elseif( WIN32 )
			set( BUILD_PLATFORMS "MSVC-64-14.0;MSVC-32-14.0" )
		else()
			message( FATAL_ERROR "Cannot auto-set build platform!" )
		endif()
	endif()
	
	message( STATUS "Building from sources at ${BUILD_SOURCE_DIR}" )
	# Call batfile instead of msbuild directly for color output
	
	if( NOT CMAKE_HOST_UNIX )
		set( batfile "${BUILD_BUILD_ROOT}/build_for_cmake.bat" )
		message( STATUS "Writing build batch file: ${batfile}" )
		file( WRITE ${batfile} "" )
	endif()
	
	foreach( BUILD_PLATFORM ${BUILD_PLATFORMS} )
		if( "${BUILD_PLATFORM}" STREQUAL "NISOM" )
			set( BPC_TARGET_NISOM True )
		else()
			if( CMAKE_HOST_UNIX )
				set( BPC_TARGET_LINUX True )
			endif()
		endif()
		
		set( BPC_COMPILER ${BUILD_PLATFORM} )
		set( BUILD_DIR "${BUILD_BUILD_ROOT}/${BPC_COMPILER}" )
		
		message( STATUS "" )
		message( STATUS "Building platform ${BUILD_PLATFORM}:" )
		message( STATUS "Building into:  ${BUILD_DIR}" )
		
		if( BUILD_SET_IPREFIX )
			set( INSTALL_DIR "${BUILD_INSTALL_ROOT}/${BPC_COMPILER}" )
			message( STATUS "Building into: ${INSTALL_DIR}" )
			set( IPREFIX_ARG "-DCMAKE_INSTALL_PREFIX=${BUILD_INSTALL_ROOT}" )
		else()
			set( IPREFIX_ARG "-DXYZ_DUMMY=h")
		endif()
			
		
		if( NOT BUILD_KEEP_CACHE )
			message( STATUS "Removing cache" )
			file( REMOVE_RECURSE "${BUILD_DIR}" )
			set( BUILD_RUN_CMAKE True )
		endif()
		
		file( TO_NATIVE_PATH "${BUILD_DIR}" nbuild_dir )
		
		if( BPC_TARGET_NISOM )
			message( STATUS "Targeting NISOM platform." )
			
			if( BUILD_RUN_CMAKE )
				bpc_create_nisom_build( "Debug" )
				bpc_create_nisom_build( "RelWithDebInfo" )
			endif()
			
			file( APPEND ${batfile} "cd /D \"${nbuild_dir}\\Debug\"\n" )
			file( APPEND ${batfile} "jom install\n" )
			file( APPEND ${batfile} "cd /D \"${nbuild_dir}\\RelWithDebInfo\"\n" )
			file( APPEND ${batfile} "jom install\n" )
			
		elseif( BPC_TARGET_LINUX )
			if( BUILD_RUN_CMAKE )
				bpc_create_linux_build( ${BUILD_PLATFORM} "Release" True )
			endif()
		else()
			message( STATUS "Targeting Windows platform." )
				
			if( BUILD_RUN_CMAKE )
				bpc_create_windows_build( ${BUILD_PLATFORM} )
			endif()
			
			file( APPEND ${batfile} "\"${MSBUILD_CMD}\" \"${BUILD_DIR}\\INSTALL.vcxproj\" /p:Configuration=Debug\n" )
			file( APPEND ${batfile} "\"${MSBUILD_CMD}\" \"${BUILD_DIR}\\INSTALL.vcxproj\" /p:Configuration=RelWithDebInfo\n" )
		endif()
	endforeach()
	
	if( NOT CMAKE_HOST_UNIX )
		message( STATUS "Executing build script: ${batfile}" )
		execute_process(
			COMMAND "cmd.exe" "/c" "start" "cmd" "/k" "${batfile}"
		)
	endif()
endfunction()

function( bpc_create_nisom_build config )
	foreach( dir "${BUILD_SOURCE_DIR}/CMakeModules/toolchains" "${BUILD_SOURCE_DIR}/bpc-package" )
		if( EXISTS "${dir}/CMakeToolchainNISOM.cmake" )
			set( TOOLCHAIN_FILE "${dir}/CMakeToolchainNISOM.cmake" )
			break()
		endif()
	endforeach()

	if( NOT TOOLCHAIN_FILE )
		message( FATAL_ERROR "Could not find CMakeToolchainNISOM.cmake!" )
	endif()
	 
	message( STATUS "Executing cmake. Build dir: ${BUILD_DIR}" )
	execute_process(
		COMMAND ${CMAKE_COMMAND} "${BUILD_SOURCE_DIR}" "-B${BUILD_DIR}/${config}"
			"-GNMake Makefiles JOM" 
			"-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}" 
			"-DCMAKE_BUILD_TYPE=${config}"
			"${IPREFIX_ARG}"
	)
endfunction()

function( bpc_create_linux_build platform config do_build )
	# Ignore platform for now
	set( MY_GCC "-DCMAKE_C_COMPILER:STRING=gcc-4.7" )
	set( MY_GXX "-DCMAKE_CXX_COMPILER=g++-4.7" )

	message( STATUS "Executing cmake" )
	execute_process(
		COMMAND ${CMAKE_COMMAND} "${BUILD_SOURCE_DIR}" "-B${BUILD_DIR}/${config}" 
			"${MY_GCC}"
			"${MY_GXX}"
			"${IPREFIX_ARG}"
			"-DCMAKE_BUILD_TYPE=${config}"
	)
	if( do_build )
		message( "Executing make in ${BUILD_DIR}/${config}" )
		execute_process(
			COMMAND "make" "-j" "4" "install" 
			WORKING_DIRECTORY "${BUILD_DIR}/${config}"
		)
	endif()
endfunction()

function( bpc_create_windows_build platform )
	if ( "${platform}" STREQUAL "MSVC-64-14.0" )
		set( GENERATOR "-GVisual Studio 14 2015 Win64" )
	elseif( "${platform}" STREQUAL "MSVC-32-14.0" )
		set( GENERATOR "-GVisual Studio 14 2015" )
	else()
		message( FATAL_ERROR "Unknown platform: ${platform}" )
	endif()
		
	message( STATUS "Executing cmake" )
	
	execute_process(
		COMMAND ${CMAKE_COMMAND} "${BUILD_SOURCE_DIR}" "-B${BUILD_DIR}" 
			"${GENERATOR}" 
			"-DCMAKE_CONFIGURATION_TYPES=Debug;RelWithDebInfo"
			"${IPREFIX_ARG}"
	)
endfunction()

