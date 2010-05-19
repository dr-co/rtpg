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
    This file contain java scripts for Action frame
*/

const NUM_LIST_FRAME = 2;

$(document).ready(function(){
    $('#action tbody.item td.select :button').bind('click', on_click_action);
});

function on_click_action()
{
    // Highlight new option
    $('#action tbody.item').removeClass('selected');
    $(this).parent().parent().parent('tbody.item').addClass('selected');

    // Set new value
    $.cookie('action', $(this).attr('class'), { expires: 730 });

    // Update List frame with new params
    var objDocList = window.parent.frames[ NUM_LIST_FRAME ].document;
    objDocList.location = 'index.cgi?show=list&action=' + $(this).attr('class');
}