SVN = http://svn.rtpg2.rshadow.ru

VERSION		= $(shell \
	grep VERSION index.cgi |grep ^our \
	|sed 's/^[^[:digit:]]\+//' |sed 's/".*//')

SVN_VERSION = $(shell svn info|grep ^Revision:|awk '{print $$2}')

SVERSION    = $(VERSION)+svn$(SVN_VERSION)

LANGS		:= 	$(shell ls po/*.po|sed 's/...$$//'|sed 's/^...//')

# Extract gettext strings to en.po file
.PHONY: i18n
i18n:
	# find all gettext messages and save in *.pot
	for file in `find templates lib -type f | grep -v '\.svn'`; do \
		perl tools/extract_po.pl \
			-o "gettext('" -c "')" -q \
			$$file  build/`basename $$file`.pot; \
	done
	# concat all files in one template
	msgcat build/*.pot po/STATIC.pot > po/TEMPLATE.pot
	# update current transtation files
	for lang in $(LANGS); do \
		msgmerge --suffix=.previous --update po/$$lang.po po/TEMPLATE.pot; \
	done

clean:
	rm -fr build/*
	rm -fr po/*.previous
	
all: po

#    
#    templates/langs/%.html: po/%.po $(TEMPLATE_PO)
#    	perl tools/poabstract/gen_translate.pl -s templates/index.tt.html $<	>$@
#    
#    js/langs/%.main.js: po/%.po $(TEMPLATE_PO)
#    	perl poabstract/gen_translate.pl -s js/main.js $< > $@
#    
#    
#    build/html.po: templates/index.tt.html Makefile
#    	perl poabstract/extract_po.pl -s $< $@
#    
#    build/js.po: js/main.js Makefile
#    	perl poabstract/extract_po.pl -s $< $@
#    
#    
#    $(TEMPLATE_PO): build/html.po build/js.po
#    	msgcat $^ > $@
#    	for lang in $(LANGS); do \
#    		msgmerge --suffix=.previous --update po/$$lang.po $@; \
#    	done
#
#	grep --recursive --perl-regexp --only-matching --no-filename --no-messages \
#		--regexp="gettext\(('.*?')\)" ./*
		
#	sed 's/^gettext(//' | \
#	sed 's/)$//'

#	xgettext \
#		--files-from=htdocs/index.cgi \
#		--output=po/111.p \
#		--language=Perl --extract-all