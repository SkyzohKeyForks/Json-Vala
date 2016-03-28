prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=${prefix}
libdir=@LIB_INSTALL_DIR@
includedir=${prefix}/include/json-vala

Name: Json
Description: JSON library.
Version: @API_VERSION@
Requires: gio-2.0 gee-0.8
Libs: -L${libdir} -ljson-vala
Cflags: -I${includedir}
