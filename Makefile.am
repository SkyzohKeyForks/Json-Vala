## Process this file with automake to produce Makefile.in
## Created by Anjuta

if ENABLE_DOC
DOC_SUBDIR = \
	doc \
	$(NULL)
endif

SUBDIRS = src $(DOC_SUBDIR)

dist_doc_DATA = \
	README \
	COPYING \
	AUTHORS \
	ChangeLog \
	INSTALL \
	NEWS

all: all-recursive

# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(docdir)

update_submodules:
	if test -d ".git"; then \
		git submodule update --init --recursive && git submodule foreach './autogen.sh' || exit 1; \
	fi
	
%-recursive:
	set . final_exit=:; \
	for dir in $(SUBDIRS); do \
		case $$dir in \
		.) $(MAKE) $*-local || { final_exit="exit 1"; };;\
		*) (cd $$dir && $(MAKE) $*) || { final_exit="exit 1"; };;\
		esac \
	done
	$$final_exit

clean: clean-recursive
install: install-recursive
uninstall: uninstall-recursive
distcheck: distcheck-recursive

distclean: distclean-recursive
