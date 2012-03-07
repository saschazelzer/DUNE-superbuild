# List all DUNE core modules
set(dune_core_modules
  dune-common
  dune-grid
  dune-istl
  dune-localfunctions
  dune-grid-howto
  dune-grid-dev-howto
)

list(APPEND DUNE_BOOTSTRAP_MODULES ${dune_core_modules})

# MD5 sums for version 2.1.1 core modules
set(dune-common-2.1.1-md5 bbc2c8be2406f28b6510ad5aa1f73fb8)
set(dune-grid-2.1.1-md5 767e44be62145bdb52d2e1016f0427eb)
set(dune-istl-2.1.1-md5 1a9fc4b751b726310e04175095de988f)
set(dune-localfunctions-2.1.1-md5 736548dd99239ec8883df7169a166acc)
set(dune-grid-howto-2.1.1-md5 ec7f5ddd3c677c5eb2fa58a403ffb745)
set(dune-grid-dev-howto-2.1.1-md5 af39cd673037d4a780dccd0aa620b42e)

# We cannot parse the dune.module file in the module's source
# directory, because we do not have the sources yet.
# Hard-code the module dependencies here instead.

set(dune-common_DEPENDS )
set(dune-grid_DEPENDS dune-common)
set(dune-istl_DEPENDS dune-common)
set(dune-localfunctions_DEPENDS dune-common dune-grid)
set(dune-grid-howto_DEPENDS dune-common dune-grid dune-istl)
set(dune-grid-dev-howto_DEPENDS dune-common dune-grid)

# Suggested packages should be named according to the "package" name
# in --with-<package> 
set(dune-common_SUGGESTS )
set(dune-grid_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid)
set(dune-istl_SUGGESTS blas lapack metis parmetis superlu superlu-dist pardiso boost)
set(dune-localfunctions_sugests blas lapack grape alberta ug amiramesh psurface alugrid)
set(dune-grid-howto_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid metis parmetis superlu superlu-dist pardiso boost)
set(dune-grid-dev-howto_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid)

# The default download location for tarballs
set(dune_tarball_base_url "http://www.dune-project.org/download")

# The default SVN repository containing dune modules
set(dune_svn_repo "https://svn.dune-project.org/svn")
