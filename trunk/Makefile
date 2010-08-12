SVN = http://svn.rtpg2.rshadow.ru

RTPGMVERSION    = $(shell \
    grep '^our[[:space:]]\+\$$VERSION' lib/RTPG.pm \
    | sed 's/^[^[:digit:]]\+//' \
    | sed 's/[[:space:]]*;.*//' \
)

CPANMODULE	= RTPG-$(RTPGMVERSION).tar.gz

DEBVERSION 	= $(shell \
	dpkg-parsechangelog|grep ^Version:|awk '{print $$2}' \
		|sed 's/-[[:digit:]]\+$$//' )

DEBFULLVERSION 	= $(shell \
	dpkg-parsechangelog|grep ^Version:|awk '{print $$2}')

VERSION		= $(shell \
	grep VERSION htdocs/index.cgi |grep ^our \
	|sed 's/^[^[:digit:]]\+//' |sed 's/".*//')

SVN_VERSION = $(shell svn info|grep ^Revision:|awk '{print $$2}')

SVERSION    = $(VERSION)+svn$(SVN_VERSION)

LANGS		:= 	$(shell ls po/*.po|sed 's/...$$//'|sed 's/^...//')

# Extract gettext strings to en.po file
.PHONY: i18n cpan
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


build/$(CPANMODULE): lib/RTPG.pm lib/RTPG/Direct.pm $(wildcard cpan/*)
	rm -fr build/cpan
	mkdir -p build/cpan/RTPG
	cp -ar cpan/* build/cpan
	cp -a $< build/cpan
	cp -a lib/RTPG/Direct.pm build/cpan/RTPG
	cd build/cpan && perl Makefile.PL
	make -C build/cpan distdir
	cd build/cpan && tar -czvf ../$(CPANMODULE) RTPG-$(RTPGMVERSION)


cpan:	build/$(CPANMODULE)
	
all: po


SRC		=	$(shell find .|grep -v '\./build\|\.svn')
DEB		=	build/rtpg-www_$(DEBFULLVERSION)_all.deb
ORIG		=	build/rtpg_$(DEBVERSION).orig.tar.gz

deb-package: build/stamp $(DEB)

deb-changelog:
	dch --newversion $(VERSION)

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
	cd build && \
		tar --exclude=debian -czf \
			rtpg_$(DEBVERSION).orig.tar.gz rtpg-$(DEBVERSION)/
	
	
