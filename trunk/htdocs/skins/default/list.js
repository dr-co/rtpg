/*

AUTHORS

 Copyright (C) 2010 Dmitry E. Oboukhov <unera@debian.org>
 Copyright (C) 2010 Nikolaev Roman <rshadow@rambler.ru>

LICENSE

This program is free software: you can redistribute  it  and/or  modify  it
under the terms of the GNU General Public License as published by the  Free
Software Foundation, either version 3 of the License, or (at  your  option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even  the  implied  warranty  of  MERCHANTABILITY  or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public  License  for
more details.

You should have received a copy of the GNU  General  Public  License  along
with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
    This file contain java scripts for List frame
*/

const NUM_PROP_FRAME = 3;

var fExtractor = function( objTd )
{
    var vReturn  = '';
    var strClass = $(objTd).attr('class');

    // Because we use colspan, shift column data
    switch( strClass )
    {
    case 'img':
        vReturn = $(objTd).siblings('td.name').text();
        break;
    case 'name':
        vReturn = $(objTd).siblings('td.num').text();
        break;
    case 'message':
        vReturn = $(objTd).siblings('td.size').find('span.data').text();
        break;
    case 'num':
        vReturn = $(objTd).siblings('td.done').text();
        break;
    case 'size':
        vReturn = $(objTd).siblings('td.status').text();
        break;
    case 'done':
        vReturn = $(objTd).siblings('td.peers').text();
        break;
    case 'status':
        vReturn = $(objTd).siblings('td.down_speed').find('span.data').text();
        break;
    case 'peers':
        vReturn = $(objTd).siblings('td.up_speed').find('span.data').text();
        break;
    case 'down_speed':
        vReturn = $(objTd).siblings('td.rate').text();
        break;
    default:
        vReturn = '';
        break;
    }

    return vReturn;
}

$(document).ready(function(){
    // On torrent select
    $('#list table.list tbody > tr').find('> td:gt(0)')
        .bind('click', on_click_list);

    // On mass select checkbox click
    $('#all').bind('change', on_all_change);

    // Add client side sorting
    $('#list table.list').tablesorter({
//        debug: true,
        headers: {
            0: { sorter: false 		},
//            1: { sorter: 'text' 		},
//            2: { sorter: 'text' 		},
            3: { sorter: 'digit' 	},
//            4: { sortet: 'procent'	},
//            5: { sorter: 'text' 		},
//            6: { sorter: 'digit' 	},
            7: { sorter: 'digit' 	},
            8: { sorter: 'digit' 	},
//            9: { sorter: 'digit' 	},
        },
        cssAsc:  		'asc',
        cssDesc: 		'desc',
        cssHeader: 		'sortable',
        widgets: 		['zebra'],
        textExtraction: fExtractor
    });
});

function on_click_list()
{
    // Set current selected
    $('#list table.list tbody tr').removeClass('selected');
    $(this).parents('tr:first').addClass('selected');

    // Set new current in cookie
    var strCurrent =
        $(this).parents('tr:first').find(':input[name="hash[]"]').val();
    $.cookie('current', strCurrent, { expires: 730 });

    // Update prop frame
    $.cookie('filelist', '');
    var objDocList = window.parent.frames[ NUM_PROP_FRAME ].document;
    objDocList.location = 'index.cgi?show=prop&current=' + strCurrent;

}

function on_all_change()
{
    // Get all state
    var boolChecked = $(this).attr('checked');
    // Save in coockie
    $.cookie('all', boolChecked, { expires: 730 });
    // Set all checkbox
    $.each(
        $('#list table.list tbody > tr').find('> td:first :checkbox'),
        function(index, objCheckbox){
            $(objCheckbox).attr('checked', boolChecked);
    });
}