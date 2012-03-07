#-----------------------------------------------------------------------------
# ALUGrid
#-----------------------------------------------------------------------------

option(DUNE_USE_ALUGRID "Use the ALUGrid library in DUNE modules" OFF)

if(DUNE_USE_ALUGRID)

  # Sanity checks
  if(DEFINED ALUGRID_DIR AND NOT EXISTS ${ALUGRID_DIR})
    message(FATAL_ERROR "ALUGRID_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj ALUGrid)
  set(proj_DEPENDENCIES )
  set(ALUGRID_DEPENDS ${proj})

  if(NOT DEFINED ALUGRID_DIR)
  
    set(DUNE_USE_ALUGRID_VERSION "" CACHE STRING "The ALUGrid version to use")
    mark_as_advanced(DUNE_USE_ALUGRID_VERSION)
    
    set(location_args )
    if(${proj}_URL)
      # We have a custom URL to fetch Metis from
      if(NOT DUNE_USE_ALUGRID_VERSION)
        message(SEND_FATAL "${proj}_URL is set but DUNE_USE_ALUGRID_VERSION is not!")
      endif()
    elseif(DUNE_USE_ALUGRID_VERSION)
      # Get a specific ALUGrid version
      set(${proj}_URL http://aam.mathematik.uni-freiburg.de/IAM/Research/alugrid/ALUGrid-${DUNE_USE_ALUGRID_VERSION}.tar.gz
         )
    else()
      # Get the default version
      set(DUNE_USE_ALUGRID_VERSION 1.50)
      set(${proj}_URL http://aam.mathematik.uni-freiburg.de/IAM/Research/alugrid/ALUGrid-${DUNE_USE_ALUGRID_VERSION}.tar.gz)
      list(APPEND location_args URL_MD5 b424c29cf632181c580b235909a34790)
    endif()
    
    list(APPEND location_args URL ${${proj}_URL})
    
    message("Using ${proj} ${DUNE_USE_ALUGRID_VERSION} from ${${proj}_URL}.")
    
    set(configure_args --prefix=<INSTALL_DIR> CXX=${CMAKE_CXX_COMPILER})
    set(alugrid_cxxflags "-DNDEBUG")
    set(alugrid_ldflags )
    
    if(DUNE_USE_MPI)
      # The MPI flags are provided by FindMPI.cmake
      set(alugrid_cxxflags "${alugrid_cxxflags} ${MPI_CXX_COMPILE_FLAGS}")
      set(alugrid_ldflags "${alugrid_ldflags} ${MPI_CXX_LINK_FLAGS}")
    endif()
    
    if(DUNE_USE_METIS)
      list(APPEND proj_DEPENDENCIES ${METIS_DEPENDS})
      list(APPEND configure_args --with-metis=${METIS_DIR})
    endif()
    
    if(DUNE_USE_PARMETIS)
      list(APPEND proj_DEPENDENCIES ${PARMETIS_DEPENDS})
      list(APPEND configure_args --with-parmetis=${PARMETIS_DIR})
    endif()
    
    ExternalProject_Add(${proj}
      SOURCE_DIR ${proj}-src
      BINARY_DIR ${proj}-src
      PREFIX ${proj}-cmake
      INSTALL_DIR ${proj}-install
      ${location_args}
      CONFIGURE_COMMAND ./configure ${configure_args} CXXFLAGS=${alugrid_cxxflags} LDFLAGS=${alugrid_ldflags}
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND $(MAKE) install
      DEPENDS ${proj_DEPENDENCIES}
    )
    
    SET(ALUGRID_DIR "${CMAKE_CURRENT_BINARY_DIR}/${proj}-install")
  
  else()
  
    message("Using ${proj} from ${ALUGRID_DIR}.")

    duneMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
    
  endif()
  
endif()
