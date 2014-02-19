# Module configures the DUNE debug streams.
# A default debug level can be specified with
# MINIMAL_DEBUG_LEVEL
#
macro(dune_set_minimal_debug_level)
set(DUNE_MINIMAL_DEBUG_LEVEL ON CACHE STRING "set the MINIMAL_DEBUG_LEVEL. Standard debug streams with level below MINIMAL_DEBUG_LEVEL will collapse to doing nothing if output is requested. (default=warn)")
set_property(CACHE DUNE_MINIMAL_DEBUG_LEVEL PROPERTY STRINGS
  "grave" "warn" "info" "verb" "vverb")
if(MINIMAL_DEBUG_LEVEL MATCHES "grave")
  set(DUNE_MINIMAL_DEBUG_LEVEL_N 5)
elseif(MINIMAL_DEBUG_LEVEL MATCHES "info")
  set(DUNE_MINIMAL_DEBUG_LEVEL_N 3)
elseif(MINIMAL_DEBUG_LEVEL MATCHES "verb")
  set(DUNE_MINIMAL_DEBUG_LEVEL_N 2)
elseif(MINIMAL_DEBUG_LEVEL MATCHES "vverb")
  set(DUNE_MINIMAL_DEBUG_LEVEL_N 1)
else()
  set(DUNE_MINIMAL_DEBUG_LEVEL_N 4)
endif()
endmacro(dune_set_minimal_debug_level)


