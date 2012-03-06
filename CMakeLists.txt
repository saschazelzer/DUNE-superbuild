project(DUNE-superbuild)

cmake_minimum_required(VERSION 2.8.4)

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------

list(APPEND CMAKE_MODULE_PATH
     ${PROJECT_SOURCE_DIR}
    )

#-----------------------------------------------------------------------------
# CMake Function(s) and Macro(s)
#-----------------------------------------------------------------------------

include(ExternalProject)
include(duneMacroEmptyExternalProject)
include(duneMacroGetBootstrapModuleInfo)
include(duneMacroParseArguments)
include(duneMacroBootstrapCoreModules)
include(duneFunctionGetModuleInfo)

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
#-----------------------------------------------------------------------------

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)

  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY
               STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# CMake options
#-----------------------------------------------------------------------------

option(DUNE_ENABLE_DOCUMENTATION "Build the DUNE module documentation" OFF)
option(DUNE_USE_BOOST "Use Boost in DUNE modules" OFF)
option(DUNE_USE_MPI "Use MPI in DUNE modules and third-party libraries." OFF)
option(DUNE_BOOTSTRAP "Bootstrap DUNE core modules" ON)

set(DUNE_MODULE_DIRS "" CACHE STRING "A list of directories containing DUNE modules")

if(DUNE_USE_BOOST)
  find_package(Boost REQUIRED)
endif()

if(DUNE_USE_MPI)
  find_package(MPI REQUIRED)
endif()

if(DUNE_BOOTSTRAP)
  set(DUNE_BOOTSTRAP_FROM_TARBALLS "2.1.1" CACHE STRING "DUNE tarball version (e.g. 2.1.1).")
  set(DUNE_BOOTSTRAP_FROM_SVN_BRANCH "" CACHE STRING "DUNE release branch version (e.g. 2.1).")
  option(DUNE_BOOTSTRAP_FROM_SVN_TRUNK "Use DUNE SVN trunk for bootstrapping." OFF)
  
  if(NOT DUNE_BOOTSTRAP_FROM_TARBALLS AND NOT DUNE_BOOTSTRAP_FROM_SVN_BRANCH
     AND NOT DUNE_BOOTSTRAP_FROM_SVN_TRUNK)
    set(DUNE_BOOTSTRAP_FROM_TARBALLS "2.1.1")
  endif()
  
  # Sanity checks
  if(NOT DUNE_BOOTSTRAP_FROM_SVN_TRUNK)
    if(DUNE_BOOTSTRAP_FROM_TARBALLS)
      string(REPLACE "." ";" dune_tarball_version_list "${DUNE_BOOTSTRAP_FROM_TARBALLS}")
      list(LENGTH dune_tarball_version_list _length)
      if(NOT _length EQUAL 3)
        message(FATAL_ERROR "DUNE_BOOTSTRAP_FROM_TARBALLS variable must be of the form <major>.<minor>.<patch>")
      endif()
    else()
      string(REPLACE "." ";" dune_svn_branch_version_list "${DUNE_BOOTSTRAP_FROM_SVN_BRANCH}")
      list(LENGTH dune_svn_branch_version_list _length)
      if(NOT _length EQUAL 2)
        message(FATAL_ERROR "DUNE_BOOTSTRAP_FROM_SVN_BRANCH variable must be of the form <major>.<minor>")
      endif()
    endif()
  endif()

endif()


#-----------------------------------------------------------------------------
# C/CXX Flags
#-----------------------------------------------------------------------------

set(DUNE_CMAKE_CXX_FLAGS_RELEASE 
    "-O3 -Wall -DNDEBUG -funroll-loops -finline-functions -fomit-frame-pointer -ffast-math -mfpmath=sse -msse3 -march=native"
    CACHE STRING "Compile flags for DUNE modules")
SET(DUNE_CMAKE_CXX_FLAGS_DEBUG "-g -Wall" CACHE STRING "Compile flags for DUNE modules")


