AM_CFLAGS = $(JSON_CFLAGS)

NULL = 

lib_LTLIBRARIES = libjson-vala.la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = json-vala.vapi

json_valaincludedir = $(includedir)
json_valainclude_HEADERS = json-vala.h 

libjson_vala_la_SOURCES = array.vala json.vala node.vala object.vala path.vala generator.vala builder.vala reader.vala

libjson_vala_la_VALAFLAGS = \
	-H json-vala.h --vapi json-vala.vapi --pkg mee --pkg gee-0.8 --pkg gio-2.0 \
	--library json-vala --disable-warnings --gir JsonVala-0.1.gir

libjson_vala_la_LIBADD = $(JSON_LIBS)

libjson_vala_la_LDFLAGS = -version-info "2:0:0" -no-undefined
	
EXTRA_DIST = $(libjson_vala_la_SOURCES) json-vala.vapi json.vala.stamp

CLEANFILES = json-vala.vapi *.h *.c *.vala~ *.stamp* *.gir *.typelib

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
JsonVala_0_1_gir_INCLUDES = Gee-0.8
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
