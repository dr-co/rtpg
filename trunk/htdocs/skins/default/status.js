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
    // Additional params
    $('#download_rate')				.bind('change', on_change_download_rate);
    $('#upload_rate')				.bind('change', on_change_upload_rate);
});

function on_change_download_rate()
{
    // Update window with new locale
    window.document.location =
        'index.cgi?show=status&download_rate=' + $(this).val();
}

function on_change_upload_rate()
{
    // Update window with new locale
    window.document.location =
        'index.cgi?show=status&upload_rate=' + $(this).val();
}