#-----------------------------------------------------------------------------
# Source directory
#-----------------------------------------------------------------------------

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()

# Entries in this list are package names used in --with-<package> configure args
# (case insensitive)
set(DUNE_THIRD_PARTY_LIBS
  Metis
  ParMetis
  ALUGrid
)

foreach(_third_party_lib ${DUNE_THIRD_PARTY_LIBS})
  include(third-party/${_third_party_lib}.cmake)
endforeach()

set(DUNE_MODULES )
set(DUNE_BOOTSTRAP_MODULES )

if(DUNE_BOOTSTRAP)
  set(_bootstrap_version)
  set(_bootstrap_type)
  if(DUNE_BOOTSTRAP_FROM_TARBALLS)
    set(_bootstrap_version ${DUNE_BOOTSTRAP_FROM_TARBALLS})
    set(_bootstrap_type TARBALLS)
  elseif(DUNE_BOOTSTRAP_FROM_SVN_BRANCH)
    set(_bootstrap_version ${DUNE_BOOTSTRAP_FROM_SVN_BRANCH}.0)
    set(_bootstrap_type SVN_BRANCH)
  else()
    set(_bootstrap_type SVN_TRUNK)
  endif()
  
  duneMacroGetBootstrapModuleInfo(VERSION ${_bootstrap_version} ${_bootstrap_type})
  #duneMacroBootstrapCoreModules(VERSION ${_bootstrap_version} ${_bootstrap_type})
endif()

# Get information about DUNE module dependencies
foreach(_module_dir ${DUNE_MODULE_DIRS})
  file(GLOB _entries "${_module_dir}/*")
  foreach(_entry ${_entries})
    if(IS_DIRECTORY "${_entry}")
      duneFunctionGetModuleInfo("${_entry}")
      if(DUNE_MODULE_FOUND)
        list(APPEND DUNE_MODULES ${DUNE_MODULE_NAME})
      endif()
    endif()
  endforeach()
endforeach()

# Add build options and verify module dependencies
foreach(_dune_module ${DUNE_MODULES} ${DUNE_BOOTSTRAP_MODULES})

  # Before adding the build option, verify that all dependencies
  # can be satisfied
  set(_module_deps_satisfied 1)
  set(_module_deps_unsatified )
  if(${_dune_module}_DEPENDS)
    foreach(_dep ${${_dune_module}_DEPENDS})
      list(FIND DUNE_MODULES ${_dep} _found)
      if(_found EQUAL -1)
        set(_module_deps_satisfied 0)
        list(APPEND _module_deps_unsatified ${_dep})
      endif()
    endforeach()
    if(NOT _module_deps_satisfied)
      message(WARNING "Skipping module ${_dune_module}. The following dependencies could not be satisfied: ${_module_deps_unsatified}")
    endif()
  endif()

  if(_module_deps_satisfied)
    set(_option_name DUNE_ENABLE_MODULE_${_dune_module})
    option(${_option_name} "Enable DUNE module ${_dune_module}" OFF)
    
    if(${_option_name} AND ${_dune_module}_DEPENDS)
      # enable dependencies
      foreach(_dep ${${_dune_module}_DEPENDS})
        if(NOT DUNE_ENABLE_MODULE_${_dep})
          message("Enabling DUNE module ${_dep} required by [${_dune_module}].")
          set(DUNE_ENABLE_MODULE_${_dep} ON CACHE BOOL "Enable DUNE module ${_dep}" FORCE)
        endif()
      endforeach()
    endif()
  endif()
endforeach()

# Todo dependency ordering
foreach(_dune_module ${DUNE_MODULES})
  if(DUNE_ENABLE_MODULE_${_dune_module})
    
  endif()
endforeach()

foreach(_module ${DUNE_MODULES})
  message("Module:   ${_module}")
  message("Dir:      ${${_module}_SOURCE_DIR}")
  message("Depends:  ${${_module}_DEPENDS}")
  message("Suggests: ${${_module}_SUGGESTS}")
endforeach()
