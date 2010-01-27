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

$(document).ready(function(){
    // On torrent select
    $('#list table.list tbody').bind('click', on_click_list);

    // Start timer
    setTimeout(
        function(){ $(document).location = 'list.cgi' },
        $.cookie('refresh') * 1000);
});

function on_click_list()
{
    // Set current selected
    $('#list table.list tbody').removeClass('selected');
    $(this).addClass('selected');

    // Update prop frame
    var objDocList = window.parent.frames[3].document;
    objDocList.location = 'prop.cgi?current=' +
                          $(this).find(':input[name="hash[]"]').val();
}
