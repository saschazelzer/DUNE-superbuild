
# This macro expects as argument a list of directories which
# may contain DUNE modules and a list variable to which to
# add any found module names.
#
macro(duneMacroGetModuleInfos)

  macro_parse_arguments(_infos "MODULE_DIRS;MODULE_LIST_VARIABLE;AUTOGEN_LIST_VARIABLE" "" ${ARGN})

  # Get information about DUNE module dependencies.
  # This will look at the dune.module file and at the
  # configure --help output.
  foreach(_module_dir ${ARGN})
    file(GLOB _entries "${_module_dir}/*")
    foreach(_entry ${_entries})
      if(IS_DIRECTORY "${_entry}")
        duneFunctionGetModuleInfo(SOURCE_DIR "${_entry}" MODULES ${${_infos_MODULE_LIST_VARIABLE}})
        if(DUNE_MODULE_FOUND)
          if(_infos_MODULE_LIST_VARIABLE)
            list(APPEND ${_infos_MODULE_LIST_VARIABLE} ${DUNE_MODULE_NAME})
          endif()
          if(NOT EXISTS "${_entry}/configure" AND _infos_AUTOGEN_LIST_VARIABLE)
            list(APPEND ${_infos_AUTOGEN_LIST_VARIABLE} ${DUNE_MODULE_NAME})
          endif()
        endif()
      endif()
    endforeach()
  endforeach()

endmacro()
