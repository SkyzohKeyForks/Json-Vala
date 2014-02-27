## Process this file with automake to produce Makefile.in
## Created by Anjuta

if ENABLE_DOC
DOC_SUBDIR = \
	doc \
	$(NULL)
endif

SUBDIRS = mee src $(DOC_SUBDIR)

dist_doc_DATA = \
	README \
	COPYING \
	AUTHORS \
	ChangeLog \
	INSTALL \
	NEWS



# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(docdir)

all:
	if test -d ".git"; then \
		git submodule update --init --recursive || exit 1; \
	fi
	for dir in $(SUBDIRS); do \
		case $$dir in \
		.) $(MAKE) $* ;;\
		*) (cd $$dir && $(MAKE) $*) ;;\
		esac \
	done
