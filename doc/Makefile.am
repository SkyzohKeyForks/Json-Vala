SRC_DIR = $(top_srcdir)/src

docdir=$(datadir)/devhelp/references/json-vala
innerdocdir=$(docdir)/json-vala
imgdir=$(innerdocdir)/img

doc_data = \
	json-vala/*.css \
	json-vala/*.png \
	$(NULL)

doc_DATA = \
	json-vala/index.html \
	$(doc_data) \
	$(NULL)

innerdoc_DATA = \
	json-vala/json-vala/index.htm \
	json-vala/json-vala/*.html \
	$(NULL)

img_DATA = \
	json-vala/json-vala/img/*.png \
	$(NULL)

$(doc_data) $(innerdoc_DATA) $(img_DATA): json-vala/index.html

json-vala/index.html:
	$(VALADOC) -o json-vala/ --wiki ./ --force -b $(top_srcdir) $(SRC_DIR)/*.vala --pkg mee-1.0 --pkg gee-0.8 --pkg gio-2.0 \
		--deps=gee-0.8 --deps=gio-2.0 --deps=mee-1.0

EXTRA_DIST = \
	index.wiki \
	$(NULL)
	
clean-local:
	rm -rf json-vala
