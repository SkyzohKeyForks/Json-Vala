AC_INIT([mee-json], [1.4], [inizan.yannick@gmail.com], [mee-json])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([check-news dist-bzip2 subdir-objects])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CONFIG_FILES([
Makefile
src/mee-json-1.0.pc
src/Makefile
])

AM_PROG_AR
LT_INIT
AC_PROG_CC
AM_PROG_VALAC

pkg_modules="gobject-2.0
	mee-1.0"
PKG_CHECK_MODULES(JSON_VALA, [$pkg_modules])

AC_OUTPUT
