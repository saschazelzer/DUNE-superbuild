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
           --with-${_dune_module_dep}=${CMAKE_CURRENT_BINARY_DIR}/${_dune_module_dep}-${${_module_NAME}_VERSION}-build
          )
    endforeach()
  endif()
  
  ExternalProject_Add(${_module_NAME}
      SOURCE_DIR ${_module_NAME}-${_bootstrap_VERSION}-src
      BINARY_DIR ${_module_NAME}-${_bootstrap_VERSION}-build
      PREFIX ${_module_NAME}-${_bootstrap_VERSION}-cmake
      INSTALL_DIR ${_module_NAME}-${_bootstrap_VERSION}-install
      ${_module_LOCATION_ARGS}
      CONFIGURE_COMMAND <SOURCE_DIR>/configure --srcdir=<SOURCE_DIR> ${dune_module_configure_options}
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND ""
      DEPENDS ${third_party_deps} ${${_module_NAME}_DEPENDS}
    )

endmacro()
