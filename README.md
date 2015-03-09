Collection of swmod-Based Install Scripts for Particle Physics Software
=======================================================================

This project provides fully automatic installation of the following
software as [swmod](https://github.com/oschulz/swmod) modules:

* [ROOT] (http://root.cern.ch/) (version 5.x and 6.x)
* [CLHEP] (http://cern.ch/clhep/) (version 2.1.2.0 and higher)
* [Geant4] (http://geant4.cern.ch/) (version 9.5 and higher)

Also, installers for frequently problematic dependencies of these software
packages are provided. Use them in case you cannot satisfy the required
dependencies using official packages provided for your operating system
(because they are not available, too old, or you lack the required
administrative privileges to install them). 

* [GNU Binutils] (http://www.gnu.org/software/binutils/)
* [GCC] (http://gcc.gnu.org/)
* [Python] (http://www.python.org/)
* [FFTW] (http://www.fftw.org/)
* [Xerces-C] (http://xerces.apache.org/xerces-c/)


Prerequisites
-------------

You need to have [swmod](https://github.com/oschulz/swmod) installed. Check
that you can run

	# swmod

or at least

    # . swmod.sh


Usage
-----

Simply run one of the `swmod-instmod-...` scripts, specifying the software
version to be installed (the source code will be downloaded automatically):

    # swmod-instmod PACKAGE VERSION [configure/CMake options]

Alternatively, if you have already have a copy of the source code, specifying
the path to it (the software version will be determined automatically):

    # swmod-instmod PACKAGE PATH/TO/SOURCE/CODE [configure/CMake options]

The installers provide individual default sets of configure or CMake
options. Add additional options to extend (or override) them if necessary.

Afterwards, you can load your freshly installed software module using

    # swmod load PACKAGE@VERSION

The software modules are installed with the prefix path
`$SWMOD_INST_BASE/PACKAGE/HOSTSPEC/VERSION`. If `$SWMOD_INST_BASE` is not set,
it defaults to `$HOME/.local/sw`.


Dependencies
------------

If build dependencies known to the installer are satisfied via packages loaded
via swmod, they will automatically be added to the dependencies of the new
software module after installation.

* ROOT dependencies:

    * GCC: ROOT version 6 requires a C++11 compatible compiler, e.g. GCC v4.8
      or newer. OS-X users should have a version of Clang that supports C++11.

    * Python: ROOT also requires Python. Python v2.7.x should usually be fine.

    * FFTW3: By default, the root installer enables FFT support, so FFTW3
      must be available.

* Geant-4 dependencies:

    * CLHEP: If CLHEP is available, the Geant4 installer will use it,
      otherwise it will configure Geant4 to use it's internal CLHEP.

    * Xerces-C: By default, the Geant4 installer enables GDML support, which
      requires Xerces-C.

    * Expat: If Expat is not available on your system, pass the option
      "-DGEANT4_USE_SYSTEM_EXPAT=OFF" to the installer, to make Geant4 use
      it's internal version of Expat.

* GCC dependencies:

    * GNU Binutils: A recent GCC version may require a newer version of the
      GNU Binutils than the one provided by your system.


Examples
--------

Download, install and load ROOT v6.02.05:

    # swmod-instmod-root 6.02.05
    # swmod load root@6.02.05

Install and load CLHEP v2.1.4.1:

    # swmod-instmod-clhep 2.1.4.1
    # swmod load clhep@2.1.4.1

Install and load Geant4 v10.0.0:

    # swmod-instmod-geant4 10.0.0
    # swmod load geant4@2.1.4.1
