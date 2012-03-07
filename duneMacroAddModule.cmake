macro(duneMacroAddModule)

  macro_parse_arguments(_module "NAME;LOCATION_ARGS" "" ${ARGN})

  set(dune_module_configure_options
    CC=${CMAKE_C_COMPILER}
    CFLAGS=${CMAKE_C_FLAGS}
    CXX=${CMAKE_CXX_COMPILER}
    CPPFLAGS=${CMAKE_CXX_FLAGS}
   )
   
  if(NOT DUNE_ENABLE_DOCUMENTATION)
    list(APPEND dune_module_configure_options --disable-documentation)
  endif()
   
  if(DUNE_USE_BOOST)
    list(APPEND dune_module_configure_options --with-boost=${BOOST_ROOT})
  endif()
   
  if(DUNE_USE_MPI)
    list(APPEND dune_module_configure_options MPICC=${MPI_C_COMPILER} --enable-parallel)
  endif()

  set(third_party_deps )
  foreach(_third_party_lib ${DUNE_THIRD_PARTY_LIBS})
    string(TOUPPER "${_third_party_lib}" _third_party_lib_upper)
    string(TOLOWER "${_third_party_lib}" _third_party_lib_lower)
    list(FIND ${_module_NAME}_SUGGESTS ${_third_party_lib_lower} _found)
    if(DUNE_USE_${_third_party_lib_upper} AND _found GREATER -1)
      list(APPEND dune_module_configure_options --with-${_third_party_lib_lower}=${${_third_party_lib_upper}_DIR})
      list(APPEND third_party_deps ${${_third_party_lib_upper}_DEPENDS})
    endif()
  endforeach()

  # Use --with-<PACKAGE> options for module dependencies
  if(${_module_NAME}_DEPENDS)
    foreach(_dune_module_dep ${${_module_NAME}_DEPENDS})
      list(APPEND dune_module_configure_options
           --with-${_dune_module_dep}=${CMAKE_CURRENT_BINARY_DIR}/${_dune_module_dep}-${${_dune_module_dep}_VERSION}-build
          )
    endforeach()
  endif()
  
  # Add custom configure options
  list(APPEND dune_module_configure_options ${DUNE_MODULE_${_module_NAME}_CONFIGURE_OPTIONS})
  
  # Add compiler flags
  if(CMAKE_BUILD_TYPE STREQUAL Release)
    list(APPEND dune_module_configure_options
         "CXXFLAGS=${DUNE_CMAKE_CXX_FLAGS_RELEASE} ${DUNE_MODULE_${_module_NAME}_CXX_FLAGS_RELEASE}")
  elseif(CMAKE_BUILD_TYPE STREQUAL Debug)
    list(APPEND dune_module_configure_options
         "CXXFLAGS=${DUNE_CMAKE_CXX_FLAGS_DEBUG} ${DUNE_MODULE_${_module_NAME}_CXX_FLAGS_DEBUG}")
  endif()
  
  set(${_module_NAME}_CONFIGURE_OPTIONS ${dune_module_configure_options})
  set(${_module_NAME}_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${_module_NAME}-${${_module_NAME}_VERSION}-build)
  
  macro_parse_arguments(_tmp "SOURCE_DIR" "" ${_module_LOCATION_ARGS})
  list(GET _tmp_SOURCE_DIR 0 _tmp_SOURCE_DIR)
  if(NOT IS_ABSOLUTE "${_tmp_SOURCE_DIR}")
    set(_tmp_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${_tmp_SOURCE_DIR}")
  endif()
  if(NOT EXISTS "${_tmp_SOURCE_DIR}/configure" AND
     NOT DUNE_BOOTSTRAP_FROM_TARBALLS)
    set(_module_build_cmds 
        CONFIGURE_COMMAND cat /dev/null
        BUILD_COMMAND cat /dev/null
       )
    message(WARNING "!!Unconfigured DUNE module [${_module_NAME}]!!\nType make rebuild_cache && make after the initial build to complete the process.\n")
  else()
    set(_module_build_cmds 
        CONFIGURE_COMMAND <SOURCE_DIR>/configure --srcdir=<SOURCE_DIR> ${dune_module_configure_options}
        BUILD_COMMAND $(MAKE)
       )
  endif()
  
  ExternalProject_Add(${_module_NAME}
    ${_module_LOCATION_ARGS}
    BINARY_DIR ${_module_NAME}-${${_module_NAME}_VERSION}-build
    PREFIX ${_module_NAME}-${${_module_NAME}_VERSION}-cmake
    INSTALL_DIR ${_module_NAME}-${${_module_NAME}_VERSION}-install
    ${_module_build_cmds}
    INSTALL_COMMAND ""
    DEPENDS ${third_party_deps} ${${_module_NAME}_DEPENDS}
  )

endmacro()
