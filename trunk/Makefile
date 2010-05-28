SVN = http://svn.rtpg2.rshadow.ru


DEBVERSION 	= $(shell \
	dpkg-parsechangelog|grep ^Version:|awk '{print $$2}' \
		|sed 's/-[[:digit:]]\+$$//' )

DEBFULLVERSION 	= $(shell \
	dpkg-parsechangelog|grep ^Version:|awk '{print $$2}')

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
	msgcat build/*.pot tools/STATIC.pot > po/TEMPLATE.pot
	# update current transtation files
	for lang in $(LANGS); do \
		msgmerge --suffix=.previous --update po/$$lang.po po/TEMPLATE.pot; \
	done

clean:
	rm -fr build/*
	rm -fr po/*.previous
	
all: po


SRC		=	$(shell find .|grep -v '\./build\|\.svn')
DEB		=	build/rtpg-www_$(DEBFULLVERSION)_all.deb
ORIG		=	build/rtpg_$(DEBVERSION).orig.tar.gz

deb-package: build/stamp $(DEB)

build/stamp:
	mkdir -p build
	touch $@

$(DEB): $(ORIG)
	cd build/rtpg-$(DEBVERSION)/ && debuild

$(ORIG): $(SRC)
	rm -fr build/rtpg-$(DEBVERSION)
	mkdir build/rtpg-$(DEBVERSION)
	rsync --exclude=.svn --exclude=build -a \
		* build/rtpg-$(DEBVERSION)/
	cd build && tar -czf rtpg_$(DEBVERSION).orig.tar.gz rtpg-$(DEBVERSION)/
	
	
