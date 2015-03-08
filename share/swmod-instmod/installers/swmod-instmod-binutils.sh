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


DEFAULT_BUILD_OPTS="\
--enable-plugins \
--enable-shared \
"

swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
	echo "http://ftpmirror.gnu.org/binutils/binutils-${1}.tar.bz2"
}

swi_get_version_no() {
	cat bfd/configure.in | grep AC_INIT | grep -o '[0-9.]\+'
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+$'
}
