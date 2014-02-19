# Module that checks whether ALUGrid is available.
# 
# Accepts the following variables:
#
# ALUGrid_DIR: Prefix where ALUGrid is installed.
# ALUGrid_LIB_NAME: Name of the ALUGrid library (default: alugrid).
# ALUGrid_LIBRARY: Full path of the METIS library.

# Sets the following variables:
#
# ALUGrid_LIBRARY: Full path of the ALUGrid library.
# ALUGrid_INCLUDE_DIRS: List of include directories
# ALUGrid_FOUND: True if ALUGrid was found.
# 
# Provides the following macros:
#
# find_package(ALUGrid)
#
# Searches for ALUGrid (See above)
#
#
# add_dune_alugrid_flags(TARGETS)
#
# Adds the necessary flags to comile and link TARGETS with ALUGrid support.
#

foreach(_dir ${ALUGrid_DIR})
  list(APPEND _ALUGrid_INCLUDE_DIRS ${ALUGrid_DIR} ${ALUGrid_DIR}/include)
endforeach(_dir ${ALUGrid_DIR})

find_path(ALUGrid_INCLUDE_DIR alugrid_serial.h PATHS ${_ALUGrid_INCLUDE_DIRS} NO_DEFAULT_PATH)

if(NOT ALUGrid_INCLUDE_DIR)
  find_path(ALUGrid_INCLUDE_DIR alugrid_serial.h)
endif(NOT ALUGrid_INCLUDE_DIRS)

set(ALUGrid_INCLUDE_DIRS ${ALUGrid_INCLUDE_DIR})
if(ALUGrid_INCLUDE_DIR)
  foreach(_subdir alu2d duneinterface parallel serial)
    list(APPEND ALUGrid_INCLUDE_DIRS ${ALUGrid_INCLUDE_DIR}/${_subdir})
  endforeach()
endif() 

set(ALUGrid_LIB_NAME "alugrid" CACHE STRING "Name of the ALUGrid library (default: alugrid).")
find_library(ALUGrid_LIBRARY ${ALUGrid_LIB_NAME} PATHS ${ALUGrid_DIR} ${ALUGrid_DIR}/lib NO_DEFAULT_PATH)

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set ALUGrid_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(ALUGrid DEFAULT_MSG
                                  ALUGrid_INCLUDE_DIR
                                  ALUGrid_LIBRARY)


function(add_dune_alugrid_flags )
  if(ALUGrid_FOUND)
    foreach(_target ${ARGN})
      target_link_libraries(${_target} ${ALUGrid_LIBRARY})
      get_target_property(_props ${_target} COMPILE_FLAGS)
      set_target_properties(${_target} PROPERTIES COMPILE_FLAGS
                            "${_props} -DENABLE_ALUGrid=1")
    endforeach(_target ${_targets})
  endif(ALUGrid_FOUND)
endfunction()


