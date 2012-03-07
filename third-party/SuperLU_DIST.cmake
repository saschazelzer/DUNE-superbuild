#-----------------------------------------------------------------------------
# SuperLU_DIST
#-----------------------------------------------------------------------------

option(DUNE_USE_SUPERLU_DIST "Use the SuperLU_DIST library in DUNE modules" OFF)

if(DUNE_USE_SUPERLU_DIST)

  # Sanity checks
  if(DEFINED SUPERLU_DIST_DIR AND NOT EXISTS ${SUPERLU_DIST_DIR})
    message(FATAL_ERROR "SUPERLU_DIST_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj SuperLU_DIST)
  set(proj_DEPENDENCIES )
  set(SUPERLU_DIST_DEPENDS ${proj})

  if(NOT DEFINED SUPERLU_DIST_DIR)
  
    if(NOT DUNE_USE_MPI)
      message(FATAL_ERROR "${proj} needs MPI support. Please switch on DUNE_USE_MPI")
    endif()
    
    if(NOT DUNE_USE_PARMETIS)
      #message(FATAL_ERROR "${proj} needs ParMetis support. Please switch on DUNE_USE_PARMETIS")
    else()
      list(APPEND proj_DEPENDENCIES ${PARMETIS_DEPENDS})
    endif()
  
    set(DUNE_USE_SUPERLU_DIST_VERSION "" CACHE STRING "The SuperLU_DIST version to use")
    mark_as_advanced(DUNE_USE_SUPERLU_DIST_VERSION)
    
    set(location_args )
    if(${proj}_URL)
      # We have a custom URL to fetch SuperLU_DIST from
      if(NOT DUNE_USE_SUPERLU_DIST_VERSION)
        message(SEND_FATAL "${proj}_URL is set but DUNE_USE_SUPERLU_DIST_VERSION is not!")
      endif()
    elseif(DUNE_USE_SUPERLU_DIST_VERSION)
      # Get a specific SuperLU_DIST version
      set(${proj}_URL http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_${DUNE_USE_SUPERLU_DIST_VERSION}.tar.gz)
    else()
      # Get the default version
      set(DUNE_USE_SUPERLU_DIST_VERSION 3.0)
      set(${proj}_URL http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_dist_${DUNE_USE_SUPERLU_DIST_VERSION}.tar.gz)
      list(APPEND location_args URL_MD5 1d77f10a265f5751d4e4b59317d778f8)
    endif()
    
    list(APPEND location_args URL ${${proj}_URL})
    
    message("Using ${proj} ${DUNE_USE_SUPERLU_DIST_VERSION} from ${${proj}_URL}.")
    
    SET(SUPERLU_DIST_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/${proj}-src")
    SET(METIS_LIBRARY_DIR "${PARMETIS_DIR}/lib")
    SET(PARMETIS_LIBRARY_DIR "${PARMETIS_DIR}/lib")
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/third-party/superlu_dist_make.inc"
                   "${CMAKE_CURRENT_BINARY_DIR}/superlu_dist_make.inc" @ONLY)
      
    ExternalProject_Add(${proj}
      SOURCE_DIR ${proj}-src
      BINARY_DIR ${proj}-src
      PREFIX ${proj}-cmake
      ${location_args}
      CONFIGURE_COMMAND ""
      PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/superlu_dist_make.inc" "<SOURCE_DIR>/make.inc"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND $(MAKE) lib
      INSTALL_COMMAND $(MAKE) install
      DEPENDS ${proj_DEPENDENCIES}
     )
    
    set(SUPERLU_DIST_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-src)
    SET(SuperLU_DIST_LIB "libsuperlu_dist.a")
  
  else()
  
    message("Using ${proj} from ${SUPERLU_DIST_DIR}.")

    duneMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
    
  endif()
  
endif()
