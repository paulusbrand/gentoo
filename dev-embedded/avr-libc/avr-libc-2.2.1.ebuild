# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

CHOST="avr"
CTARGET="avr"

inherit flag-o-matic

DESCRIPTION="C library for Atmel AVR microcontrollers"
HOMEPAGE="https://github.com/avrdudes/avr-libc"
SRC_URI="https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_2_1-release/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
# 'amd64' is a blessed placeholder for crossdev. It could
# be any other arch. See bug #620316#c5
# Don't add more arches to KEYWORDS.
KEYWORDS="amd64"
IUSE="headers-only"

DEPEND=">=sys-devel/crossdev-0.9.1"
[[ ${CATEGORY/cross-} != ${CATEGORY} ]] \
	&& RDEPEND="!dev-embedded/avr-libc" \
	|| RDEPEND=""

DOCS="AUTHORS NEWS"

pkg_setup() {
	# check for avr-gcc, bug #134738
	ebegin "Checking for avr-gcc"
	if type -p avr-gcc > /dev/null ; then
		eend 0
	else
		eend 1

		eerror
		eerror "Failed to locate 'avr-gcc' in \$PATH. You can install an AVR toolchain using:"
		eerror "  $ crossdev -t avr"
		eerror
		die "AVR toolchain not found"
	fi
}

src_prepare() {
	default

	# work around broken gcc versions PR45261
	local mcu
	for mcu in $(sed -r -n '/CHECK_AVR_DEVICE/{s:.*[(](.*)[)]:\1:;p}' configure.ac) ; do
		if avr-gcc -E - -mmcu=${mcu} <<<"" |& grep -q 'unknown MCU' ; then
			sed -i "/HAS_${mcu}=yes/s:yes:no:" configure
		fi
	done

	strip-flags
	strip-unsupported-flags
}

src_install() {
	default

	# Make sure diff cross-compilers don't collide #414075
	mv "${ED}"/usr/share/doc/{${PF},${CTARGET}-${PF}} || die
}
