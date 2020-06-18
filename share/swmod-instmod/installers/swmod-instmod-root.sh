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
-Dfail-on-missing=ON \
-Dshared=ON \
-Dsoversion=ON \
-Dexplicitlink=ON \
"

ADDITIONAL_BUILD_OPTS="\
-Dasimage=ON \
-Dastiff=ON \
-Dfftw3=ON \
-Dgdml=ON \
-Dgsl-shared=ON \
-Dhttp=ON \
-Dmathmore=ON \
-Dminuit2=ON \
-Dopengl=ON \
-Dpython=ON \
-Droofit=ON \
-Dssl=ON \
-Dtable=ON \
-Dtmva=ON \
-Dunuran=ON \
-Dxml=ON \
-Dxft=ON \
-Dbuiltin_gsl=ON \
-Dbuiltin_tbb=ON
\
-Dafs=OFF \
-Dalien=OFF \
-Dbonjour=OFF \
-Dbuiltin-afterimage=OFF \
-Dbuiltin-freetype=OFF \
-Dbuiltin-ftgl=OFF \
-Dbuiltin-pcre=OFF \
-Dbuiltin-zlib=OFF \
-Dcastor=OFF \
-Ddavix=OFF \
-Dchirp=OFF \
-Ddcache=OFF \
-Dfitsio=OFF \
-Dgfal=OFF \
-Dglobus=OFF \
-Dhdfs=OFF \
-Dkrb5=OFF \
-Dldap=OFF \
-Dmonalisa=OFF \
-Dmysql=OFF \
-Dodbc=OFF \
-Doracle=OFF \
-Dpgsql=OFF \
-Dpythia6=OFF \
-Dpythia8=OFF \
-Dqt=OFF \
-Dqtgsi=OFF \
-Drfio=OFF \
-Drpath=OFF \
-Druby=OFF \
-Dsapdb=OFF \
-Dshadowpw=OFF \
-Dsqlite=OFF \
-Dsrp=OFF \
-Dxrootd=OFF \
"

DEFAULT_BUILD_OPTS=`echo ${BASIC_BUILD_OPTS} ${ADDITIONAL_BUILD_OPTS}`


FFTW3_PREFIX=$( (dirname $(dirname `which fftw-wisdom`)) 2> /dev/null )
if [ -n "${FFTW3_PREFIX}" ] ; then
	FFTW3_MODNAME=`. swmod.sh list "${FFTW3_PREFIX}" 2> /dev/null`
	if [ -n "${FFTW3_MODNAME}" ] ; then
		echo "FFTW3 loaded via swmod, will add ${FFTW3_MODNAME} to target package dependencies."

		DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} -DFFTW_INCLUDE_DIR=${FFTW3_PREFIX}/include"

		if \test -d "${FFTW3_PREFIX}/lib64" ; then
			DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} -DFFTW_LIBRARY=${FFTW3_PREFIX}/lib64/libfftw3.so"
		else
			DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} -DFFTW_LIBRARY=${FFTW3_PREFIX}/lib/libfftw3.so"
		fi
	fi
fi

swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
	echo "https://root.cern.ch/download/root_v${1}.source.tar.gz"
}

swi_get_version_no() {
	test -d .git && (git describe HEAD | sed 's/^v[ -_]\?//; s/^\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\)/\1.\2.\3/') || (cat build/version_number | sed 's|/|.|g')
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+[.][0-9]\+$'
}

swi_build_and_install() {
	export ROOTSYS="${SWMOD_INST_PREFIX}" \
	&& . swmod.sh install "$@" \
	&& echo '. "$SWMOD_PREFIX/bin/thisroot.sh"' > "${SWMOD_INST_PREFIX}/swmodrc.sh" \
	&& (test -n "${FFTW3_MODNAME}" && . swmod.sh add-deps "${FFTW3_MODNAME}" || true) \
	&& swi_add_bin_dep python
}
