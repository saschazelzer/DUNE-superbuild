# - Find the Distributed and Unified Numerics Environment (DUNE)
# 

#=============================================================================
# Copyright 2012 Sascha Zelzer
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================


set(dune_modules
  dune-common
  dune-grid
  dune-istl
  dune-localfunctions
  dune-pdelab
)

find_path(DUNE_ROOT_DIR include/dune/common/bartonnackmanifcheck.h)

find_file(DUNE_CMAKE_CONFIG_H config.h.cmake PATHS ${DUNE_ROOT_DIR} ${DUNE_ROOT_DIR}/share/cmake)

find_package(PkgConfig)

if(PKG_CONFIG_FOUND)
  find_path(DUNE_PKG_CONFIG_PATH dune-common.pc
            PATHS ${DUNE_ROOT_DIR} ${DUNE_ROOT_DIR}/lib/pkgconfig)
  if(DUNE_PKG_CONFIG_PATH)
    set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${DUNE_PKG_CONFIG_PATH}")
  endif()
endif()

foreach(dune_module ${dune_modules} ${DUNE_FIND_COMPONENTS})
  set(DUNE_${dune_module}_FOUND 0)
endforeach()

if(DUNE_FIND_COMPONENTS)
  # sanity check
else()
  set(DUNE_FIND_COMPONENTS ${dune_modules})
endif()

set(DUNE_INCLUDE_DIRS )
set(DUNE_LIBRARY_DIRS )
set(DUNE_LIBRARIES )

foreach(dune_module ${DUNE_FIND_COMPONENTS})
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(pkg_${dune_module} ${dune_module})
    message("[pkg check ${dune_module}] LDFLAGS = ${pkg_${dune_module}_LDFLAGS}")
    message("[pkg check ${dune_module}] LDFLAGS_OTHER = ${pkg_${dune_module}_LDFLAGS_OTHER}")
    message("[pkg check ${dune_module}] CFLAGS = ${pkg_${dune_module}_CFLAGS}")
    message("[pkg check ${dune_module}] CFLAGS_OTHER = ${pkg_${dune_module}_CFLAGS_OTHER}")
    message("[pkg check ${dune_module}] LIBRARIES = ${pkg_${dune_module}_LIBRARIES}")
  endif()
  
  string(REPLACE "dune-" "" _name ${dune_module})
  find_path(DUNE_${dune_module}_INCLUDE_DIR dune/${_name} 
            PATHS ${pkg_${dune_module}_INCLUDEDIR} ${DUNE_ROOT_DIR}/include)
  if(DUNE_${dune_module}_INCLUDE_DIR)
    list(APPEND DUNE_INCLUDE_DIRS ${DUNE_${dune_module}_INCLUDE_DIR})
  endif()
  
  string(REPLACE "-" "" _libname ${dune_module})
  # There might be no library for this module, if it is "header-only"
  find_library(DUNE_${_libname}_LIBRARY ${_libname}
               PATHS ${pkg_${dune_module}_LIBDIR} ${DUNE_ROOT_DIR}/lib)
  if(DUNE_${_libname}_LIBRARY)
    list(APPEND DUNE_LIBRARIES ${DUNE_${_libname}_LIBRARY})
  endif()

  foreach(_lib ${pkg_${dune_module}_LIBRARIES})
    find_library(DUNE_${_lib}_LIBRARY ${_lib}
                 PATHS ${pkg_${dune_module}_LIBDIR} ${DUNE_ROOT_DIR}/lib)
    if(DUNE_${_libname}_LIBRARY)
      list(APPEND DUNE_LIBRARIES ${DUNE_${_lib}_LIBRARY})
    endif()
  endforeach()

  if(DUNE_${dune_module}_INCLUDE_DIR)
    set(DUNE_${dune_module}_FOUND 1)
  endif()
endforeach()

if(DUNE_INCLUDE_DIRS)
  list(REMOVE_DUPLICATES DUNE_INCLUDE_DIRS)
endif()
if(DUNE_LIBRARIES)
  list(REMOVE_DUPLICATES DUNE_LIBRARIES)
endif()

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set DUNE_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(DUNE DEFAULT_MSG
                                  DUNE_ROOT_DIR
                                  DUNE_CMAKE_CONFIG_H
                                  DUNE_INCLUDE_DIRS
                                  DUNE_LIBRARIES)

if(DUNE_FOUND)
  include(${DUNE_ROOT_DIR}/share/cmake/DuneStreams.cmake)
  dune_set_minimal_debug_level()
endif()

