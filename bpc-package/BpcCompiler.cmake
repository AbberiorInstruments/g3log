if ( CMAKE_TOOLCHAIN_FILE )
	# We do this by hand at the moment and just call it nisom - may change
	get_filename_component( toolchain_file ${CMAKE_TOOLCHAIN_FILE} NAME )
	if ( ${toolchain_file} STREQUAL "CMakeToolchainNISOM.cmake" )
		set( BPC_TARGET_NISOM ON )
		
		# Check if we are using the expected generator
		if( ${CMAKE_GENERATOR} STREQUAL "MinGW Makefiles" )
			message( "Using MinGW to target NI-SOM platform" )
		elseif( ${CMAKE_GENERATOR} STREQUAL "NMake Makefiles" )
			message( "Using nmake to target NI-SOM platform" )
		elseif( ${CMAKE_GENERATOR} STREQUAL "NMake Makefiles JOM" )
			message( "Using JOM to target NI-SOM platform" )
		else()
			message( "Warning: Invalid generator for NI-SOM platform. Use 'Nmake Makefiles JOM'!" )
		endif()
		
		set( BPC_COMPILER nisom )
			
		# Compiler flags for the NI-SOM platform
		set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3 -mfloat-abi=softfp -Wall -Wno-psabi" )
		set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3 -mfloat-abi=softfp -Wall -Wno-psabi -std=c++11" )
		set( CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3 -mfloat-abi=softfp -Wall -Wno-psabi" )
		set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3 -mfloat-abi=softfp -Wall -Wno-psabi -std=c++11" )

		add_definitions(-DTARGET_NISOM)
		
		# Needed for the NISOM platform for some reason. 
		set( THREADS_PTHREAD_ARG "-pthread" )
	endif()
elseif( UNIX )
	set( BPC_COMPILER ${CMAKE_CXX_COMPILER_ID} )
	if( CMAKE_SIZEOF_VOID_P EQUAL 4 )
		string( APPEND BPC_COMPILER -32 )
	elseif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		string( APPEND BPC_COMPILER -64 )
	endif()
	string( REGEX REPLACE "^([^-]+).*$" "\\1" system_name ${CMAKE_SYSTEM_NAME} )
	string( APPEND BPC_COMPILER -${system_name} )
	string( APPEND BPC_COMPILER -${CMAKE_CXX_COMPILER_VERSION} )

	if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5 )
		string( APPEND CMAKE_CXX_FLAGS " -std=c++11" )
	else()
		string( APPEND CMAKE_CXX_FLAGS " -std=c++14" )
	endif()

	set( CMAKE_POSITION_INDEPENDENT_CODE TRUE )
