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
    if(DUNE_ENABLE_MODULE_${_module} OR DUNE_ENABLE_ALL_MODULES)
      set(_src_dir ${_module}-${_bootstrap_VERSION}-src)
      set(location_args SOURCE_DIR ${_src_dir})
      if(_bootstrap_SVN_TRUNK)
        list(APPEND location_args
             SVN_REPOSITORY ${dune_svn_repo}/${_module}/trunk
             SVN_USERNAME ${_bootstrap_SVN_USERNAME}
             SVN_PASSWORD ${_bootstrap_SVN_PASSWORD}
            )
      elseif(_bootstrap_SVN_BRANCH)
        list(APPEND location_args
             SVN_REPOSITORY ${dune_svn_repo}/${_module}/branches/release-${_version_major}.${_version_minor}
             SVN_USERNAME ${_bootstrap_SVN_USERNAME}
             SVN_PASSWORD ${_bootstrap_SVN_PASSWORD}
            )
      else()
        list(APPEND location_args
             URL ${dune_tarball_base_url}/${_module}-${_bootstrap_VERSION}.tar.gz
            )
        if(${_module}-${_bootstrap_VERSION}-md5)
          list(APPEND location_args URL_MD5 ${${_module}-${_bootstrap_VERSION}-md5})
        endif()
      endif()
      
      duneMacroAddModule(NAME ${_module} LOCATION_ARGS ${location_args})
    endif()
  endforeach()

endmacro()
