#-----------------------------------------------------------------------------
# SuperLU
#-----------------------------------------------------------------------------

option(DUNE_USE_SUPERLU "Use the SuperLU library in DUNE modules" OFF)

if(DUNE_USE_SUPERLU)

  # Sanity checks
  if(DEFINED SUPERLU_DIR AND NOT EXISTS ${SUPERLU_DIR})
    message(FATAL_ERROR "SUPERLU_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj SuperLU)
  set(proj_DEPENDENCIES )
  set(SUPERLU_DEPENDS ${proj})

  if(NOT DEFINED SUPERLU_DIR)
  
    set(DUNE_USE_SUPERLU_VERSION "" CACHE STRING "The SuperLU version to use")
    mark_as_advanced(DUNE_USE_SUPERLU_VERSION)
    
    set(location_args )
    if(${proj}_URL)
      # We have a custom URL to fetch SuperLU from
      if(NOT DUNE_USE_SUPERLU_VERSION)
        message(SEND_FATAL "${proj}_URL is set but DUNE_USE_SUPERLU_VERSION is not!")
      endif()
    elseif(DUNE_USE_SUPERLU_VERSION)
      # Get a specific SuperLU version
      set(${proj}_URL http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_${DUNE_USE_SUPERLU_VERSION}.tar.gz)
    else()
      # Get the default version
      set(DUNE_USE_SUPERLU_VERSION 4.3)
      set(${proj}_URL http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_${DUNE_USE_SUPERLU_VERSION}.tar.gz)
      list(APPEND location_args URL_MD5 b72c6309f25e9660133007b82621ba7c)
    endif()
    
    list(APPEND location_args URL ${${proj}_URL})
    
    message("Using ${proj} ${DUNE_USE_SUPERLU_VERSION} from ${${proj}_URL}.")
    
    SET(SuperLU_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/${proj}-src")
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/third-party/superlu_make.inc"
                   "${CMAKE_CURRENT_BINARY_DIR}/superlu_make.inc" @ONLY)
      
    ExternalProject_Add(${proj}
      SOURCE_DIR ${proj}-src
      BINARY_DIR ${proj}-src
      PREFIX ${proj}-cmake
      ${location_args}
      CONFIGURE_COMMAND ""
      PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/superlu_make.inc" "<SOURCE_DIR>/make.inc"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND $(MAKE) lib
      INSTALL_COMMAND $(MAKE) install
      DEPENDS ${proj_DEPENDENCIES}
     )
    
    set(SUPERLU_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-src)
    SET(SuperLU_LIB "libsuperlu.a")
  
  else()
  
    message("Using ${proj} from ${SUPERLU_DIR}.")

    duneMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")
    
  endif()
  
endif()
