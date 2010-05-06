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
    // Select all subdirectories if click on folder checkbox
    $('table.files tbody.folder td.select :checkbox')
        .bind('click', on_folder_click);

    // Directories folding
    $('table.files tbody.folder td.path div.mime')
        .bind('click', on_mime_click);

    // On mass select checkbox click
    $('#all_files').bind('change', on_all_change);

    // Priority set
    $('input.inlays.priority.off')   .bind('click', function(){call('off')   });
    $('input.inlays.priority.normal').bind('click', function(){call('normal')});
    $('input.inlays.priority.high')  .bind('click', function(){call('high')  });

    // Selected save
    $('input[name="index[]"]')      .bind('change',function(){ bitmap() });
});

function on_folder_click()
{
    // Get current row
    var objCheckbox = $(this);
    var objTBody = objCheckbox.parents('tbody.folder');

    // Get corrent direcory level
    var reLevel = new RegExp("level(\\d+)");
    var iLevel  = objTBody.attr('class').match(reLevel)[1];

    // Select all subdirectories
    $.each($(objTBody).nextAll('tbody'), function(i, objRow){
        // Get row level
        var iRowLevel = $(objRow).attr('class').match(reLevel)[1];
        // If level <= current level then it`s not subdir and stop check
        if(iRowLevel <= iLevel ){ return false; }
        // Check subdir/subfile
        $(objRow).find('td.select :checkbox')
            .attr('checked', objCheckbox.attr('checked'));
    });
}

function on_mime_click()
{
    // Get current row
    var objDiv = $(this);
    var objTBody = objDiv.parents('tbody.folder');
    // Toggle folding
    objTBody.toggleClass('open');

    // Get corrent direcory level
    var reLevel = new RegExp("level(\\d+)");
    var iLevel  = objTBody.attr('class').match(reLevel)[1];

    // How/Hide all subdirectories
    $.each($(objTBody).nextAll('tbody'), function(i, objRow){
        // Get row level
        var iRowLevel = $(objRow).attr('class').match(reLevel)[1];
        // If level <= current level then it`s not subdir and stop check
        if(iRowLevel <= iLevel ){ return false; }
        // Check subdir/subfile
        (objTBody.hasClass('open'))
            ?$(objRow).removeClass('folded')
            :$(objRow).addClass('folded');
    });
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
    // Check for selected files
    if(! $('table.files').find('input[name="index[]"]:checked').length ){
        throw "Files not selected";
    }
    // Set priority and submit form
    $('#do').val(strCommand);
    $('#form').submit();
}

function on_all_change()
{
    // Get all state
    var boolChecked = $(this).attr('checked');
    // Save in coockie
    $.cookie('all_files', boolChecked, { expires: 730 });
    // Set all checkbox
    $.each(
        $('table.files tbody > tr').find('> td:first :checkbox'),
        function(index, objCheckbox){
            $(objCheckbox).attr('checked', boolChecked);
    });
}