# increase when you break the API
set (PKG_SOVERSION 3)

# Increase when you add functionality
set (PKG_SOMINOR 0.1)

set (VALA_SOURCES
	Array.vala
	Encoding.vala
	Generator.vala
	Node.vala 
	Object.vala
	Parser.vala
	Reader.vala
	Serialize.vala
	Stream.vala
	schema/Schema.vala
	schema/SchemaArray.vala
	schema/SchemaNumber.vala
	schema/SchemaObject.vala
	schema/SchemaString.vala
	bson/BsonDocument.vala
	bson/BsonReader.vala
)

######################
# lib PC file
######################
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$") # You hear that? It's kittens being killed by the gods of cmake

configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc)

include (GNUInstallDirs)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig)

# Link all
set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (LIBS ${DEPS_LIBRARIES})
set (LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories (${LIB_PATHS})

option (VAPI_COMMENTS "Include comments in the generated vapi file" OFF)

if (VAPI_COMMENTS)
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --vapi-comments)
endif ()

vala_precompile (VALA_C ${PKG_NAME}
    ${VALA_SOURCES}
PACKAGES
    ${PKG_DEPS}
GENERATE_HEADER
    ${PKG_NAME}
GENERATE_VAPI
    ${PKG_NAME}
OPTIONS
    ${VALAC_OPTIONS}
)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.vapi DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.deps DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.h DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PKG_NAME})

set (LIB_FILES ${VALA_C})

add_library (${PKG_NAME} SHARED ${LIB_FILES})

target_link_libraries (${PKG_NAME} ${LIBS})

set_target_properties (${PKG_NAME} PROPERTIES
    VERSION ${PKG_SOVERSION}.${PKG_SOMINOR}
    SOVERSION ${PKG_SOVERSION})

install (TARGETS ${PKG_NAME} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})
