AC_INIT([json-vala], [0.1], [inizan.yannick@gmail.com], [libjson-vala])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([check-news dist-bzip2 subdir-objects])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])
AC_CONFIG_FILES([Makefile
		src/Makefile
		json-vala.pc])

AM_PROG_AR
LT_INIT
AC_PROG_CC
AM_PROG_VALAC

pkg_modules="glib-2.0 >= 2.24.1
             gobject-2.0 >= 2.24.1
             gio-2.0 >= 2.24.1
             gee-0.8
             mee"
             
PKG_CHECK_MODULES(JSON, [$pkg_modules])
AC_SUBST(JSON_CFLAGS)
AC_SUBST(JSON_LIBS)

GOBJECT_INTROSPECTION_CHECK([0.9.0])

AC_OUTPUT
