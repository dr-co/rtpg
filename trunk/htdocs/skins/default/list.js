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

$(document).ready(function(){
    // On torrent select
    $('#list table.list tbody > tr').find('> td:gt(0)')
        .bind('click', on_click_list);

    // On mass select checkbox click
    $('#all').bind('change', on_all_change);

    // Add client side sorting
    $('#list table.list').tablesorter();
//    $('#list table.list').tableSort({
//        headRow: 0,
//        columns: {
//            1: { type: 'string', sorted: 'asc' },
//            2: { type: 'string' },
////            3: { type: 'string' },
//            4: { type: 'number'   },
//            5: { type: 'string' },
//            6: { type: 'string' },
////            7: { type: 'string' },
////            8: { type: 'string' },
//            9: { type: 'number' },
//        },
//        stripe: true,
//        classes: {
//            sorting:  'sorting',
//            sortable: 'sortable',
//            asc:      'asc',
//            desc:     'desc',
//            stripe:   'even'
//     }});
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