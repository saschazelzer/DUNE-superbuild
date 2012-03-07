
# This function extracts dependency information from
# a given directory if it contains a DUNE module.
#
# The function sets the following variables:
#
# DUNE_MODULE_FOUND 
#     Set to true if the directory contains a dune.module file.
#
# DUNE_MODULE_NAME 
#     The name of the DUNE module.
#
# ${DUNE_MODULE_NAME}_SOURCE_DIR
#     The directory containing the DUNE module.
#
# ${DUNE_MODULE_NAME}_VERSION
#     The version of the module.
#
# ${DUNE_MODULE_NAME}_DEPENDS
#     A list of DUNE modules this module depends on.
#
# ${DUNE_MODULE_NAME}_SUGGESTS
#     A list of package names which the configure command understands.
#
function(duneFunctionGetModuleInfo)

  macro_parse_arguments(_module "SOURCE_DIR;MODULES" "" ${ARGN})

  set(DUNE_MODULE_FOUND 0 PARENT_SCOPE)
  
  # Check if the directory contains a dune.module file
  if(NOT EXISTS ${_module_SOURCE_DIR} OR
     NOT EXISTS ${_module_SOURCE_DIR}/dune.module)
    return()
  endif()
  
  # Read the dune.module file
  file(STRINGS ${_module_SOURCE_DIR}/dune.module _dune_module_file)
  
  # Parse the "Module" and "Depends" headers
  set(_keywords Module Version Depends)
  foreach(_line ${_dune_module_file})
    foreach(_keyword ${_keywords})
      set(_regex "[^#]*${_keyword}:(.*)")
      string(REGEX MATCH ${_regex} _matched ${_line})
      if(_matched)
        string(REGEX REPLACE ${_regex} "\\1" _${_keyword}_value "${_matched}")
        string(STRIP ${_${_keyword}_value} _${_keyword}_value)
      endif()
    endforeach()
  endforeach()
  
  # Check if the module name is already in use
  list(FIND _module_MODULES ${_Module_value} _found)
  if(NOT _found EQUAL -1)
    set(_msg "The module name \"${_Module_value}\" used in ${_module_SOURCE_DIR}/dune.module is already used")
    if(${_Module_value}_SOURCE_DIR)
      set(_msg "${_msg} by module ${${_Module_value}_SOURCE_DIR}.")
    else()
      set(_msg "${_msg} (probably by a DUNE core module being bootstrapped).")
    endif()
    message(FATAL_ERROR "${_msg}")
  endif()
  
  if(NOT _Version_value)
    set(_Version_value "unknown")
  else()
    if(${_Module_value}_BOOTSTRAPPED)
      # Fix the version since this value has already been used
      # for bootstrapped modules and would otherwise confuse the system
      set(_Version_value ${BOOTSTRAP_VERSION})
    endif()
  endif()
  
  # Special handling for "Depends" (we only use the module
  # names, not the version information).
  set(_Depends_value " ${_Depends_value} ")
  string(REGEX MATCHALL " [^\(][^ ]+[^\)] " _depends ${_Depends_value})
  set(_Depends_value )
  
  foreach(_dep ${_depends})
    string(STRIP ${_dep} _dep)
    list(APPEND _Depends_value ${_dep})
  endforeach()
  
  # Parse the "configure --help" output to get information
  # about supported optional packages.
  # We just use all --with-<PACKAGE> options, since the help
  # text does not consistently use --with-<PACKAGE>=PATH for
  # example across all DUNE modules.
  
  execute_process(COMMAND ${_module_SOURCE_DIR}/configure --help
                  RESULT_VARIABLE _result
                  OUTPUT_VARIABLE _out
                  ERROR_QUIET
                 )
                 
  set(_module_suggests )
  if(_result EQUAL 0)
    string(REGEX MATCHALL "--with-[^ =\\[]+" _module_with_options ${_out})
    foreach(_with_option ${_module_with_options})
      string(SUBSTRING ${_with_option} 7 -1 _package)
      string(TOLOWER _package ${_package})
      list(APPEND _module_suggests ${_package})
    endforeach()
  endif()
  
  if(_module_suggests)
    list(REMOVE_DUPLICATES _module_suggests)
  endif()
  
  set(DUNE_MODULE_FOUND 1 PARENT_SCOPE)
  set(DUNE_MODULE_NAME ${_Module_value} PARENT_SCOPE)
  set(${_Module_value}_SOURCE_DIR ${_module_SOURCE_DIR} PARENT_SCOPE)
  set(${_Module_value}_VERSION ${_Version_value} PARENT_SCOPE)
  set(${_Module_value}_DEPENDS ${_Depends_value} PARENT_SCOPE)
  set(${_Module_value}_SUGGESTS ${_module_suggests} PARENT_SCOPE)

endfunction()
