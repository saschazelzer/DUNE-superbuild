
# This macro includes the appropriate .cmake file for setting
# *_DEPENDS, *_SUGGESTS, etc. variables for DUNE core modules
# which are not yet available in the filesystem.
#
macro(duneMacroGetBootstrapModuleInfo)

  macro_parse_arguments(_bootstrap
                        "VERSION"
                        "SVN_BRANCH;SVN_TRUNK;TARBALLS"
                        ${ARGN}
                       )

  set(_bootstrap_file "${CMAKE_SOURCE_DIR}/duneBootstrapCoreModules")

  if(NOT _bootstrap_SVN_TRUNK)
    # Sanity checks
    string(REPLACE "." ";" _version_list "${_bootstrap_VERSION}")
    list(LENGTH _version_list _length)
    if(NOT _length EQUAL 3)
      message(FATAL_ERROR "VERSION argument must be of the form <major>.<minor>.<patch>")
    endif()
    list(GET _version_list 0 _version_major)
    list(GET _version_list 1 _version_minor)
    list(GET _version_list 2 _version_patch)
    
    if(NOT EXISTS "${_bootstrap_file}-${_version_major}.${_version_minor}.cmake")
      message(WARNING "Using defaults for bootstrapping DUNE core modules version ${_bootstrap_VERSION}")
      set(_bootstrap_file "${_bootstrap_file}-fallback.cmake")
    else()
      set(_bootstrap_file "${_bootstrap_file}-${_version_major}.${_version_minor}.cmake")
    endif()
  else()
    set(_bootstrap_VERSION "svntrunk")
    set(_bootstrap_file "${_bootstrap_file}-svntrunk.cmake")
  endif()

  # Include CMake file setting core module dependencies information
  include(${_bootstrap_file})
  
  foreach(_module ${dune_core_modules})
    set(${_module}_VERSION "${_bootstrap_VERSION}")
  endforeach()

endmacro()