elseif( WIN32 )
	if( BPC_AI_BRANDING )
		add_definitions( -D_AI_BRANDING )
	endif()

	if( MINGW )
		set( BPC_COMPILER GCC-4.7 )

		string( APPEND CMAKE_C_FLAGS " -DWIN32_LEAN_AND_MEAN" )
		string( APPEND CMAKE_CXX_FLAGS " -DWIN32_LEAN_AND_MEAN" )
		string( APPEND CMAKE_C_FLAGS_DEBUG " -D_DEBUG" )
		string( APPEND CMAKE_CXX_FLAGS_DEBUG " -D_DEBUG" )
	elseif( MSVC )
		if( MSVC90 )
			if( NOT CMAKE_CL_64 )
				set( BPC_COMPILER MSVC-9.0/win32 )
			else()
				set( BPC_COMPILER MSVC-9.0/win64 )
			endif()
			set( BPC_MFC_LIBRARY mfc90 )

			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0501" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0501" )
			string( APPEND CMAKE_C_FLAGS " /D_BIND_TO_CURRENT_VCLIBS_VERSION=1" )
			string( APPEND CMAKE_CXX_FLAGS " /D_BIND_TO_CURRENT_VCLIBS_VERSION=1" )
		elseif( MSVC10 )
			if( NOT CMAKE_CL_64 )
				set( BPC_COMPILER MSVC-10.0/win32 )
			else()
				set( BPC_COMPILER MSVC-10.0/win64 )
			endif()
			set( BPC_MFC_LIBRARY mfc100 )

			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0600" )
		elseif( MSVC11 )
			if( NOT CMAKE_CL_64 )
				set( BPC_COMPILER MSVC-11.0/win32 )
			else()
				set( BPC_COMPILER MSVC-11.0/win64 )
			endif()
			set( BPC_MFC_LIBRARY mfc110 )

			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0600" )
		elseif( MSVC12 )
			if( NOT CMAKE_CL_64 )
				set( BPC_COMPILER MSVC-12.0/win32 )
			else()
				set( BPC_COMPILER MSVC-12.0/win64 )
			endif()
			set( BPC_MFC_LIBRARY mfc120 )

			string( APPEND CMAKE_C_FLAGS " /DNO_WARN_MBCS_MFC_DEPRECATION" )
			string( APPEND CMAKE_CXX_FLAGS " /DNO_WARN_MBCS_MFC_DEPRECATION" )
			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_C_FLAGS " /D_WINSOCK_DEPRECATED_NO_WARNINGS" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WINSOCK_DEPRECATED_NO_WARNINGS" )
		elseif( MSVC14 )
			if( NOT CMAKE_CL_64 )
				set( BPC_COMPILER MSVC-32-14.0 )
			else()
				set( BPC_COMPILER MSVC-64-14.0 )
			endif()
			set( BPC_MFC_LIBRARY mfc140 )

			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /wd4091" ) # typedef enum
		endif()
		string( APPEND CMAKE_C_FLAGS " /DNOMINMAX" )
		string( APPEND CMAKE_CXX_FLAGS " /DNOMINMAX" )
		string( APPEND CMAKE_C_FLAGS " /DWIN32_LEAN_AND_MEAN" )
		string( APPEND CMAKE_CXX_FLAGS " /DWIN32_LEAN_AND_MEAN" )
		string( APPEND CMAKE_C_FLAGS " /D_CRT_SECURE_NO_WARNINGS" )
		string( APPEND CMAKE_CXX_FLAGS " /D_CRT_SECURE_NO_WARNINGS" )
		string( APPEND CMAKE_CXX_FLAGS " /D_SCL_SECURE_NO_WARNINGS" )
		string( APPEND CMAKE_CXX_FLAGS " /wd4250" ) # virtual inheritance
		string( APPEND CMAKE_CXX_FLAGS " /wd4800" ) # conversion to bool
		string( APPEND CMAKE_SHARED_LINKER_FLAGS " /MANIFEST:NO" )
		string( APPEND CMAKE_MODULE_LINKER_FLAGS " /MANIFEST:NO" )

		if( MSVC_IDE AND NOT CMAKE_CL_64 )
			# enable 'edit and continue'
			string( APPEND CMAKE_C_FLAGS_DEBUG " /ZI" )
			string( APPEND CMAKE_CXX_FLAGS_DEBUG " /ZI" )
			if( MSVC11 OR MSVC12 OR MSVC14 )
				string( APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG " /SAFESEH:NO" )
				string( APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG " /SAFESEH:NO" )
				string( APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG " /SAFESEH:NO" )
			endif()
		endif()

		set( BUILD_SHARED_LIBS TRUE )

		if( MSVC_IDE AND NOT BPC_KEEP_ZERO_CHECK )
			set( CMAKE_SUPPRESS_REGENERATION TRUE )
		endif()
		
		# CRT, MFC
		bpc_if_not_defined_set( BPC_MFC_ENCODING "unicode" )

		function( bpc_find_system_libraries return debug )
			set( CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS )
			set( CMAKE_INSTALL_DEBUG_LIBRARIES ${debug} )
			set( CMAKE_INSTALL_DEBUG_LIBRARIES_ONLY ${debug} )
			set( CMAKE_INSTALL_UCRT_LIBRARIES ${debug} )
			set( CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE )
			include( InstallRequiredSystemLibraries )
			set( ${return} ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} PARENT_SCOPE )
		endfunction()

		set( CMAKE_INSTALL_MFC_LIBRARIES FALSE )
		bpc_find_system_libraries( CRT_BINARIES_RELEASE FALSE )
		bpc_find_system_libraries( CRT_BINARIES_DEBUG TRUE )
		set( CRT_BINARIES_RELWITHDEBINFO ${CRT_BINARIES_RELEASE} )

		set( CMAKE_INSTALL_MFC_LIBRARIES TRUE )
		bpc_find_system_libraries( MFC_BINARIES_RELEASE FALSE )
		bpc_find_system_libraries( MFC_BINARIES_DEBUG TRUE )
		bpc_list_subtract( MFC_BINARIES_RELEASE "${MFC_BINARIES_RELEASE}" "${CRT_BINARIES_RELEASE}" )
		bpc_list_subtract( MFC_BINARIES_DEBUG "${MFC_BINARIES_DEBUG}" "${CRT_BINARIES_DEBUG}" )
		set( MFC_BINARIES_RELWITHDEBINFO ${MFC_BINARIES_RELEASE} )

		macro( bpc_link_mfc target )
			if( BPC_MFC_ENCODING STREQUAL mbcs )
				set_property( TARGET ${target}
					APPEND PROPERTY COMPILE_DEFINITIONS _AFXDLL )
				target_link_libraries( ${target} PRIVATE
					debug ${BPC_MFC_LIBRARY}d optimized ${BPC_MFC_LIBRARY} )
			elseif( BPC_MFC_ENCODING STREQUAL unicode )
				set_property( TARGET ${target}
					APPEND PROPERTY COMPILE_DEFINITIONS _AFXDLL _UNICODE UNICODE )
				target_link_libraries( ${target} PRIVATE
					debug ${BPC_MFC_LIBRARY}ud optimized ${BPC_MFC_LIBRARY}u )
			else()
				message( FATAL_ERROR "Unknown encoding '${BPC_MFC_ENCODING}' for MFC" )
			endif()
			set_property( TARGET ${target} PROPERTY Qt5_NO_LINK_QTMAIN TRUE )
		endmacro()
	endif()

	if( CMAKE_SIZEOF_VOID_P EQUAL 4 )
		set( BPC_ARCHITECTURE "win32" )
	elseif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		set( BPC_ARCHITECTURE "win64" )
	endif()
endif()

set( BPC_BINARY_DIRECTORY "bin/${BPC_ARCHITECTURE}$<$<CONFIG:Debug>:_d>" )
set( BPC_SYMBOLS_DIRECTORY "pdb/${BPC_ARCHITECTURE}$<$<CONFIG:Debug>:_d>" )
set( BPC_LIBRARY_DIRECTORY "sdk/lib/${BPC_ARCHITECTURE}$<$<CONFIG:Debug>:_d>" )

function( bpc_add_debugging target executable arguments working_directory )
  if( MSVC12 OR MSVC14 )
    file( WRITE ${CMAKE_CURRENT_BINARY_DIR}/${target}.vcxproj.user
"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
"<Project ToolsVersion=\"14.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n"
"  <PropertyGroup>\n"
"    <LocalDebuggerCommand>${executable}</LocalDebuggerCommand>\n"
"    <LocalDebuggerCommandArguments>${arguments}</LocalDebuggerCommandArguments>\n"
"    <LocalDebuggerWorkingDirectory>${working_directory}</LocalDebuggerWorkingDirectory>\n"
"  </PropertyGroup>\n"
"</Project>\n"
    )
  endif()
endfunction()

