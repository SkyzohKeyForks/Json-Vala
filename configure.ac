dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard. 

AC_INIT(json-vala, 1.4)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_AR

AM_PROG_VALAC

LT_INIT

pkg_modules="gobject-2.0
	mee-1.0"
PKG_CHECK_MODULES(JSON_VALA, [$pkg_modules])

AC_OUTPUT([
Makefile
src/json-vala.pc
src/Makefile
])
