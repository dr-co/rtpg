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

$(document).ready(function(){
    $('table.files tbody.folder td.select :checkbox')
        .bind('click', on_folder_click);
});

function on_folder_click()
{
//    var objCheckbox = $(this);
//    var objTBody = objCheckbox.parents('tbody.folder');
//    var arrTBody = $(objTBody).next('tbody.folder');
//
//    alert(arrTBody.length);
//
//    $.each(arrTBody, function(i, obj){
//
//        $(obj).find('td.select :checkbox')
//            .attr('checked', objCheckbox.attr('checked'));
//    });
}