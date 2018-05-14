
include( SelectLibraryConfigurations )
include( FindPackageHandleStandardArgs )
include( FindPackageCleanCache )

if( ZLIB_ROOT )
	set( paths PATHS "${ZLIB_ROOT}" NO_DEFAULT_PATH )
else()
	set( paths )
endif()

find_path( Zlib_INCLUDE_DIR zlib.h ${paths} PATH_SUFFIXES include )
set( Zlib_INCLUDE_DIRS ${Zlib_INCLUDE_DIR} )
mark_as_advanced( Zlib_INCLUDE_DIR )

if( Zlib_INCLUDE_DIR )
	file( STRINGS "${Zlib_INCLUDE_DIR}/zlib.h" line
		REGEX "^#define[ \t]+ZLIB_VER_MAJOR[ \t]+[0-9]+" )
	string( REGEX MATCH [0-9]+ Zlib_VERSION_MAJOR ${line} )
	file( STRINGS "${Zlib_INCLUDE_DIR}/zlib.h" line
		REGEX "^#define[ \t]+ZLIB_VER_MINOR[ \t]+[0-9]+" )
	string( REGEX MATCH [0-9]+ Zlib_VERSION_MINOR ${line} )
	file( STRINGS "${Zlib_INCLUDE_DIR}/zlib.h" line
		REGEX "^#define[ \t]+ZLIB_VER_REVISION[ \t]+[0-9]+" )
	string( REGEX MATCH [0-9]+ Zlib_VERSION_PATCH ${line} )
	set( Zlib_VERSION
		${Zlib_VERSION_MAJOR}.${Zlib_VERSION_MINOR}.${Zlib_VERSION_PATCH} )
endif()

find_library( Zlib_LIBRARY_RELEASE z zdll ${paths} PATH_SUFFIXES lib )
find_library( Zlib_LIBRARY_DEBUG zdlld ${paths} PATH_SUFFIXES lib )
SELECT_LIBRARY_CONFIGURATIONS( Zlib )

if( UNIX )
	FIND_PACKAGE_HANDLE_STANDARD_ARGS( Zlib
		REQUIRED_VARS
			Zlib_INCLUDE_DIR
			Zlib_LIBRARY
		VERSION_VAR Zlib_VERSION
	)

	if( Zlib_FOUND AND NOT TARGET Zlib::zlib )
		add_library( Zlib::zlib UNKNOWN IMPORTED )

		set_property( TARGET Zlib::zlib
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${Zlib_INCLUDE_DIR}" )
		set_property( TARGET Zlib::zlib
			PROPERTY IMPORTED_LOCATION "${Zlib_LIBRARY}" )
	endif()
elseif( WIN32 )
	find_file( Zlib_BINARY_RELEASE zlib1.dll ${paths} PATH_SUFFIXES bin )
	find_file( Zlib_BINARY_DEBUG zlib1d.dll ${paths} PATH_SUFFIXES bin )
	mark_as_advanced( Zlib_BINARY_RELEASE Zlib_BINARY_DEBUG )

	FIND_PACKAGE_HANDLE_STANDARD_ARGS( Zlib
		REQUIRED_VARS
			Zlib_INCLUDE_DIR
			Zlib_LIBRARY
			Zlib_BINARY_RELEASE
			Zlib_BINARY_DEBUG
		VERSION_VAR Zlib_VERSION
	)

	if( Zlib_FOUND AND NOT TARGET Zlib::zlib )
		add_library( Zlib::zlib SHARED IMPORTED )

		set_property( TARGET Zlib::zlib
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${Zlib_INCLUDE_DIR}" )
		foreach( configuration RELEASE DEBUG )
			set_property( TARGET Zlib::zlib
				APPEND PROPERTY IMPORTED_CONFIGURATIONS ${configuration} )
			set_property( TARGET Zlib::zlib
				PROPERTY IMPORTED_IMPLIB_${configuration} "${Zlib_LIBRARY_${configuration}}")
			set_property( TARGET Zlib::zlib
				PROPERTY IMPORTED_LOCATION_${configuration} "${Zlib_BINARY_${configuration}}")
		endforeach()
	endif()
endif()
