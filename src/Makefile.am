AM_CPPFLAGS = -std=c99 -w \
	$(GLIB_CFLAGS) \
	$(DEPS_CFLAGS)

NULL = 

BUILT_SOURCES = json.vala.stamp

lib_LTLIBRARIES = libjson-vala.la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = json-vala.vapi

json_valaincludedir = $(includedir)
json_valainclude_HEADERS = json-vala.h 

libjson_vala_la_VALASOURCES = array.vala json.vala node.vala object.vala

AM_VALAFLAGS = \
	-H json-vala.h --vapi json-vala.vapi --pkg mee --pkg gee-0.8 \
	--library json-vala --disable-warnings

libjson_vala_la_SOURCES = json.vala.stamp $(libjson_vala_la_VALASOURCES:.vala=.c)

libjson_vala_la_LIBADD = $(GLIB_LIBS) $(DEPS_LIBS)

libjson_vala_la_LDFLAGS = -version-info "2:0:0" -no-undefined

json-vala.vapi json.vala.stamp: $(libjson_vala_la_VALASOURCES)
	$(VALAC) -C $(AM_VALAFLAGS) $^
	touch $@
	
EXTRA_DIST = $(libjson_vala_la_VALASOURCES) json-vala.vapi json.vala.stamp

CLEANFILES = json-vala.vapi *.h *.c *.stamp* *.gir *.typelib

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = \
	--add-include-path=$(srcdir) \
	--identifier-prefix=Json \
	--symbol-prefix=json \
	--nsversion=0.1 \
	--pkg=mee -I../ -I$(srcdir)/..

INTROSPECTION_COMPILER_ARGS = --includedir=$(srcdir)

if HAVE_INTROSPECTION
introspection_sources = $(libjson_vala_la_SOURCES) json-vala.h

JsonVala-0.1.gir: libjson-vala.la
JsonVala_0_1_gir_INCLUDES = Mee-0.1 Gee-0.8
JsonVala_0_1_gir_CFLAGS = $(INCLUDES)
JsonVala_0_1_gir_LIBS = libjson-vala.la
JsonVala_0_1_gir_FILES = $(introspection_sources)
INTROSPECTION_GIRS += JsonVala-0.1.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(INTROSPECTION_GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(INTROSPECTION_GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif
