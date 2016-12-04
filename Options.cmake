# g3log is a KjellKod Logger
# 2015 @author Kjell Hedström, hedstrom@kjellkod.cc 
# ==================================================================
# 2015 by KjellKod.cc. This is PUBLIC DOMAIN to use at your own
#    risk and comes  with no warranties.
#
# This code is yours to share, use and modify with no strings attached
#   and no restrictions or obligations.
# ===================================================================


# PLEASE NOTE THAT:
# the following definitions can through options be added 
# to the auto generated file src/g3log/generated_definitions.hpp
#   add_definitions(-DG3_DYNAMIC_LOGGING)
#   add_definitions(-DCHANGE_G3LOG_DEBUG_TO_DBUG)
#   add_definitions(-DDISABLE_FATAL_SIGNALHANDLING)
#   add_definitions(-DDISABLE_VECTORED_EXCEPTIONHANDLING)
#   add_definitions(-DDEBUG_BREAK_AT_FATAL_SIGNAL)



# Used for generating a macro definitions file  that is to be included
# that way you do not have to re-state the Options.cmake definitions when 
# compiling your binary (if done in a separate build step from the g3log library)
SET(G3_DEFINITIONS "")


# -DUSE_DYNAMIC_LOGGING_LEVELS=ON   : run-type turn on/off levels
option (USE_DYNAMIC_LOGGING_LEVELS
       "Turn ON/OFF log levels. An disabled level will not push logs of that level to the sink. By default dynamic logging is disabled" OFF)
IF(USE_DYNAMIC_LOGGING_LEVELS)
   LIST(APPEND G3_DEFINITIONS G3_DYNAMIC_LOGGING)
   MESSAGE(STATUS "-DUSE_DYNAMIC_LOGGING_LEVELS=ON")
   MESSAGE(STATUS "\tDynamic logging levels is used")
   MESSAGE(STATUS "\tUse  [g3::setLogLevel(LEVEL boolean)] to enable/disable logging on specified levels")
ELSE() 
  MESSAGE(STATUS "-DUSE_DYNAMIC_LOGGING_LEVELS=OFF") 
ENDIF(USE_DYNAMIC_LOGGING_LEVELS)

# -DCHANGE_G3LOG_DEBUG_TO_DBUG=ON   : change the DEBUG logging level to be DBUG to avoid clash with other libraries that might have
# predefined DEBUG for their own purposes
option (CHANGE_G3LOG_DEBUG_TO_DBUG
       "Use DBUG logging level instead of DEBUG. By default DEBUG is the debugging level" OFF)

IF(CHANGE_G3LOG_DEBUG_TO_DBUG)
   LIST(APPEND G3_DEFINITIONS CHANGE_G3LOG_DEBUG_TO_DBUG)
   MESSAGE(STATUS "-DCHANGE_G3LOG_DEBUG_TO_DBUG=ON")
   MESSAGE(STATUS "\tDBUG instead of DEBUG logging level is used")
ELSE() 
   MESSAGE(STATUS "-DCHANGE_G3LOG_DEBUG_TO_DBUG=OFF")
   MESSAGE(STATUS "\tDebuggin logging level is 'DEBUG' only") 
ENDIF(CHANGE_G3LOG_DEBUG_TO_DBUG)



# -DENABLE_FATAL_SIGNALHANDLING=ON   : defualt change the
# By default fatal signal handling is enabled. You can disable it with this option
# enumerated in src/stacktrace_windows.cpp 
option (ENABLE_FATAL_SIGNALHANDLING
    "Vectored exception / crash handling with improved stack trace" ON)

IF(NOT ENABLE_FATAL_SIGNALHANDLING)
   LIST(APPEND G3_DEFINITIONS DISABLE_FATAL_SIGNALHANDLING)

   MESSAGE(STATUS "-DENABLE_FATAL_SIGNALHANDLING=OFF")
   MESSAGE(STATUS "\tFatal signal handler is disabled")
ELSE() 
   MESSAGE(STATUS "-DENABLE_FATAL_SIGNALHANDLING=ON")
   MESSAGE(STATUS "\tFatal signal handler is enabled")
ENDIF(NOT ENABLE_FATAL_SIGNALHANDLING)

# WINDOWS OPTIONS
IF (MSVC OR MINGW) 
# -DENABLE_VECTORED_EXCEPTIONHANDLING=ON   : defualt change the
# By default vectored exception handling is enabled, you can disable it with this option. 
# Please know that only known fatal exceptions will be caught, these exceptions are the ones
# enumerated in src/stacktrace_windows.cpp 
   option (ENABLE_VECTORED_EXCEPTIONHANDLING
       "Vectored exception / crash handling with improved stack trace" ON)

    IF(NOT ENABLE_VECTORED_EXCEPTIONHANDLING)
       LIST(APPEND G3_DEFINITIONS DISABLE_VECTORED_EXCEPTIONHANDLING)
       MESSAGE(STATUS "-DENABLE_VECTORED_EXCEPTIONHANDLING=OFF")
	   MESSAGE(STATUS "\tVectored exception handling is disabled") 
    ELSE() 
       MESSAGE(STATUS "-DENABLE_VECTORED_EXCEPTIONHANDLING=ON")
	   MESSAGE(STATUS "\tVectored exception handling is enabled") 
    ENDIF(NOT ENABLE_VECTORED_EXCEPTIONHANDLING)


# Default ON. Will trigger a break point in DEBUG builds if the signal handler 
#  receives a fatal signal.
#
   option (DEBUG_BREAK_AT_FATAL_SIGNAL
      "Enable Visual Studio break point when receiving a fatal exception. In __DEBUG mode only" OFF)
   IF(DEBUG_BREAK_AT_FATAL_SIGNAL)
      LIST(APPEND G3_DEFINITIONS DEBUG_BREAK_AT_FATAL_SIGNAL)
      MESSAGE(STATUS "-DDEBUG_BREAK_AT_FATAL_SIGNAL=ON")
	  MESSAGE(STATUS "\tBreak point for fatal signal is enabled for __DEBUG.") 
   ELSE() 
      MESSAGE(STATUS "-DDEBUG_BREAK_AT_FATAL_SIGNAL=OFF")
	  MESSAGE(STATUS "\tBreak point for fatal signal is disabled") 
   ENDIF(DEBUG_BREAK_AT_FATAL_SIGNAL)
ENDIF (MSVC OR MINGW)

IF (MSVC)
   option (ENABLE_WIN_WSTRING_SUPPPORT
      "Allow windows UTF-16 strings as log messages" OFF)

   IF(NOT ENABLE_WIN_WSTRING_SUPPPORT)
     MESSAGE(STATUS "-DENABLE_WIN_WSTRING_SUPPPORT=OFF")
	 MESSAGE(STATUS "\tWide string support is disabled") 
   ELSE() 
	  LIST(APPEND G3_DEFINITIONS ENABLE_WIN_WSTRING_SUPPPORT)
      MESSAGE(STATUS "-DENABLE_WIN_WSTRING_SUPPPORT=ON")
	  MESSAGE(STATUS "\tWide string support is enabled") 
   ENDIF(NOT ENABLE_WIN_WSTRING_SUPPPORT)
ENDIF (MSVC)

MESSAGE(STATUS "\n")