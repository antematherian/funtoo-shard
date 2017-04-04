# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="Dia - Funtoo Linux diagnostic script"
HOMEPAGE="https://github.com/antematherian/dia"
SRC_URI="https://github.com/antematherian/dia/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="app-text/mpaste"

src_install() {
	dobin ${PN}
}
