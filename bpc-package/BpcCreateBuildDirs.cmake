set( MSBUILD_CMD "C:\\Program Files (x86)\\MSBuild\\14.0\\Bin\\MSBuild.exe" )

function( bpc_build )
	
	# Platforms that can be built on windows
	set( KNOWN_PLATFORMS_WINDOWS
		"MSVC-64-14.0"
		"MSVC-32-14.0"
		"NISOM"
	)
	
	set( KNOWN_PLATFORMS_LINUX
		"GNU-64-Linux-4.7.4"
	)
	
	if( CMAKE_HOST_UNIX )
		message( "Cmake is running on linux!" )
		set( IS_LINUX_HOSTED True )
	endif()
	
	if( ARGN )
		cmake_parse_arguments( "BUILD" "KEEP_CACHE;RUN_CMAKE;NOBUILD" "BUILD_PREFIX;INSTALL_PREFIX;SOURCE_DIR;TARGET" "PLATFORMS;CONFIGURATIONS" ${ARGN} )
	endif()
	
	if( NOT BUILD_SOURCE_DIR )
		get_filename_component( BUILD_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY )
	else()
		file( TO_CMAKE_PATH ${BUILD_SOURCE_DIR} BUILD_SOURCE_DIR)
	endif()

	set( DEFAULTS_FILE "${BUILD_SOURCE_DIR}/BpcPackageDefaults.cmake" )

	if( EXISTS "${DEFAULTS_FILE}" )
		message( STATUS "Reading package defaults from: ${DEFAULTS_FILE}" )
		include( "${DEFAULTS_FILE}" )
	else()
		message( STATUS "No package defaults file found at: ${DEFAULTS_FILE}" )
	endif()
	
	if( NOT BUILD_INSTALL_PREFIX )
		if( BPC_INSTALL_PREFIX )
			set( BUILD_INSTALL_PREFIX ${BPC_INSTALL_PREFIX} )
		else()
			if( CMAKE_HOST_UNIX )
				set( BUILD_INSTALL_PREFIX "$ENV{HOME}/Libraries" )
			else()
				set( BUILD_INSTALL_PREFIX "${BUILD_SOURCE_DIR}-install" )
			endif()
		endif()
	else()
		file( TO_CMAKE_PATH ${BUILD_INSTALL_PREFIX} BUILD_INSTALL_PREFIX)
	endif()
	
	if( NOT BUILD_BUILD_PREFIX)
		if( CMAKE_HOST_UNIX )
			get_filename_component( sourcedir_name ${BUILD_SOURCE_DIR} NAME )
			set( BUILD_BUILD_PREFIX "$ENV{HOME}/Build/${sourcedir_name}" )
		else()
			set( BUILD_BUILD_PREFIX "${BUILD_SOURCE_DIR}-build" )
		endif()
	else()
		file( TO_CMAKE_PATH ${BUILD_BUILD_PREFIX} BUILD_BUILD_PREFIX)
		
		if( ${BUILD_BUILD_PREFIX} MATCHES "^${BUILD_SOURCE_DIR}(/|$).*" )
			message( STATUS "Build Root: ${BUILD_BUILD_PREFIX}" )
			message( STATUS "Source Dir: ${BUILD_SOURCE_DIR}" )
			message( FATAL_ERROR "Will not build inside source tree. build.sh or build.bat should be called from the intended BUILD_PREFIX directory!" )
		endif()
	endif()
		
	if( NOT BUILD_PLATFORMS )
		if( CMAKE_HOST_UNIX )
			set( KNOWN_PLATFORMS ${KNOWN_PLATFORMS_LINUX} )
		else()
			set( KNOWN_PLATFORMS ${KNOWN_PLATFORMS_WINDOWS} )
		endif()
		set( BUILD_PLATFORMS )
		if( BPC_PACKAGE_PLATFORMS )
			foreach( p ${BPC_PACKAGE_PLATFORMS} )
				list( FIND KNOWN_PLATFORMS ${p} _idx )
				if( "${_idx}" GREATER "-1" )
					list( APPEND BUILD_PLATFORMS "${p}" )
				endif()
			endforeach()
		else()
			set( BUILD_PLATFORMS ${KNOWN_PLATFORMS} )
		endif()
	endif()
	
	if( NOT BUILD_PLATFORMS )
		message( FATAL_ERROR "No valid platforms to build package for!" )
	endif()
	
	message( STATUS "Building from sources at ${BUILD_SOURCE_DIR}" )
	message( STATUS "Building platforms: ${BUILD_PLATFORMS}" )
	# Call batfile instead of msbuild directly for color output
	
	if( NOT CMAKE_HOST_UNIX )
		set( batfile "${BUILD_BUILD_PREFIX}/build_for_cmake.bat" )
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
		set( BUILD_DIR "${BUILD_BUILD_PREFIX}/${BPC_COMPILER}" )
		
		message( STATUS "" )
		message( STATUS "Building platform ${BUILD_PLATFORM}:" )
		message( STATUS "Building into:  ${BUILD_DIR}" )
		
		set( INSTALL_DIR "${BUILD_INSTALL_PREFIX}/${BPC_COMPILER}" )
		message( STATUS "Building into: ${INSTALL_DIR}" )
		set( IPREFIX_ARG "-DCMAKE_INSTALL_PREFIX=${BUILD_INSTALL_PREFIX}" )	
		
		if( NOT BUILD_KEEP_CACHE )
			message( STATUS "Removing cache" )
			file( REMOVE_RECURSE "${BUILD_DIR}" )
			set( BUILD_RUN_CMAKE True )
		endif()
		
		file( TO_NATIVE_PATH "${BUILD_DIR}" nbuild_dir )
		
		if( BPC_TARGET_NISOM )
			message( STATUS "Targeting NISOM platform." )
			
			if( NOT BUILD_CONFIGURATIONS )
				set( BUILD_CONFIGURATIONS "Debug;RelWithDebInfo" )
			endif()
			
			if( NOT BUILD_TARGET )
				set( target "install" )
			else()
				set( target ${BUILD_TARGET} )
			endif()
		
			foreach( config ${BUILD_CONFIGURATIONS} )
				if( BUILD_RUN_CMAKE )
					bpc_create_nisom_build( ${config} )
				endif()
			
				if( NOT BUILD_NOBUILD )
					file( APPEND ${batfile} "cd /D \"${nbuild_dir}\\${config}\"\n" )
					file( APPEND ${batfile} "jom ${target}\n" )
				endif()
			endforeach()
			
		elseif( BPC_TARGET_LINUX )
			if( NOT BUILD_CONFIGURATIONS )
				set( BUILD_CONFIGURATIONS "Release" )
			endif()
			
			if( NOT BUILD_TARGET )
				set( target "install" )
			else()
				set( target ${BUILD_TARGET} )
			endif()
		
			if( BUILD_RUN_CMAKE )
				foreach( config ${BUILD_CONFIGURATIONS} )
					bpc_create_linux_build( ${BUILD_PLATFORM} ${config} ${BUILD_NOBUILD} ${target} )
				endforeach()
			endif()
		else()
			message( STATUS "Targeting Windows platform." )

			if( NOT BUILD_CONFIGURATIONS )
				set( BUILD_CONFIGURATIONS "Debug;RelWithDebInfo" )
			endif()
			
			if( BUILD_RUN_CMAKE )
				bpc_create_windows_build( ${BUILD_PLATFORM} )
			endif()
			
			if( NOT BUILD_TARGET )
				set( target "INSTALL" )
			else()
				set( target ${BUILD_TARGET} )
			endif()
			
			if( NOT BUILD_NOBUILD )
				foreach( config ${BUILD_CONFIGURATIONS} )
					file( APPEND ${batfile} "\"${MSBUILD_CMD}\" \"${BUILD_DIR}\\${target}.vcxproj\" /p:Configuration=${config}\n" )
				endforeach()
			endif()
		endif()
	endforeach()
	
	if( NOT CMAKE_HOST_UNIX AND NOT BUILD_NOBUILD )
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

function( bpc_create_linux_build platform config nobuild target )
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
	if( NOT nobuild )
		message( "Executing make in ${BUILD_DIR}/${config}" )
		execute_process(
			COMMAND "make" "-j" "4" "${target}" 
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

