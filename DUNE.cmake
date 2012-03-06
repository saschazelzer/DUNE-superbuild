#-----------------------------------------------------------------------------
# DUNE
#-----------------------------------------------------------------------------

IF(MITK_USE_DUNE)

  # Sanity checks
  IF(DEFINED DUNE_DIR AND NOT EXISTS ${DUNE_DIR})
    MESSAGE(FATAL_ERROR "DUNE_DIR variable is defined but corresponds to non-existing directory")
  ENDIF()

  SET(proj DUNE)
  SET(proj_DEPENDENCIES )
  IF(NOT MITK_USE_SYSTEM_Boost)
    # We rely on the Boost binaries build within the MITK superbuild
    SET(proj_DEPENDENCIES ${MITK_DEPENDS})
  ENDIF()
  
  SET(DUNE_DEPENDS ${proj})

  IF(NOT DEFINED DUNE_DIR)
  
    #------------ Metis 4.0.3 ------------------------
    
    ExternalProject_Add(Metis
      URL "http://mbits/~zelzer/metis-4.0.3.tar.gz"
      SOURCE_DIR Metis-src
      BINARY_DIR Metis-src
      CONFIGURE_COMMAND ""
      PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/Metis_Makefile.in" "<SOURCE_DIR>/Makefile.in"
      BUILD_COMMAND make
      INSTALL_COMMAND ""
    )
    
    SET(Metis_DIR "${CMAKE_CURRENT_BINARY_DIR}/Metis-src")
    
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/CMakeExternals/Metis_Makefile.in" "${CMAKE_CURRENT_BINARY_DIR}/Metis_Makefile.in")
    
    LIST(APPEND proj_DEPENDENCIES Metis)
  
    #------------ ParMetis 3.2.0 ---------------------
    
    ExternalProject_Add(ParMetis
      URL "http://mbits/~zelzer/ParMetis-3.2.0.tar.gz"
      SOURCE_DIR ParMetis-src
      BINARY_DIR ParMetis-src
      CONFIGURE_COMMAND ""
      BUILD_COMMAND make
      INSTALL_COMMAND ""
    )
    
    SET(ParMetis_DIR "${CMAKE_CURRENT_BINARY_DIR}/ParMetis-src")
    
    #------------ SuperLU 4.3 -------------------------
    
    ExternalProject_Add(SuperLU
      URL "http://mbits/~zelzer/superlu_4.3.tar.gz"
      SOURCE_DIR SuperLU-src
      BINARY_DIR SuperLU-src
      PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/superlu_make.inc" "<SOURCE_DIR>/make.inc"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND make lib
      INSTALL_COMMAND make install
    )
    
    SET(SuperLU_DIR "${CMAKE_CURRENT_BINARY_DIR}/SuperLU-src")
    SET(SuperLU_LIB "libsuperlu.a")
    SET(SuperLU_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/SuperLU-src")
    
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/CMakeExternals/superlu_make.inc" "${CMAKE_CURRENT_BINARY_DIR}/superlu_make.inc")
    
    LIST(APPEND proj_DEPENDENCIES SuperLU)
    
    #------------ SuperLU_DIST 3.0 --------------------
    
    ExternalProject_Add(DSuperLU
      URL "http://mbits/~zelzer/superlu_dist_3.0.tar.gz"
      SOURCE_DIR DSuperLU-src
      BINARY_DIR DSuperLU-src
      PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/superlu_dist_make.inc" "<SOURCE_DIR>/make.inc"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND make lib
      INSTALL_COMMAND make install
      DEPENDS ParMetis
    )
    
    SET(DSuperLU_DIR "${CMAKE_CURRENT_BINARY_DIR}/DSuperLU-src")
#    SET(DSuperLU_LIB "lib/libsuperlu-mpi.a")
    SET(DSuperLU_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/DSuperLU-src")
    
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/CMakeExternals/superlu_dist_make.inc" "${CMAKE_CURRENT_BINARY_DIR}/superlu_dist_make.inc")
    
    LIST(APPEND proj_DEPENDENCIES DSuperLU)
    
    #------------ ALUGrid 1.23 -----------------------
    
    ExternalProject_Add(ALUGrid
      URL "http://mbits/~zelzer/ALUGrid-1.23.tar.gz"
      SOURCE_DIR ALUGrid-src
      BINARY_DIR ALUGrid-src
      INSTALL_DIR ALUGrid-bin
      CONFIGURE_COMMAND ./configure CXX=${CMAKE_CXX_COMPILER} CXXFLAGS=-DNDEBUG --with-parmetis=/opt/local-toolkits/ParMetis-3.2.0 --prefix=<INSTALL_DIR>
      BUILD_COMMAND make
      INSTALL_COMMAND make install
      DEPENDS ParMetis
    )
    
    SET(ALUGrid_DIR "${CMAKE_CURRENT_BINARY_DIR}/ALUGrid-bin")
    
    LIST(APPEND proj_DEPENDENCIES ALUGrid)
    
    #------------ DUNE Release 2.1 branch ------------
  
    SET(DUNE_CXX_FLAGS )
    IF(CMAKE_BUILD_TYPE STREQUAL Release)
      SET(DUNE_CXX_FLAGS "-O3 -Wall -DNDEBUG -funroll-loops -finline-functions -fomit-frame-pointer -ffast-math -mfpmath=sse -msse3 -march=native")
    ELSE()
      SET(DUNE_CXX_FLAGS "-g -Wall")
    ENDIF()
  
    CONFIGURE_FILE("${PROJECT_SOURCE_DIR}/CMakeExternals/dune.opts" "${CMAKE_CURRENT_BINARY_DIR}/dune.opts" @ONLY)

    SET(additional_cmake_args )
  
    ExternalProject_Add(${proj}
      URL "http://mbits/~zelzer/DUNE-2.1.tar.gz"
      SOURCE_DIR ${proj}-src
      BINARY_DIR ${proj}-src
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ./dune-common-2.1/bin/dunecontrol --builddir=_build --opts=${CMAKE_CURRENT_BINARY_DIR}/dune.opts all
      INSTALL_COMMAND ""
      DEPENDS ${proj_DEPENDENCIES}
    )

    SET(DUNE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-src)

  ELSE()

    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")

  ENDIF()

ENDIF()
