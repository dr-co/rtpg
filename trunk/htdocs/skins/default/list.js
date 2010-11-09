/*

AUTHORS

 Copyright (C) 2010 Dmitry E. Oboukhov <unera@debian.org>
 Copyright (C) 2010 Roman V. Nikolaev <rshadow@rambler.ru>

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

/* This file contain java scripts for List frame */
var m = 0;
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
            1: { sorter: 'text' 	},
            2: { sorter: 'text' 	},
            3: { sorter: false 		},
            4: { sorter: false 		},
            5: { sorter: 'text' 	},
            6: { sorter: 'digit' 	},
            7: { sortet: 'procent'	},
            8: { sorter: 'text' 	},
            9: { sorter: 'digit' 	},
           10: { sorter: 'digit' 	},
           11: { sorter: 'digit' 	},
           12: { sorter: 'digit' 	},
        },
        cssAsc:  		'asc',
        cssDesc: 		'desc',
        cssHeader: 		'sortable',
//        sortList:		[[1,0]],
        widgets: 		['zebra'],
        textExtraction: function( objTd )
        {
            return $(objTd).find('span.data').text() || $(objTd).text();
        }
    });
});

function on_click_list()
{
    // Check for double click. Need late.
    var bDouble = false;
    if( $(this).parents('tr:first').hasClass('selected') ){ bDouble = true; }

    // Set current selected
    $('#list table.list tbody tr').removeClass('selected');
    $(this).parents('tr:first').addClass('selected');

    // Set new current in cookie
    var strCurrent =
        $(this).parents('tr:first').find(':input[name="hash[]"]').val();
    $.cookie('current', strCurrent, { expires: 730 });

    // On double click show prop frame
    if( bDouble )
    {
        var objPanel  = $(window.parent.frames['frm_panel'].document);
        var objLayout = objPanel.find('#layout');
        switch( objLayout.val() )
        {
            case 'default'  :
            case 'list_prop':
                break;
            case 'act_list' :
                $.cookie('layout', 'default', { expires: 730 });
                window.parent.document.location = 'index.cgi?layout=default';
                break;
            case 'list'     :
                $.cookie('layout', 'list_prop', { expires: 730 });
                window.parent.document.location = 'index.cgi?layout=list_prop';
                break;
        }

// Now this good code don`t work becouse jquery bug.
//        switch( objLayout.val() )
//        {
//            case 'default'  :
//            case 'list_prop':                                       break;
//            case 'act_list' :  objLayout.val('default').change();   break;
//            case 'list'     :  objLayout.val('list_prop').change(); break;
//        }
    }

    // Update prop frame if exists
    if( window.parent.frames['frm_prop'] )
    {
        window.parent.frames['frm_prop'].location =
            'index.cgi?show=prop&current=' + strCurrent;
    }
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
