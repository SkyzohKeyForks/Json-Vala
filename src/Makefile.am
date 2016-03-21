lib_LTLIBRARIES = libjson-vala-1.0.la

libjson_vala_1_0_la_CFLAGS = -w -g $(JSON_VALA_CFLAGS) -lm -lmagic

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = json-vala-1.0.vapi json-vala-1.0.deps

libjson_vala_1_0_la_SOURCES = Array.vala Encoding.vala Generator.vala Node.vala \
	Object.vala Parser.vala Reader.vala Serialize.vala Stream.vala \
	schema/Schema.vala schema/SchemaArray.vala schema/SchemaNumber.vala schema/SchemaObject.vala schema/SchemaString.vala \
	bson/BsonDocument.vala bson/BsonReader.vala

libjson_vala_1_0_la_LDFLAGS = -version-info 1:7:0
	
libjson_vala_1_0_la_VALAFLAGS = --library json-vala-1.0 -H json-vala.h --pkg gio-2.0 --pkg gee-0.8 --pkg libmagic --vapidir=vapi

libjson_vala_1_0_la_LIBADD = $(JSON_VALA_LIBS)


json_valaincludedir = $(includedir)/json-vala-1.0
json_valainclude_HEADERS = \
	json-vala.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = json-vala-1.0.pc

EXTRA_DIST = $(libjson_vala_1_0_la_SOURCES) json-vala-1.0.pc.in
	
CLEANFILES = *.c bson/*.c schema/*.c *.stamp *.h *.vapi

DISTCLEANFILES = $(CLEANFILES) Makefile *.pc
