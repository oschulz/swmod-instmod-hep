Collection of swmod-Based Install Scripts for Particle Physics Software
=======================================================================

This project provides scripts for fully automatic installation of the following
software as [swmod](https://github.com/oschulz/swmod) modules:

* [ROOT] (http://root.cern.ch/)
* [CLHEP] (http://cern.ch/clhep/)
* [Geant4] (http://geant4.cern.ch/)

swmod is a simple tool to manage `PATH`, `LD_LIBRARY_PATH` for custom-installed
software.


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

    # swmod-instmod-MODULE VERSION [configure/CMake options]

Alternatively, if you have already have a copy of the source code, specifying
the path to it (the software version will be determined automatically):

    # swmod-instmod-MODULE PATH/TO/SOURCE/CODE [configure/CMake options]

The installers provide individual default sets of configure or CMake
options. Add additional options to extend (or override) them if necessary.

Afterwards, you can load your freshly installed software module using

    # swmod load MODULE@VERSION

The software modules are installed with the prefix path
`$SWMOD_INST_BASE/MODULE/HOSTSPEC/VERSION`. If `$SWMOD_INST_BASE` is not set,
it defaults to `$HOME/.local/sw`.


Examples
--------

Download, install and load ROOT v6.02.05:

    # swmod-instmod-root 6.02.05
    # swmod load root@6.02.05

Install and load CLHEP v2.1.4.1:

    # swmod-instmod-clhep 2.1.4.1
    # swmod load clhep@2.1.4.1

Install and load Geant4 v10.0.0:

    # swmod-instmod-geant4 10.0.0 -DGEANT4_INSTALL_DATA=ON
    # swmod load geant4@2.1.4.1


Software-Specific Behavior
---------------------------

### Geant4

If CLHEP is installed and loaded while installing Geant4, Geant4 will use this
CLHEP. Otherwise, Geant4 will be installed using the CLHEP included in the
Geant4 source code package.
