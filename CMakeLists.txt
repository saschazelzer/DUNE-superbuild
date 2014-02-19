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
include(duneMacroGetModuleInfos)
include(duneMacroAddModule)
include(TopologicalSort)

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

option(DUNE_ENABLE_DOCUMENTATION "Build the DUNE module documentation." OFF)
option(DUNE_ENABLE_ALL_MODULES "Build all available DUNE modules." OFF)
option(DUNE_USE_BOOST "Use Boost in DUNE modules." OFF)
option(DUNE_USE_MPI "Use MPI in DUNE modules and third-party libraries." OFF)
option(DUNE_BOOTSTRAP "Bootstrap DUNE core modules." OFF)

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

# These flags are used for all DUNE modules

set(DUNE_CMAKE_CXX_FLAGS_RELEASE 
    "-O3 -Wall -DNDEBUG -funroll-loops -finline-functions -fomit-frame-pointer -ffast-math -mfpmath=sse -msse3 -march=native"
    CACHE STRING "Compile flags for DUNE modules")
SET(DUNE_CMAKE_CXX_FLAGS_DEBUG "-g -Wall" CACHE STRING "Compile flags for DUNE modules")


#-----------------------------------------------------------------------------
# External project support (Metis, ALUGrid, etc.)
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
  SuperLU
  Metis
  ParMetis
  SuperLU_DIST
  ALUGrid
)

# Set-up targets for external packages
foreach(_third_party_lib ${DUNE_THIRD_PARTY_LIBS})
  include(third-party/${_third_party_lib}.cmake)
endforeach()

#-----------------------------------------------------------------------------
# DUNE modules
#-----------------------------------------------------------------------------

set(DUNE_MODULES )
set(DUNE_BOOTSTRAP_MODULES )

if(DUNE_BOOTSTRAP)
  set(BOOTSTRAP_VERSION)
  set(_bootstrap_type)
  if(DUNE_BOOTSTRAP_FROM_TARBALLS)
    set(BOOTSTRAP_VERSION ${DUNE_BOOTSTRAP_FROM_TARBALLS})
    set(_bootstrap_type TARBALLS)
  elseif(DUNE_BOOTSTRAP_FROM_SVN_BRANCH)
    set(BOOTSTRAP_VERSION ${DUNE_BOOTSTRAP_FROM_SVN_BRANCH}.svn)
    set(_bootstrap_type SVN_BRANCH)
  else()
    set(_bootstrap_type SVN_TRUNK)
  endif()
  
  duneMacroGetBootstrapModuleInfo(${_bootstrap_type})
endif()

# Get module infos from non-bootstrapped modules and
# check if we need to run dune-autogen.
set(autogen_run_needed )
duneMacroGetModuleInfos(MODULE_DIRS ${DUNE_MODULE_DIRS}
                        MODULE_LIST_VARIABLE DUNE_MODULES
                        AUTOGEN_LIST_VARIABLE autogen_run_needed
                       )

# This will update the module information from boostrapped
# modules (overwrites the hard-coded infos in duneBootstrapCoreModules-*.cmake files)
# and also checks if we need to run dune-autogen (may be the case
# when bootstrapping from SVN).
duneMacroGetModuleInfos(MODULE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
                        AUTOGEN_LIST_VARIABLE autogen_run_needed
                       )

# Add build options and verify module dependencies.
# Do this before running dune-autogen to catch dependency
# errors ourselves.
set(_all_dune_modules ${DUNE_MODULES} ${DUNE_BOOTSTRAP_MODULES})
foreach(_dune_module ${_all_dune_modules})

  # Before adding the build option, verify that all dependencies
  # can be satisfied
  set(_module_deps_satisfied 1)
  set(_module_deps_unsatified )
  if(${_dune_module}_DEPENDS)
    foreach(_dep ${${_dune_module}_DEPENDS})
      list(FIND _all_dune_modules ${_dep} _found)
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
    
    # Add options for custom configure and compiler flags
    set(DUNE_MODULE_${_dune_module}_CONFIGURE_OPTIONS "" CACHE STRING
        "Custom configure options for ${_dune_module}")
    set(DUNE_MODULE_${_dune_module}_CXX_FLAGS_RELEASE "" CACHE STRING
        "Custom C++ Compiler release flags for ${_dune_module}")
    set(DUNE_MODULE_${_dune_module}_CXX_FLAGS_DEBUG "" CACHE STRING
        "Custom C++ Compiler debug flags for ${_dune_module}")
        
    mark_as_advanced(DUNE_MODULE_${_dune_module}_CONFIGURE_OPTIONS
                     DUNE_MODULE_${_dune_module}_CXX_FLAGS_RELEASE
                     DUNE_MODULE_${_dune_module}_CXX_FLAGS_DEBUG
                    )
    
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

