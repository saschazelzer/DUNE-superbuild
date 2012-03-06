#-----------------------------------------------------------------------------
# Metis
#-----------------------------------------------------------------------------

option(DUNE_USE_METIS "Use the Metis library in DUNE modules" OFF)

if(DUNE_USE_METIS)

  # Sanity checks
  if(DEFINED METIS_DIR AND NOT EXISTS ${METIS_DIR})
    message(FATAL_ERROR "METIS_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj Metis)
  set(proj_DEPENDENCIES )
  set(METIS_DEPENDS ${proj})

  if(NOT DEFINED METIS_DIR)
  
    set(DUNE_USE_METIS_VERSION "" CACHE STRING "The Metis version to use")
    mark_as_advanced(DUNE_USE_METIS_VERSION)
    
    set(location_args )
    if(${proj}_URL)
      # We have a custom URL to fetch Metis from
      if(NOT DUNE_USE_METIS_VERSION)
        message(SEND_FATAL "${proj}_URL is set but DUNE_USE_METIS_VERSION is not!")
      endif()
    elseif(DUNE_USE_METIS_VERSION)
      # Get a specific Metis version from the "OLD" directory
      set(${proj}_URL http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/OLD/metis-${DUNE_USE_METIS_VERSION}.tar.gz)
    else()
      # Get the default version
      set(DUNE_USE_METIS_VERSION 5.0.2)
      set(${proj}_URL http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-${DUNE_USE_METIS_VERSION}.tar.gz)
      list(APPEND location_args URL_MD5 acb521a4e8c2e6dd559a7f9abd0468c5)
    endif()
    
    list(APPEND location_args URL ${${proj}_URL})
    
    message("Building ${proj} ${DUNE_USE_METIS_VERSION} from ${${proj}_URL}.")
    
    if(DUNE_USE_METIS_VERSION VERSION_LESS 5)
    
      # Use traditional make/configure steps
      
      CONFIGURE_FILE("${CMAKE_SOURCE_DIR}/third-party/Metis_Makefile.in"
                     "${CMAKE_CURRENT_BINARY_DIR}/Metis_Makefile.in")
      
      ExternalProject_Add(${proj}
        SOURCE_DIR ${proj}-src
        BINARY_DIR ${proj}-src
        PREFIX ${proj}-cmake
        ${location_args}
        CONFIGURE_COMMAND ""
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/Metis_Makefile.in"
                                                            "<SOURCE_DIR>/Makefile.in"
        BUILD_COMMAND $(MAKE)
        INSTALL_COMMAND ""
        DEPENDS ${proj_DEPENDENCIES}
       )
      
      set(METIS_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-src)
      
    else()
    
      # Use the Metis CMake scripts
      
      option(METIS_ENABLE_OPENMP "Enable OpenMP support in ParMetis" OFF)
      option(METIS_BUILD_SHARED "Build ParMetis as a shared library" OFF)
      
      set(METIS_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Choose the type of build for ${proj}")
      mark_as_advanced(METIS_BUILD_TYPE)
     
      ExternalProject_Add(${proj}
        SOURCE_DIR ${proj}-src
        BINARY_DIR ${proj}-build
        INSTALL_DIR ${proj}-install
        PREFIX ${proj}-cmake
        ${location_args}
        CMAKE_GENERATOR ${gen}
        CMAKE_CACHE ARGS
          -DCMAKE_BUILD_TYPE:STRING=${METIS_BUILD_TYPE}
          -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
          -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
          -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
          -DGKLIB_PATH:PATH=<SOURCE_DIR>/GKlib
          -DGDB:BOOL=0
          -DASSERT:BOOL=0
          -DASSERT2:BOOL=0
          -DDEBUG:BOOL=0
          -DGPROF:BOOL=0
          -DOPENMP:BOOL=${METIS_ENABLE_OPENMP}
          -DSHARED:BOOL=${METIS_BUILD_SHARED}
        DEPENDS ${proj_DEPENDENCIES}
       )
      
      set(METIS_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-install)
      
    endif()
  
  else()
  
    message("Using Metis from ${METIS_DIR}.")

    duneMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
    
  endif()
  
endif()
