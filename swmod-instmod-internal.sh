# Copyright (C) 2009-2015 Oliver Schulz <oliver.schulz@tu-dortmund.de>
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


# ===========================================================================

# Required functions:
#
# swi_get_download_url PACKAGE_VERSION
# swi_get_version_no


# Optional functions:
# swi_is_version_no WHAT
# swi_build_and_install BUILD_OPTS  # defaults to "source swmod.sh install"
# swi_modify_pkg_version PACKAGE_VERSION
# swi_pkg_tarname

# ===========================================================================


swi_cpu_cores() {
	grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4
}


swi_is_generic_version_no() {
	echo "${1}" | grep -q '^[0-9]\+\([.][0-9]\+\)\+$'
}


swi_build_and_install_internal() {
	if [ ""`type -t swi_build_and_install` = "function" ] ; then
		(swi_build_and_install "$@")
	else
		source swmod.sh install "$@"
	fi
}


swmod_instmod_install() {
	local PKG_NAME="${1}"
	local WHAT="${2}"

	shift 2


	local BUILDSYS="Build"


	if [ -z "${PKG_NAME}" ] ; then
		echo "Error, syntax is: swmod_instmod_install PKG_NAME" 1>&2
		return 1
	fi

	if [ -z "${WHAT}" ] ; then
		local BUILDSYS_UPPER=`echo "${BUILDSYS}" | tr '[:lower:]' '[:upper:]'`

		echo "Syntax: $0 WHAT [${BUILDSYS_UPPER}_OPTION] ..." 1>&2
		echo 1>&2
		echo "For \"WHAT\", specify either a version number (e.g. \"6.02.01\") to download, or" 1>&2
		echo "the path to the ${PKG_NAME} source directory (may be an rsync-compatible" 1>&2
		echo "remote path)." 1>&2

		return 1
	fi


	if ! . swmod.sh init ; then
		echo "ERROR: swmod not available, aborting." 1>&2
		return 1
	fi

	if ! (. swmod.sh list 2>/dev/null) ; then
		echo "ERROR: Current version of swmod is too old, please install a recent version." 1>&2
		return 1
	fi


	if [ ""`type -t swi_get_download_url` != "function" ] ; then
		echo "ERROR: Function swi_get_download_url must be defined." 1>&2
		return 1
	fi

	if [ ""`type -t swi_get_version_no` != "function" ] ; then
		echo "ERROR: Function swi_get_download_url must be defined." 1>&2
		return 1
	fi

	if [ ""`type -t swi_pkg_tarname` = "function" ] ; then
		local PKG_TARNAME=`swi_pkg_tarname "${PKG_NAME}"` || (
			echo "ERROR: Determination of package tarname failed." 1>&2
			return 1
		)
	else
		local PKG_TARNAME=`echo "${PKG_NAME}" | tr '[:upper:]' '[:lower:]' | sed 's/[^A-Za-z0-9]/-/'`
		echo "Setting package tarname to ${PKG_TARNAME}"

	fi


	local BUILDDIR=`mktemp -d -t "$(whoami)-build-${PKG_TARNAME}-XXXXXX"` || (
		echo "ERROR: Can't create temporary build directory." 1>&2
		return 1
	)
	echo "Build directory: \"${BUILDDIR}\""


	local OLD_INST_PREFIX="${SWMOD_INST_PREFIX}"

	local STATUS="ok"

	if (swi_is_generic_version_no "${WHAT}") ; then
		if (! swi_is_version_no "${WHAT}") ; then
			echo "ERROR: \"${WHAT}\" is not a valid version number for this project." 1>&2
			false
		fi \
		&& if [ ""`type -t swi_modify_pkg_version` = "function" ] ; then
			local PKG_VERSION=`swi_modify_pkg_version "${WHAT}"`
		else
			local PKG_VERSION="${WHAT}"
		fi \
		&& (
			cd "${BUILDDIR}" \
			&& local DOWNLOAD_URL=`swi_get_download_url "${PKG_VERSION}"` \
			&& echo "Downloading ${PKG_NAME} version ${PKG_VERSION} from ${DOWNLOAD_URL}" \
			&& curl "${DOWNLOAD_URL}" |
				tar --strip-components 1 -C "${BUILDDIR}" --strip=1 -x -z \
		)
	else
		local PKG_FROM="${WHAT}" \
		&& echo "Copying ${PKG_NAME} sources from ${PKG_FROM} to ${BUILDDIR}" \
		&& rsync -rlpt "${PKG_FROM}/" "${BUILDDIR}/" \
		&& local PKG_VERSION=`(cd "${BUILDDIR}/" && swi_get_version_no)`
	fi \
	&& . swmod.sh setinst "${PKG_TARNAME}@${PKG_VERSION}" \
	&& if [ -e "${SWMOD_INST_PREFIX}" ] ; then
		rmdir "${SWMOD_INST_PREFIX}" || (
			echo "Error: Install prefix \"${SWMOD_INST_PREFIX}\" exists and is not a removeable empty directory."
			false
		)
	fi \
	&& (
		echo "Installing ${PKG_NAME} version ${PKG_VERSION}" \
		&& echo "Install prefix: ${SWMOD_INST_PREFIX}" \
		&& echo "${BUILDSYS} options:" "$@" \

		cd "${BUILDDIR}" \
		&& swi_build_and_install_internal "$@" \
	) || local STATUS="fail"


	local inst_prefix="${SWMOD_INST_PREFIX}"
	export SWMOD_INST_PREFIX="${OLD_INST_PREFIX}"

	test -d "${BUILDDIR}" && rm -rf "${BUILDDIR}"

	if [ "${STATUS}" != "ok" ] ; then
		echo "ERROR: Installation failed." 1>&2
		return 1
	fi;


	echo ""
	echo "Successfully installed ${PKG_NAME} to \"${inst_prefix}\"."
	echo "Use"
	echo ""
	echo "    swmod load ${PKG_TARNAME}@${PKG_VERSION}"
	echo ""
	echo "to load the newly installed ${PKG_NAME}."
}
