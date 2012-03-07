DUNE Superbuild
---------------

This is a CMake based meta build system for [DUNE].

**Main features**

  - Bootstrap the DUNE core modules from tarballs or SVN repositories
  - Automatically download, configure, and build third-party libraries like ParMetis, SuperLU, ALUGrid, etc.
  - Configure all third-party libraries and DUNE modules automatically

Supported platforms

  - Tested on Ubuntu 11.10, but should generally work on all Unix-like systems
  
If you find bugs, get into trouble or want to contribute a feature, please don't hesitate to use the Github features for communication.

### Quick Start

Get this project's sources via git clone or a source zipball:

    git clone git://github.com/saschazelzer/DUNE-superbuild.git

or:

    wget https://github.com/saschazelzer/DUNE-superbuild/zipball/master
    unzip master
    mv saschazelzer-DUNE-superbuild-<hash> DUNE-superbuild

To build the latest stable version of DUNE with ALUGrid (for example) write:

    mkdir DUNE-bin
    cd DUNE-bin
    cmake -DDUNE_BOOTSTRAP:BOOL=1 -DDUNE_USE_ALUGRID:BOOL=1 -DDUNE_ENABLE_ALL_MODULES:BOOL=1 ../DUNE-superbuild
    make -j

### Prerequisites

Required:

  - CMake 2.8.4 or newer
  - A C++ compiler (see the [DUNE installation notes] [2])
  
Depending on the enabled CMAke options, you might need to have additional packages installed. For example `blas, MPI, csh, Boost, gmp` etc.

### Third-Party Libraries

The following third-party libraries can currently be automatically be build within the DUNE superbuild system:

  - Metis
  - ParMetis
  - SuperLU
  - SuperLU_DIST
  - ALUGrid

To enable any of the above libraries, set the corresponding CMake variable `DUNE_USE_<library>` to true.

### Bootstrapping DUNE core modules

The DUNE core modules can be automatically downloaded. To customize the version and download location, use the following variables:

  - `DUNE_BOOTSTRAP [on|off]` Switch bootstrapping completely ON or OFF
  - `DUNE_BOOTSTRAP_FROM_TARBALLS [version]` Get the DUNE release tarballs with the specified version for all enabled core modules
  - `DUNE_BOOTSTRAP_FROM_SVN_BRANCH [version]` Checkout the SVN release branches with the specified version of all enabled core modules
  - `DUNE_BOOTSTRAP_FROM_SVN_TRUNK [on|off]` Checkout the SVN trunk of all enabled core modules

The priority of these options is from top to bottom.

**Note:** If you bootstrap from SVN, the build system needs to run the autotools on the module's sources to create the usual configure/make files. For this step, it needs a complete checkout of the module. Because the output of `configure --help` is used to look for suggested packages and to configure the modules correctly, bootstrapping from SVN is a two-phase process. After the initial CMake configuration, type:

    make -j
    make rebuild_cache
    make -j

This is only necessary once.

### Adding DUNE modules

The source code for DUNE modules can be located anywhere on the filesystem. To include one or more DUNE modules in the DUNE superbuild, add the directory containing the modules to the `DUNE_MODULE_DIRS` variable.

### Todos

  - Add install support
  - Add support for CMake projects who want to link against DUNE modules

### Known Problems

  - Switching from one bootstrap type to another will confuse the system. You will have to clean your build directory if you want to switch for example from tarballs to using a SVN release branch.
  - When bootstrapping the DUNE core modules from SVN trunk, the dune-geometry module does not yet configure correctly.
  
[DUNE]: http://www.dune-project.org
[2]: http://www.dune-project.org/doc/installation-notes.html
