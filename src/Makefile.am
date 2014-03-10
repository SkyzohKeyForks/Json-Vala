## Process this file with automake to produce Makefile.in

## Created by Anjuta

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(JSON_VALA_CFLAGS)

AM_CFLAGS = -I ../mee/src\
	 -Wall\
	 -g

lib_LTLIBRARIES = libjson-vala.la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = json-vala.vapi json-vala.deps

libjson_vala_la_SOURCES = node.vala \
	object.vala \
	json.vala \
	array.vala \
	parser.vala \
	path.vala \
	generator.vala \
	builder.vala \
	reader.vala \
	serialize.vala \
	../mee/src/mee-1.0.vapi

libjson_vala_la_LDFLAGS = 
	
libjson_vala_la_VALAFLAGS =  --pkg gio-2.0 --pkg gee-0.8 \
	--library json-vala --vapi json-vala.vapi -H json-vala.h

libjson_vala_la_LIBADD = $(JSON_VALA_LIBS) ../mee/src/libmee.la


json_valaincludedir = $(includedir)/json-vala-0.1
json_valainclude_HEADERS = \
	json-vala.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = json-vala.pc

EXTRA_DIST = \
	json-vala.pc.in
	
CLEANFILES = *.c *.stamp json-vala.h json-vala.vapi

DISTCLEANFILES = $(CLEANFILES) Makefile json-vala.pc
