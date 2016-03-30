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
#
# Created Mar. 29, 2016, Giovanni Benato <gbenato@berkeley.edu>
#

BASIC_BUILD_OPTS=""

ADDITIONAL_BUILD_OPTS=""

DEFAULT_BUILD_OPTS=`echo ${BASIC_BUILD_OPTS} ${ADDITIONAL_BUILD_OPTS}`

swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
    echo "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.9.tar.xz"
}

swi_get_version_no() {
	cat configure | grep 'PACKAGE_VERSION[^_]' | grep -o '[0-9.]\+' | head -1
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+[.][0-9]\+$'
}

swi_build_and_install() {
local src_dir=`pwd` \
    && local build_dir="../"`basename "${src_dir}"`_build_"`. swmod.sh hostspec`" \
	&& mkdir "${build_dir}" \
	&& cd "${build_dir}" \
	&& . swmod.sh "${src_dir}"/configure --without-p11-kit "$@" \
	&& make -j`. swmod.sh nthreads` \
	&& make install
}
