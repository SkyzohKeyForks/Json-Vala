lib_LTLIBRARIES = libmee-json-1.0.la

libmee_json_1_0_la_CFLAGS = -w -g $(JSON_VALA_CFLAGS) -lm

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = mee-json-1.0.vapi mee-json-1.0.deps

libmee_json_1_0_la_SOURCES = array.vala error.vala generator.vala node.vala object.vala \
	reader.vala writer.vala parser.vala property.vala serializer.vala \
	schema/schema.vala schema/schemaobject.vala schema/schemaarray.vala schema/schemastring.vala schema/schemanumber.vala \
	bson/bsonreader.vala bson/bsondocument.vala bson/bsonwriter.vala

libmee_json_1_0_la_LDFLAGS = -version-info 1:5
	
libmee_json_1_0_la_VALAFLAGS = --pkg mee-1.0 --library mee-json-1.0 -H mee-json.h --disable-warnings

libmee_json_1_0_la_LIBADD = $(JSON_VALA_LIBS)


json_valaincludedir = $(includedir)/json-vala-1.0
json_valainclude_HEADERS = \
	mee-json.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = mee-json-1.0.pc

EXTRA_DIST = \
	mee-json-1.0.pc.in
	
CLEANFILES = *.c schema/*.c bson/*.c *.stamp *.h *.vapi

DISTCLEANFILES = $(CLEANFILES) Makefile mee-json-1.0.pc
