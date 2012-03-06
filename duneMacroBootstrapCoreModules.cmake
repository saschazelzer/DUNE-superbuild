macro(duneMacroBootstrapCoreModules)

macro_parse_arguments(_bootstrap
                      "MODULES;BASE_URL;SVN_USERNAME;SVN_PASSWORD;VERSION"
                      "SVN_BRANCH;SVN_TRUNK;TARBALLS"
                      ${ARGN}
                     )


  # Overwrite the download URL
  if(_bootstrap_BASE_URL)
    set(dune_tarball_base_url ${_bootstrap_BASE_URL})
  endif()
  set(dune_tarball_base_url "${dune_tarball_base_url}/${_version_major}.${_version_minor}")

  # Inform the user
  if(_bootstrap_TARBALLS)
    message("Using DUNE core module tarballs from ${dune_tarball_base_url}.")
  else()
    set(_msg "Using DUNE core modules from SVN repository ${dune_svn_repo}")
    if(_bootstrap_SVN_BRANCH)
      set(_msg "${_msg} using release branch ${_version_major}.${_version_minor}.")
    else()
      set(_msg "${_msg} using trunk.")
    endif()
    message("${_msg}")
  endif()

  foreach(_module ${_bootstrap_MODULES})
    set(location_args )
    if(_bootstrap_SVN_TRUNK)
      set(location_args
          SVN_REPOSITORY ${dune_svn_repo}/${_dune_core_module}/trunk
          SVN_USERNAME ${_bootstrap_SVN_USERNAME}
          SVN_PASSWORD ${_bootstrap_SVN_PASSWORD}
         )
    elseif(_bootstrap_SVN_BRANCH)
      set(location_args
          SVN_REPOSITORY ${dune_svn_repo}/${_dune_core_module}/branches/release-${_version_major}.${_version_minor}
          SVN_USERNAME ${_bootstrap_SVN_USERNAME}
          SVN_PASSWORD ${_bootstrap_SVN_PASSWORD}
         )
    else()
      set(location_args
          URL ${dune_tarball_base_url}/${_dune_core_module}-${_bootstrap_VERSION}.tar.gz
         )
      if(${_dune_core_module}-${_bootstrap_VERSION}-md5)
        list(APPEND location_args URL_MD5 ${${_dune_core_module}-${_bootstrap_VERSION}-md5})
      endif()
    endif()
    
    dunceMacroAddModule(NAME ${_module} LOCATION_ARGS ${location_args})
    
  endforeach()

endmacro()
