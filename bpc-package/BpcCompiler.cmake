if(NOT CMAKE_CXX_STANDARD)
	set(CMAKE_CXX_STANDARD 17)
endif()

if(NOT DEFINED BPC_STRICT_CXX_OPTIONS AND
	MSVC AND
	CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.12)

    set(BPC_STRICT_CXX_OPTIONS "/permissive-")
endif()

set(CMAKE_CXX_EXTENSIONS OFF)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	string( APPEND CMAKE_C_FLAGS " -Wall" )
	string( APPEND CMAKE_CXX_FLAGS " -Wall" )
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_SYSTEM_PROCESSOR STREQUAL "armv7l" )
	set( BPC_TARGET_NISOM ON )
		
	# Check if we are using the expected generator
	if(CMAKE_GENERATOR MATCHES "Makefiles" OR CMAKE_GENERATOR MATCHES "Ninja")
		message( "Using ${CMAKE_GENERATOR} to target NI-SOM platform" )
	else()
		message( "Warning: Invalid generator for NI-SOM platform." )
	endif()
		
	if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)
		set( BPC_COMPILER nisom )
	else()
		set( BPC_COMPILER nisom-cxx11 )
	endif()

	set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)

	set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib" "$ORIGIN")
		
	add_definitions(-DTARGET_NISOM)
		
	set( BPC_ARCHITECTURE "NISOM" )
		
	# Exclude from packaging as they are always on the sytem and just added to LIBRARIES for cross-compiling
	# Exclude all libraries that are part of the 
	set( BPC_NISOM_INSTALL_EXCLUDE_PATTERNS
		".*Zlib.*"
		".*LibTIFF.*"
	)
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

	set( CMAKE_POSITION_INDEPENDENT_CODE TRUE )
	
	if( CMAKE_SIZEOF_VOID_P EQUAL 4 )
		set( BPC_ARCHITECTURE "GNU-Linux-32" )
	elseif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		set( BPC_ARCHITECTURE "GNU-Linux-64" )
	endif()
elseif( WIN32 )
	if( BPC_AI_BRANDING )
		add_definitions( -D_AI_BRANDING )
	endif()

	if( MSVC )
		# Disable "dll interface" warning 
		string( APPEND CMAKE_CXX_FLAGS " /wd4251 /wd4275" )
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
			set( BPC_COMPILER ${CMAKE_CXX_COMPILER_ID} )
			if( CMAKE_SIZEOF_VOID_P EQUAL 4 )
				string( APPEND BPC_COMPILER -32 )
			elseif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
				string( APPEND BPC_COMPILER -64 )
			endif()
			if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.10 )
				string( APPEND BPC_COMPILER -14.0 )
			else()
				string( APPEND BPC_COMPILER -14.1 )
			endif()
			
			# This warning appears in boost/asio. Not clear whether it is a false positive (some issues
			# where reported with MSVC not getting this right) or with boost. Stays until the warning 
			# disappears or it is clear that it is not a compiler bug and boost if fixed or included
			# through some mechanism that will disable the warning for the buggy header in question
			if (CMAKE_CXX_COMPILER_VERSION EQUAL 19.13 )
				string( APPEND CMAKE_CXX_FLAGS " /wd4834" )
			endif()
			
			set( BPC_MFC_LIBRARY mfc140 )

			string( APPEND CMAKE_C_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /D_WIN32_WINNT=0x0600" )
			string( APPEND CMAKE_CXX_FLAGS " /wd4091" ) # typedef enum
			
			if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 19.12)
				add_definitions( -D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS )
			endif()

			if( NOT MSVC_IDE )
				# msbuild will set this in the culture section of the tc compiler potentially 
				# breaking rc when also setting it in the additional options
				string( FIND ${CMAKE_RC_FLAGS} "nologo" nl )
				if( nl EQUAL -1 )
					string( APPEND CMAKE_RC_FLAGS " /nologo" )
				endif()
			endif()
			#string( APPEND CMAKE_RC_FLAGS " /nologo" ) # typedef enum
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

		# Switch on edit and continue for Visual Studio 2017 64bit builds
		if( MSVC_IDE AND CMAKE_CL_64 AND (MSVC_VERSION GREATER_EQUAL 1910) )
			string( APPEND CMAKE_C_FLAGS_DEBUG " /ZI" )
			string( APPEND CMAKE_CXX_FLAGS_DEBUG " /ZI" )
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

