dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard.

AC_INIT(json-vala, 0.1)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_AR

AM_PROG_VALAC


AC_ARG_ENABLE(doc, AS_HELP_STRING([--enable-doc], [Enable documentation generation]), enable_doc=$enableval, enable_doc=no)
AM_CONDITIONAL(ENABLE_DOC, test x$enable_doc = xyes)

AS_IF([test "x$enable_doc" != xno],
	[AC_PATH_PROG(VALADOC, valadoc, :)
	 AC_SUBST(VALADOC)
	 AS_IF([test "$VALADOC" = :],
		[AC_MSG_ERROR([valadoc not found])])])



LT_INIT

pkg_modules="gobject-2.0
	gio-2.0
	gee-0.8"
PKG_CHECK_MODULES(JSON_VALA, [$pkg_modules])

AC_OUTPUT([
Makefile
src/json-vala.pc
src/Makefile
doc/Makefile
])

SUBMODULE_ERROR='Could not recursively update all git submodules. You may experience compilation problems if some submodules are out of date'
SUBMODULE_OK='Git submodules updated successfully'
if test -d .git; then \
	   (git submodule update --init --recursive && echo $SUBMODULE_OK) \
	|| (git submodule init && git submodule update --recursive && echo $SUBMODULE_OK) \
	|| (git submodule init && git submodule update && echo $SUBMODULE_ERROR) \
	|| (echo 'Git submodules could not be updated. Compilation will fail') \
fi
