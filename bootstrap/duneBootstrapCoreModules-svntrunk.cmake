# List all DUNE core modules
set(dune_core_modules
  dune-common
  dune-geometry
  dune-grid
  dune-istl
  dune-localfunctions
  dune-grid-howto
  dune-grid-dev-howto
)

list(APPEND DUNE_BOOTSTRAP_MODULES ${dune_core_modules})

# We cannot parse the dune.module file in the module's source
# directory, because we do not have the sources yet.
# Hard-code the module dependencies here instead.

set(dune-common_DEPENDS )
set(dune-geometry_DEPENDS dune-common)
set(dune-grid_DEPENDS dune-common dune-geometry)
set(dune-istl_DEPENDS dune-common)
set(dune-localfunctions_DEPENDS dune-geometry)
set(dune-grid-howto_DEPENDS dune-common dune-geometry dune-grid dune-istl)
set(dune-grid-dev-howto_DEPENDS dune-common dune-grid)

# The default download location for tarballs
set(dune_tarball_base_url "http://www.dune-project.org/download")

# The default SVN repository containing dune modules
set(dune_svn_repo "https://svn.dune-project.org/svn")

set(BOOTSTRAP_VERSION "2.2-svn")

# Suggested packages should be named according to the "package" name
# in --with-<package> 
set(dune-common_SUGGESTS )
set(dune-geometry_SUGGESTS )
set(dune-grid_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid)
set(dune-istl_SUGGESTS blas lapack metis parmetis superlu superlu-dist pardiso boost)
set(dune-localfunctions_sugests blas lapack grape alberta ug amiramesh psurface alugrid)
set(dune-grid-howto_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid metis parmetis superlu superlu-dist pardiso boost)
set(dune-grid-dev-howto_SUGGESTS blas lapack grape alberta ug amiramesh psurface alugrid)
