SVN = http://svn.rtpg2.rshadow.ru

VERSION		= $(shell \
	grep VERSION index.cgi |grep ^our \
	|sed 's/^[^[:digit:]]\+//' |sed 's/".*//')

SVN_VERSION = $(shell svn info|grep ^Revision:|awk '{print $$2}')

SVERSION    = $(VERSION)+svn$(SVN_VERSION)

# Extract gettext strings to en.po file
.PHONY: extract_po
extract_po:
	grep --recursive --perl-regexp --only-matching --no-filename --no-messages \
		--regexp="gettext\(('.*?')\)" ./*
		
#	sed 's/^gettext(//' | \
#	sed 's/)$//'

#	xgettext \
#		--files-from=htdocs/index.cgi \
#		--output=po/111.p \
#		--language=Perl --extract-all