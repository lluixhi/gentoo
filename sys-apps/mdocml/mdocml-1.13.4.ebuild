# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit savedconfig toolchain-funcs

DESCRIPTION="The mandoc UNIX manpage compiler toolset"
HOMEPAGE="http://mdocml.bsd.lv/"
SRC_URI="http://mdocml.bsd.lv/snapshots/${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="ISC"
SLOT="0"
IUSE="cgi manpager savedconfig +sqlite static static-libs"

REQUIRED_USE="cgi? ( sqlite )"

DEPEND="
	sys-libs/zlib
	sqlite? ( dev-db/sqlite )"

RDEPEND="${DEPEND}
	manpager? ( app-text/manpager )
	!sys-apps/man
	!sys-apps/man-db"

src_configure() {
	mv cgi.h.example cgi.h || die
	restore_config cgi.h

	# Non-autotools configure script reads configure.local file for options
	local myconf=(
		CC=$(tc-getCC) \
		CFLAGS="\"${CFLAGS}\"" \
		LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		MANDIR="${EPREFIX}/usr/share/man" \
		PREFIX="${EPREFIX}/usr" \
		INSTALL_DATA="echo" \
		INSTALL_MAN="\"install -m 0644\"" \
		INSTALL_PROGRAM="\"install -m 0755\"" \
		BINM_SOELIM="mandoc-soelim" \
		HAVE_MANPATH=0 \
		MANPATH_DEFAULT="/usr/local/share/man:/usr/share/man" \
		OSNAME="Gentoo"
	)

	myconf+=( INSTALL_LIB="$(usex static-libs '\"install -m 0644\"' 'echo')" )
	myconf+=( STATIC="$(usex static '-static -pthread' '')" )
	myconf+=( BUILD_DB="$(usex sqlite 1 0)" )
	myconf+=( BUILD_CGI="$(usex cgi 1 0)" )

	echo "${myconf[@]}" > configure.local || die
	./configure || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install

	insinto /etc
	doins "${FILESDIR}"/man.conf

	# These conflict with man-pages
	rm "${ED}"/usr/share/man/man7/{roff,man,mdoc}.7 || die

	save_config cgi.h

	einstalldocs
}

pkg_postinst() {
	einfo "Regenerating man db..."
	makewhatis -a -Tutf8
}
