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
const NUM_INDEX_FRAME	= 0;
const NUM_ACTION_FRAME	= 1;
const NUM_LIST_FRAME 	= 2;
const NUM_PROP_FRAME 	= 3;
const NUM_STATUS_FRAME 	= 4;

var idRefreshTimer;

$(document).ready(function(){
    // Panel buttons
    $('input.panel.add')			.bind('click', on_add);
    $('input.panel.delete')			.bind('click', function(){ call('delete')});
    $('input.panel.start')			.bind('click', function(){ call('start') });
    $('input.panel.pause')			.bind('click', function(){ call('pause') });
    $('input.panel.stop')			.bind('click', function(){ call('stop')	 });
    $('input.panel.check')			.bind('click', function(){ call('check') });
    $('input.panel.priority.off')   .bind('click', function(){ call('off')   });
    $('input.panel.priority.low')   .bind('click', function(){ call('low')   });
    $('input.panel.priority.normal').bind('click', function(){ call('normal')});
    $('input.panel.priority.high')  .bind('click', function(){ call('high')  });
    $('input.panel.refresh')		.bind('click', on_refresh);

    // Additional params
    $('#locale')					.bind('change', on_change_locale);
    $('#refresh')					.bind('change', on_change_refresh);
    $('#skin')						.bind('change', on_change_skin);

    // Start refresh timer
    $('#refresh').change();
});

/* Refresh frame by it`s number and send some command */
function refresh_frame( iFrame, strCommand )
{
    switch( iFrame )
    {
    case NUM_INDEX_FRAME:
        window.parent.document.location.reload(true);
        break;
    case NUM_ACTION_FRAME:
        window.parent.frames[ NUM_ACTION_FRAME ].document.location.reload(true);
        break;
    case NUM_LIST_FRAME:
        var objDoc = $(window.parent.frames[ NUM_LIST_FRAME ].document);
        // For few checked list send request as GET ////////////////////////////
        if( objDoc.find('#list table.list tbody > tr')
                .find('> td:first :checkbox:checked').length <= 64)
        {
            objDoc.find('#form').attr('method', 'get');
        }
        ////////////////////////////////////////////////////////////////////////
        objDoc.find('#do').val(strCommand);
        objDoc.find('#form').submit();
        break;
    case NUM_PROP_FRAME:
        var objDoc = $(window.parent.frames[ NUM_PROP_FRAME ].document);
        if( objDoc.find('#form').length )
        {
            // For few checked list send request as GET ////////////////////////
            if( objDoc.find('table.files tbody > tr')
                    .find('> td:first :checkbox:checked').length <= 256)
            {
                objDoc.find('#form').attr('method', 'get');
            }
            ////////////////////////////////////////////////////////////////////
            objDoc.find('#do').val(strCommand);
            objDoc.find('#form').submit();
        }
        else
        {
            window.parent.frames[ NUM_PROP_FRAME ].document
                .location.reload(true);
        }
        break;
    case NUM_STATUS_FRAME:
        window.parent.frames[ NUM_STATUS_FRAME ].document.location.reload(true);
        break;
    default:
        throw 'Undefined frame';
        break;
    }
}

function call( strCommand )
{
    // Check for command
    if(! strCommand.length ){ throw "Command not set"; }

    // Restart refresh timer
    $('#refresh').change();

    var objDocList = $(window.parent.frames[ NUM_LIST_FRAME ].document);

    // If some checkboxs selected then submit form
    if( objDocList.find('input[name="hash[]"]:checked').length ){
        refresh_frame(NUM_LIST_FRAME, 	strCommand);
        refresh_frame(NUM_ACTION_FRAME, 'refresh');
        refresh_frame(NUM_PROP_FRAME, 	'refresh');
    }
    else{
        // Get current torrent hash
        var objCurrent = objDocList.find('table.list tbody tr.selected');
        var objCheckbox = objCurrent.find('> td:first > input[type=checkbox]');
        // If have current selected torrent then send them
        if( objCheckbox.length ){
            refresh_frame(NUM_ACTION_FRAME, 'refresh');
            refresh_frame(NUM_PROP_FRAME, 	'refresh');
            window.parent.frames[ NUM_LIST_FRAME   ].document.location =
                'index.cgi?show=list' +
                '&do=' + strCommand +
                '&current=' + objCheckbox.val();
        }
        // If no selected torrents then alert about this
        else
        {
            alert(STR_NO_SELECTED);
        }
    }
}

function on_add()
{
    const WIDTH  = 640;
    const HEIGHT = 480;
    var iTop   = parseInt((screen.availHeight/2) - (HEIGHT/2));
    var iLeft  = parseInt((screen.availWidth/2) - (WIDTH/2));
    var retVal = window.showModalDialog('index.cgi?show=add', 'add',
        'resizable:yes;status:no;center:yes;unadorned:yes'  +
        ';dialogHeight:' + HEIGHT + ';dialogWidth:' + WIDTH +
        ';screenX:' + iLeft + ';left:' + iLeft + ';dialogLeft:' + iLeft +
        ';screenY:' + iTop  + ';top:'  + iTop  + ';dialogTop:'  + iTop
    );

    // If return TRUE then reftesh all frames
    if(retVal){
        refresh_frame(NUM_LIST_FRAME, 	'refresh');
        refresh_frame(NUM_ACTION_FRAME, 'refresh');
        refresh_frame(NUM_PROP_FRAME, 	'refresh');
    }
}

function on_refresh()
{
    // Update all frames
    refresh_frame(NUM_INDEX_FRAME, 'refresh');
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
                refresh_frame(NUM_LIST_FRAME, 	'refresh');
                refresh_frame(NUM_PROP_FRAME, 	'refresh');
                refresh_frame(NUM_STATUS_FRAME, 'refresh');
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
