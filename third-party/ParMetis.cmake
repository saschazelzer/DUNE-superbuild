#-----------------------------------------------------------------------------
# ParMetis
#-----------------------------------------------------------------------------

option(DUNE_USE_PARMETIS "Use the Parallel Metis library in DUNE modules" OFF)

if(DUNE_USE_PARMETIS)

  # Sanity checks
  if(DEFINED PARMETIS_DIR AND NOT EXISTS ${PARMETIS_DIR})
    message(FATAL_ERROR "PARMETIS_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj ParMetis)
  set(proj_DEPENDENCIES )
  set(PARMETIS_DEPENDS ${proj})

  if(NOT DEFINED PARMETIS_DIR)
  
    set(DUNE_USE_PARMETIS_VERSION "" CACHE STRING "The Parallel Metis version to use")
    mark_as_advanced(DUNE_USE_PARMETIS_VERSION)
    
    set(location_args )
    if(${proj}_URL)
      # We have a custom URL to fetch ParMetis from
      if(NOT DUNE_USE_PARMETIS_VERSION)
        message(SEND_FATAL "${proj}_URL is set but DUNE_USE_PARMETIS_VERSION is not!")
      endif()
    elseif(DUNE_USE_PARMETIS_VERSION)
      # Get a specific ParMetis version from the "OLD" directory
      set(${proj}_URL http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/OLD/parmetis-${DUNE_USE_PARMETIS_VERSION}.tar.gz)
    else()
      # Get the default version
      set(DUNE_USE_PARMETIS_VERSION 4.0.2)
      set(${proj}_URL http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-${DUNE_USE_PARMETIS_VERSION}.tar.gz)
      list(APPEND location_args URL_MD5 0912a953da5bb9b5e5e10542298ffdce)
    endif()
    
    list(APPEND location_args URL ${${proj}_URL})
    
    message("Building ${proj} ${DUNE_USE_PARMETIS_VERSION} from ${${proj}_URL}.")
    
    # We require MPI for building ParMetis
    find_package(MPI)
    if(NOT MPI_FOUND)
      message(FATAL_ERROR "ParMetis needs a MPI implementation, but none was found.")
    endif()
    
    if(DUNE_USE_PARMETIS_VERSION VERSION_LESS 4)
    
      # Use traditional make/configure steps
      
      ExternalProject_Add(${proj}
        SOURCE_DIR ${proj}-src
        BINARY_DIR ${proj}-src
        PREFIX ${proj}-cmake
        ${location_args}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND $(MAKE)
        INSTALL_COMMAND ""
        DEPENDS ${proj_DEPENDENCIES}
       )
      
      set(PARMETIS_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-src)
      
    else()
    
      # Use the ParMetis CMake scripts
      
      option(PARMETIS_ENABLE_OPENMP "Enable OpenMP support in ParMetis" OFF)
      option(PARMETIS_BUILD_SHARED "Build ParMetis as a shared library" OFF)
      set(PARMETIS_METIS_PATH "${CMAKE_CURRENT_BINARY_DIR}/${proj}-src/metis" CACHE STRING
          "The Metis path to be used in ParMetis")
      mark_as_advanced(PARMETIS_METIS_PATH)
      
      set(PARMETIS_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Choose the type of build for ${proj}")
      mark_as_advanced(PARMETIS_BUILD_TYPE)
     
      ExternalProject_Add(${proj}
        SOURCE_DIR ${proj}-src
        BINARY_DIR ${proj}-build
        INSTALL_DIR ${proj}-install
        PREFIX ${proj}-cmake
        ${location_args}
        CMAKE_GENERATOR ${gen}
        CMAKE_CACHE ARGS
          -DCMAKE_BUILD_TYPE:STRING=${PARMETIS_BUILD_TYPE}
          -DCMAKE_C_COMPILER:FILEPATH=${MPI_C_COMPILER}
          -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
          -DCMAKE_CXX_COMPILER:FILEPATH=${MPI_CXX_COMPILER}
          -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
          -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
          -DMETIS_INSTALL:BOOL=1
          -DGKLIB_PATH:PATH=<SOURCE_DIR>/metis/GKlib
          -DGDB:BOOL=0
          -DASSERT:BOOL=0
          -DASSERT2:BOOL=0
          -DDEBUG:BOOL=0
          -DGPROF:BOOL=0
          -DOPENMP:BOOL=${PARMETIS_ENABLE_OPENMP}
          -DSHARED:BOOL=${PARMETIS_BUILD_SHARED}
          -DMETIS_PATH:PATH=${PARMETIS_METIS_PATH}
        DEPENDS ${proj_DEPENDENCIES}
       )
      
      set(PARMETIS_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-install)
      
      # Work around a possible bug in parmetis CMake scripts which leads to missing
      # metis.h in the install folder
      ExternalProject_Add_Step(${proj} install-patch
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PARMETIS_METIS_PATH}/include/metis.h ${CMAKE_CURRENT_BINARY_DIR}/${proj}-install/include
        DEPENDEES install
       )
    endif()
  
  else()
  
    message("Using ParMetis from ${PARMETIS_DIR}.")

    duneMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
    
  endif()
  
endif()
