AC_INIT([json-vala], [1.7], [inizan.yannick@gmail.com], [json-vala])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([check-news dist-bzip2 subdir-objects])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CONFIG_FILES([
Makefile
src/json-vala-1.0.pc
src/Makefile
])

AM_PROG_AR
LT_INIT
AC_PROG_CC
AM_PROG_VALAC

PKG_CHECK_MODULES(JSON_VALA, [gio-2.0 gee-0.8])

AC_OUTPUT
