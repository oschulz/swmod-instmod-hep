# Copyright (C) 2015 Oliver Schulz <oliver.schulz@tu-dortmund.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


BASIC_BUILD_OPTS="\
--fail-on-missing \
--enable-shared \
--enable-soversion \
"

ADDITIONAL_BUILD_OPTS="\
  -DGEANT4_USE_GDML=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_RAYTRACER_X11=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_INSTALL_EXAMPLES=ON \
"

CLHEP_PREFIX=`(clhep-config --prefix | sed 's/\"//g') 2> /dev/null`
if [ -n "${CLHEP_PREFIX}" ] ; then
	echo "CLHEP available, will use it for Geant4 installation."

	BASIC_BUILD_OPTS="${BASIC_BUILD_OPTS} -DGEANT4_USE_SYSTEM_CLHEP=ON -DCLHEP_ROOT_DIR=${CLHEP_PREFIX}"
else
	BASIC_BUILD_OPTS="${BASIC_BUILD_OPTS} -DGEANT4_USE_SYSTEM_CLHEP=OFF"
fi

XERCES_C_PREFIX=$( (dirname $(dirname `which XInclude`)) 2> /dev/null )
if [ -n "${XERCES_C_PREFIX}" ] ; then
	XERCES_C_MODNAME=`. swmod.sh list "${XERCES_C_PREFIX}" 2> /dev/null`
	if [ -n "${XERCES_C_MODNAME}" ] ; then
		echo "Xerces-C loaded via swmod, will add ${XERCES_C_MODNAME} to target package dependencies."

		BASIC_BUILD_OPTS="${BASIC_BUILD_OPTS} -DXERCESC_ROOT_DIR=${XERCES_C_PREFIX}"
	fi
fi

DEFAULT_BUILD_OPTS=`echo ${BASIC_BUILD_OPTS} ${ADDITIONAL_BUILD_OPTS}`


swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
	local PKG_VERSION="${1}" \
	&& local PKG_VERSION_MAJOR=$(echo "${PKG_VERSION}" | cut -d '.' -f 1) \
	&& local PKG_VERSION_MINOR=$(echo "${PKG_VERSION}" | cut -d '.' -f 2) \
	&& local PKG_VERSION_MINOR=$(test "${PKG_VERSION_MAJOR}" -ge 10 && seq -f "%02g" "${PKG_VERSION_MINOR}" "${PKG_VERSION_MINOR}" || echo "${PKG_VERSION_MINOR}") \
	&& local PKG_VERSION_PATCH=$(echo "${PKG_VERSION}" | cut -d '.' -f 3) \
	&& local PKG_VERSION_PATCH=$(seq -f "%02g" "${PKG_VERSION_PATCH}" "${PKG_VERSION_PATCH}") \
	&& local PKG_VERSION_DNL="${PKG_VERSION_MAJOR}.${PKG_VERSION_MINOR}" \
	&& local PKG_VERSION_DNL=$(test "${PKG_VERSION_PATCH}" -ne 0 && echo "${PKG_VERSION_DNL}.p${PKG_VERSION_PATCH}" || echo "${PKG_VERSION_DNL}") \
	&& echo "http://geant4.cern.ch/support/source/geant4.${PKG_VERSION_DNL}.tar.gz"
}

swi_get_version_no() {
	cat CMakeLists.txt | grep 'set.*PROJECT_NAME.*_VERSION[^_]' | grep -o '[0-9.]\+'
}

swi_modify_pkg_version() {
	echo "${1}" | sed 's/^\([0-9]\+\.[0-9]\+\)$/\1.00/'
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+\([.][0-9]\+\)\?$'
}

swi_build_and_install() {
	. swmod.sh install "$@" \
	&& echo '. "$SWMOD_PREFIX/bin/geant4.sh" > /dev/null' > "${SWMOD_INST_PREFIX}/swmodrc.sh" \
	&& (test -n "${CLHEP_PREFIX}" && swi_add_prefix_dep "${CLHEP_PREFIX}" || true) \
	&& (test -n "${XERCES_C_MODNAME}" && . swmod.sh add-deps "${XERCES_C_MODNAME}" || true) \
	&& (
		# Fix architecture.gmk if geant4 is built with internal Expat:
		if (ls "${SWMOD_INST_PREFIX}"/lib*/libG4expat* 1>/dev/null 2>&1) ; then
			local arch_makefile=`ls "${SWMOD_INST_PREFIX}"/share/*/geant4make/config/architecture.gmk 2>/dev/null | head -n1` \
			&& if [ -n "${arch_makefile}" ] ; then
				echo "Fixing \"${arch_makefile}\" to use \"-lG4expat\" instead of \"-lexpat\"." \
				&& cat "${arch_makefile}" | sed 's/-lexpat/-lG4expat/' > "${arch_makefile}.fixed" \
				&& mv "${arch_makefile}.fixed" "${arch_makefile}"
			fi
		fi
	)
}
