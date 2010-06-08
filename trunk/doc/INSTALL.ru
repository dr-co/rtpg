RTPG (rtorrent perl gui) - простой веб-GUI для rtorrent.
Реализует такие функции, как: добавление/удаление/установка приоритетов
для торрентов и отдельных их частей.

SVN-репозитарий RTPG можно найти по адресу: http://svn.rtpg2.rshadow.ru/

Зависимости:
    librpc-xml-perl     http://search.cpan.org/dist/rpc-xml/
    libjson-xs-perl     http://search.cpan.org/dist/json-xs/
    libjs-jquery        http://jquery.com/
    libtemplate-perl    http://search.cpan.org/dist/template-toolkit/
    rtorrent            http://libtorrent.rakshasa.no/
    apache2             http://httpd.apache.org/
    liblocale-po-perl   http://search.cpan.org/dist/locale-po/
    libmime-types-perl  http://search.cpan.org/dist/mime-types/
    libtree-simple-perl http://search.cpan.org/dist/tree-simple/

Необязательные, для показа флагов в списке пиров:
    libgeo-ipfree-perl  http://search.cpan.org/dist/geo-ipfree/
    famfamfam-flag-png  http://www.famfamfam.com/lab/icons/flags/

1. Разверните архив
2. Создайте виртуальный сервер, пример: debian/rtpg.apache.conf
   переменная окружения rtpg_config должна указывать на файл rtpg.conf
3. Положите jquery.js в каталог htdocs/js/
4. Настройте rtorrent, пример: debian/rtorrent.rc
