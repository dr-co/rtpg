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

    // On checkbox select add hash to list in cookies
    $('#list table.list tbody > tr').find('> td:first :checkbox')
        .bind('change', on_click_checkbox);

    // On mass select checkbox click
    $('#all').bind('change', on_all_change);
});

function on_click_list()
{
    // Set current selected
    $('#list table.list tbody').removeClass('selected');
    $(this).parents('tbody:first').addClass('selected');

    // Set new current in cookie
    var strCurrent =
        $(this).parents('tbody:first').find(':input[name="hash[]"]').val();
    $.cookie('current', strCurrent, { expires: 730 });

    // Update prop frame
    $.cookie('filelist', '');
    var objDocList = window.parent.frames[ NUM_PROP_FRAME ].document;
    objDocList.location = 'prop.cgi?current=' + strCurrent;

}

function on_click_checkbox()
{
//    var arrChecked = new Array();
//    arrChecked = $.map(
//        $('#list table.list tbody > tr').find('> td:first :checkbox'),
//        function(objCheckbox){ return (objCheckbox.attr('checked')) ?1 :0; });
//    // Get cookie sting and slip it to array
//    var strCookie = new String( $.cookie('checked') || '' );
//    var arrChecked;
//    if( strCookie == '' ){ arrChecked = new Array(); }
//    else { arrChecked = strCookie.split(';'); }
//
//    if( $(this).attr('checked') )
//    {
//        // Add hash to array
//        arrChecked.push( $(this).val() );
//    }
//    else
//    {
//        // Remove hash from array
//        arrChecked.splice( $.inArray($(this).val(), arrChecked), 1);
//    }
//
    // Set new cookie value
//    $.cookie(
//        'checked',
//        $.cookie('action') + ':' + arrChecked.join(''),
//        { expires: 730 } );
}

function on_all_change()
{
    // Get all state
    var strChecked = $(this).attr('checked');
    // Seve in cookie
    $.cookie('all', strChecked, { expires: 730 });
    // Set all checkbox
    $.each($('#list table.list tbody > tr').find('> td:first :checkbox'),
        function(index, objCheckbox){
//            if((strChecked == 'true'  && $(objCheckbox).attr('checked') == 'false') ||
//               (strChecked == 'false' && $(objCheckbox).attr('checked') == 'true')){
//                $(objCheckbox).attr('checked', true);
//            }
    });
}