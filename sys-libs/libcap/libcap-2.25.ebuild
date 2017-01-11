# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils multilib multilib-minimal toolchain-funcs pam

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://www.friedhoff.org/posixfilecaps.html"
SRC_URI="mirror://kernel/linux/libs/security/linux-privs/libcap2/${P}.tar.xz"

# it's available under either of the licenses
LICENSE="|| ( GPL-2 BSD )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux"
IUSE="pam static-libs"

RDEPEND=">=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}]
	pam? ( virtual/pam )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

PATCHES=(
	"${FILESDIR}"/${PN}-2.25-build-system-fixes.patch
	"${FILESDIR}"/${PN}-2.22-no-perl.patch
	"${FILESDIR}"/${PN}-2.25-ignore-RAISE_SETFCAP-install-failures.patch
	"${FILESDIR}"/${PN}-2.21-include.patch
)

GPERF_PATCHES=("${FILESDIR}"/${PN}-2.25-gperf-3.1.patch ) #604802 and FL-3473

src_prepare() {
	epatch "${PATCHES[@]}"
	#the patch that fixes version gperf 3.1.0 (excuse me, gperf 3.1)
	#breaks the build on version gperf 3.0.4 , so some hacking needs to be done
	#if the version is higher or equal to 3.1.0, apply the patch.
	#note to future maintainer: Test >gperf 3.1.1 and see if the patch still works. 
	if [ "$(gperf --version | grep gperf | sed s'/ /\n/'g | grep 3 | sed s'/\.//'g)" -ht 309 ]
	then
		epatch "${GPERF_PATCHES[@]}"
	fi
	#and for version 3.1
	if [ "$(gperf --version | grep gperf | sed s'/ /\n/'g | grep 3 | sed s'/\.//'g)" -eq 31 ]
	then
		epatch "${GPERF_PATCHES[@]}"
	fi

	multilib_copy_sources
}

multilib_src_configure() {
	local pam
	if multilib_is_native_abi && use pam; then
		pam=yes
	else
		pam=no
	fi

	sed -i \
		-e "/^PAM_CAP/s:=.*:=${pam}:" \
		-e '/^DYNAMIC/s:=.*:=yes:' \
		-e '/^lib_prefix=/s:=.*:=$(prefix):' \
		-e "/^lib=/s:=.*:=$(get_libdir):" \
		Make.Rules
}

multilib_src_compile() {
	tc-export_build_env BUILD_CC
	tc-export AR CC RANLIB

	default
}

multilib_src_install() {
	# no configure, needs explicit install line #444724#c3
	emake install DESTDIR="${ED}"

	gen_usr_ldscript -a cap
	use static-libs || rm "${ED}"/usr/$(get_libdir)/libcap.a

	rm -rf "${ED}"/usr/$(get_libdir)/security
	if multilib_is_native_abi && use pam; then
		dopammod pam_cap/pam_cap.so
		dopamsecurity '' pam_cap/capability.conf
	fi
}

multilib_src_install_all() {
	dodoc CHANGELOG README doc/capability.notes
}
