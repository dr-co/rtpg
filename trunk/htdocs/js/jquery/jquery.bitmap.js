/*************************************************************************
 *                                                                       *
 * Copyright (C) 2009 Dmitry E. Oboukhov <unera@debian.org>              *
 *                                                                       *
 * This program is free software: you can redistribute it and/or modify  *
 * it under the terms of the GNU General Public License as published by  *
 * the Free Software Foundation, either version 3 of the License, or     *
 * (at your option) any later version.                                   *
 *                                                                       *
 * This program is distributed in the hope that it will be useful,       *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 * GNU General Public License for more details.                          *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *                                                                       *
 *************************************************************************/

/*
* Examples:
* 
* var s = $.bitmap_serialize('00010001001010110');
*   - returns 17:4iI
*
* var ds = $.bitmap_deserialize('17:4iI');
*   - returns 00010001001010110
*/

jQuery.bitmap_symbols = function() {

    const bs = [
        '0', '$', '2', '3', '4', '5', '6', '7',
        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v',

        'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D',
        'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
        'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
        'U', 'V', 'W', 'X', 'Y', 'Z', '@', '1'
    ];

    return bs;
};

jQuery.bitmap_symbols_hash = function() {
    if (jQuery.bitmap_symbols_hash_built)
    	return jQuery.bitmap_symbols_hash_built;

    var bs = jQuery.bitmap_symbols();
       
    var bsh = {};
    for (var i = 0; i < bs.length; i++) {
        var s = bs[i];
        var octet = '';
        for(var num = i; num; num >>= 1) {
            if (num & 1) {
                octet = '1' + octet;
            } else {
                octet = '0' + octet;
            }
        }

        while(octet.length < 6) octet = '0' + octet;

        bsh[s] = octet;
    }

    jQuery.bitmap_symbols_hash_built = bsh;
    return bsh;
};

jQuery.bitmap_deserialize = function(sdata)
{
    function expand_octet(roctet) {
        var bsh = jQuery.bitmap_symbols_hash();

        if (bsh[roctet] == null)
            throw "Octet for '" + roctet + "' not found";
        return bsh[roctet];
    }


    sdata = String(sdata);
    if (sdata == '') return '';
    var items = /^(\d+):(.*)$/.exec(sdata);

    if (!items) throw "Internal error: incorrect serialized string: " + sdata;

    var len = items[1];
    sdata = items[2].split('');

    var res = '';
    for (var i = 0; i < sdata.length; i++) {
    	res += expand_octet(sdata[i]);
    }
    return res.substr(0, len);
}

jQuery.bitmap_serialize = function(data)
{
    function reduce_octet(octet)
    {
        var num = 0;
        var pow = 0;
        var s = octet.split('');
        var bs = jQuery.bitmap_symbols();

        while(s.length < 6) s[s.length] = '0';

        for (var i = s.length - 1; i >= 0; i--) {
            if (parseInt(s[i]) == 1) {
                num += (1 << pow);
            }
            pow++;
        }

        if (num < bs.length) return bs[num];
        throw "Internal error: octet is " + octet;
    }

    var result = '';
    data = String(data);

    if (!data.match(/^[01]*$/)) {
    	throw "line must contain only '0' or '1' symbols";
    }

    result += data.length + ':';

    while(data.length > 6) {
    	var str = data.substr(0, 6);
    	result += reduce_octet(str);
        data = data.substr(6);
    }

    if (data.length) {
    	result  += reduce_octet(data);
    }
    return result;
}
