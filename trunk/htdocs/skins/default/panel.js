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

var idRefreshTimer;

$(document).ready(function(){
    // Panel buttons
    $('input.panel.delete')			.bind('click', on_delete);
    $('input.panel.start')			.bind('click', on_start);
    $('input.panel.pause')			.bind('click', on_pause);
    $('input.panel.stop')			.bind('click', on_stop);
    $('input.panel.priority_up')	.bind('click', on_priority_up);
    $('input.panel.priority_down')	.bind('click', on_priority_down);
    $('input.panel.refresh')		.bind('click', on_refresh);

    // Additional params
    $('#download_rate')				.bind('change', on_change_download_rate);
    $('#upload_rate')				.bind('change', on_change_upload_rate);
    $('#locale')					.bind('change', on_change_locale);
    $('#refresh')					.bind('change', on_change_refresh);
    $('#skin')						.bind('change', on_change_skin);

    // Start refresh timer
    $('#refresh').change();
});

function on_delete()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;
    objDocList.location = 'list.cgi?delete=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_start()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;
    objDocList.location = 'list.cgi?start=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_pause()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;
    objDocList.location = 'list.cgi?pause=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_stop()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;

    $.each($(objDocList).find('table.list tbody tr'), function(i, objTr){
        alert($(objTr).find('td:first > :selected').val());
        var objCheckbox = $(objTr).find('td:first > :selected');
        if( !objCheckbox.length ){ return; }
        alert( objCheckbox.val() );
    });

//    var arrSelected = $(objDocList).find('table.list tbody tr td:first :selected');
//    $.each(arrSelected, function(i, objCheckbox){
//        objCheckbox = 'stop=' + objCheckbox.val();
//    });
//    var strQuery = '?' + arrSelected.join('&');
//    alert('query:' + strQuery + ' arr:' + arrSelected.length);
//    objDocList.location = 'list.cgi?stop=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_priority_up()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;
    objDocList.location = 'list.cgi?priority_up=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_priority_down()
{
    // Update frames
    var objDocList = window.parent.frames[2].document;
    objDocList.location = 'list.cgi?priority_down=' + $.cookie('current');
    var objDocProp = window.parent.frames[3].document;
    objDocProp.location = 'prop.cgi';
}

function on_refresh()
{
    // Update all windows
    window.parent.document.location = 'index.cgi';
}


function on_change_download_rate()
{
    // Set new value
    $.cookie('download_rate', $(this).val(), { expires: 730 });
    // Update window with new locale
    window.parent.document.location = 'status.cgi?download_rate=' + $(this).val();
}

function on_change_upload_rate()
{
    // Set new value
    $.cookie('upload_rate', $(this).val(), { expires: 730 });
    // Update window with new locale
    window.parent.document.location = 'status.cgi?upload_rate=' + $(this).val();
}



function on_change_locale()
{
    // Set new value
    $.cookie('locale', $(this).val(), { expires: 730 });
    // Update window with new locale
    window.parent.document.location = 'index.cgi?locale=' + $(this).val();
}

function on_change_refresh()
{
    // Set new timeout
    $.cookie('refresh', $(this).val(), { expires: 730 });

    // Clear interval if it already started
    if( idRefreshTimer ) { clearInterval(idRefreshTimer); }

    // Start refresh timer if refresh time selected
    if( $(this).val() != 0 )
    {
        idRefreshTimer = setInterval(
            function(){
                var objDocList = window.parent.frames[2].document;
                objDocList.location = 'list.cgi';
                var objDocProp = window.parent.frames[3].document;
                objDocProp.location = 'prop.cgi';
            },
            ($(this).val() || 60 ) * 1000 );
    }
}

function on_change_skin()
{
    // Set new value
    $.cookie('skin', $(this).val(), { expires: 730 });
    // Update window with new skin
    window.parent.document.location = 'index.cgi?skin=' + $(this).val();
}