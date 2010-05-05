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
    // Show new prop page
    $('div.inlays div.item')        .bind('click', on_prop);

    $('input.panel.priority.off')   .bind('click', function(){ call('off')   });
    $('input.panel.priority.low')   .bind('click', function(){ call('low')   });
    $('input.panel.priority.normal').bind('click', function(){ call('normal')});
    $('input.panel.priority.high')  .bind('click', function(){ call('high')  });

    $('input[name="index[]"]')      .bind('change',function(){ bitmap() });
});

function on_prop()
{
    // Set new value
    $.cookie('prop', $(this).attr('id'), { expires: 730 });

    // Update window with new locale
    document.location = 'prop.cgi?prop=' + $(this).attr('id');
}

function bitmap()
{
    // Get bitmap array
    var arrResult = $('input[name="index[]"]');
    arrResult = $.map( $('input[name="index[]"]'), function(obj, i){
        if( $(obj).attr('checked') ){ return 1; }
        return 0;
    });

    // Save compressed bitmap in cookie
    $.cookie('filelist',
        $.bitmap_serialize(arrResult.join('')),
        { expires: 730 });
}

function call( strCommand )
{
    // Check for command
    if(! strCommand.length ){ throw "Command not set"; }

    if(! $('table.files input[name="index[]"]:checked').length ){
        throw "Files not selected";
    }

    document.location = 'prop.cgi?do=' + strCommand;
}