set(autogen_cmd ${dune-common_SOURCE_DIR}/bin/dune-autogen)
if(autogen_run_needed)

  # One of the modules does not have a "configure" file.
  # Run dune-autogen just in case and re-read the module infos.
  
  foreach(_module ${autogen_run_needed})
    if(DUNE_ENABLE_MODULE_${_module})
    
      if(NOT EXISTS ${autogen_cmd})
        message(FATAL_ERROR "Command dune-autogen not found [${autogen_cmd}]")
      endif()
  
      set(_module_source_dirs )
      foreach(_dep ${${_module}_DEPENDS})
        list(APPEND _module_source_dirs ${${_dep}_SOURCE_DIR})
      endforeach()
      
      message(STATUS "Running dune-autogen for ${_module}...")
      execute_process(COMMAND ${autogen_cmd} . ${_module_source_dirs}
                      WORKING_DIRECTORY ${${_module}_SOURCE_DIR}
                      RESULT_VARIABLE _result
                      ERROR_VARIABLE _err
                      OUTPUT_QUIET
                     )
      if(NOT _result EQUAL 0)
        message(FATAL_ERROR "Running ${dune-common_SOURCE_DIR}/bin/dune-autogen in ${${_module}_SOURCE_DIR} failed with:\n${_err}")
      endif()
      
      # Now re-read the module infos (module dependencies should stay unchanged)
      duneFunctionGetModuleInfo(SOURCE_DIR "${${_module}_SOURCE_DIR}")
    endif()
  endforeach()
  
endif()

# Bootstrap DUNE core modules
if(DUNE_BOOTSTRAP)
  # Do a topological sort of the bootstrap module list
  topological_sort(DUNE_BOOTSTRAP_MODULES "" "_DEPENDS")
  duneMacroBootstrapCoreModules(MODULES ${DUNE_BOOTSTRAP_MODULES}
                                VERSION ${BOOTSTRAP_VERSION}
                                BASE_URL ${DUNE_BOOTSTRAP_BASE_URL}
                                ${_bootstrap_type}
                               )
endif()

# Do a topological sort of the modules from the DUNE_MODULE_DIRS list
topological_sort(DUNE_MODULES "" "_DEPENDS")

foreach(_dune_module ${DUNE_MODULES})
  if(DUNE_ENABLE_MODULE_${_dune_module} OR DUNE_ENABLE_ALL_MODULES)
    duneMacroAddModule(NAME ${_dune_module}
                       LOCATION_ARGS SOURCE_DIR ${${_dune_module}_SOURCE_DIR}
                      )
  endif()
endforeach()

#-----------------------------------------------------------------------------
# Special targets
#-----------------------------------------------------------------------------

set(_autogen_targets )
set(_configure_targets )
set(_build_targets )
foreach(_module ${DUNE_BOOTSTRAP_MODULES} ${DUNE_MODULES})
  if(DUNE_ENABLE_MODULE_${_module} OR DUNE_ENABLE_ALL_MODULES)
    set(_module_source_dirs )
    foreach(_dep ${${_module}_DEPENDS})
      list(APPEND _module_source_dirs ${${_dep}_SOURCE_DIR})
    endforeach()
    
    add_custom_target(autogen_${_module}
                      COMMAND ${autogen_cmd} . ${_module_source_dirs}
                      WORKING_DIRECTORY ${${_module}_SOURCE_DIR}
                     )
    list(APPEND _autogen_targets autogen_${_module})
    
    add_custom_target(configure_${_module}
                      COMMAND ${${_module}_SOURCE_DIR}/configure ${${_module}_CONFIGURE_OPTIONS}
                      WORKING_DIRECTORY ${${_module}_BINARY_DIR}
                     )
    list(APPEND _configure_targets configure_${_module})
    
    set(_build_target_depends )
    foreach(_dep ${${_module}_DEPENDS})
      list(APPEND _build_target_depends build_${_dep})
    endforeach()
    add_custom_target(build_${_module}
                      COMMAND $(MAKE)
                      WORKING_DIRECTORY ${${_module}_BINARY_DIR}
                      DEPENDS ${_build_target_depends}
                     )
    list(APPEND _build_targets build_${_module})
  endif()
endforeach()

if(_autogen_targets)
  add_custom_target(autogen_all DEPENDS ${_autogen_targets})
endif()

if(_configure_targets)
  add_custom_target(configure_all DEPENDS ${_configure_targets})
endif()

if(_build_targets)
  add_custom_target(build_all DEPENDS ${_build_targets})
endif()

#-----------------------------------------------------------------------------
# Install support
#-----------------------------------------------------------------------------

configure_file(DUNE-superbuild-config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/DUNE-superbuild-config.cmake)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/DUNE-superbuild-config.cmake DESTINATION .)

install(FILES cmake/config.h.cmake DESTINATION share/cmake)
install(FILES cmake/FindDUNE-superbuild.cmake DESTINATION share/cmake)
install(FILES cmake/DuneMPI.cmake DESTINATION share/cmake)
install(FILES cmake/DuneStreams.cmake DESTINATION share/cmake)
install(FILES cmake/FindCXX11Features.cmake DESTINATION share/cmake)
install(FILES cmake/FindParMETIS.cmake DESTINATION share/cmake)
install(FILES cmake/FindALUGrid.cmake DESTINATION share/cmake)

