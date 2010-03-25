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

function call( strCommand )
{
    // Check for command
    if(! strCommand.length ){ throw "Command not set"; }

    // Restart refresh timer
    $('#refresh').change();

    var objDocList = $(window.parent.frames[ NUM_LIST_FRAME ].document);

    // If some checkboxs selected then submit form
    if( objDocList.find('input[name="hash[]"]:checked').length ){
        objDocList.find('#do').val(strCommand);
        objDocList.find('#form').submit();

        window.parent.frames[ NUM_ACTION_FRAME ].document.location.reload(true);
        window.parent.frames[ NUM_PROP_FRAME   ].document.location.reload(true);
    }
    else{
        // Get current torrent hash
        var objCurrent = objDocList.find('table.list tbody.selected');
        var objCheckbox = objCurrent.find('> tr:first > td:first > input[type=checkbox]');
        // If have current selected torrent then send them
        if( objCheckbox.length ){
            window.parent.frames[ NUM_ACTION_FRAME ].document.location.reload(true);
            window.parent.frames[ NUM_PROP_FRAME   ].document.location.reload(true);
            window.parent.frames[ NUM_LIST_FRAME   ].document.location =
                'list.cgi?do=' + strCommand + '&current=' + objCheckbox.val();
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
    const HEIGHT = 320;
    var iTop   = parseInt((screen.availHeight/2) - (HEIGHT/2));
    var iLeft  = parseInt((screen.availWidth/2) - (WIDTH/2));
    var retVal = window.showModalDialog('add.cgi', 'add',
        ',toolbar=0,location=0,directories=0,status=0,menubar=0,copyhistory=0' +
        ',width='+ WIDTH +',height='+ HEIGHT +
        ',left='+ iLeft +',top='+ iTop +',screenX='+ iLeft +',screenY='+ iTop);

    // If return TRUE then reftesh all frames
    if(retVal){
        window.parent.frames[ NUM_ACTION_FRAME ].document
            .location.reload(true);
        window.parent.frames[ NUM_LIST_FRAME   ].document
            .location.reload(true);
        window.parent.frames[ NUM_PROP_FRAME   ].document
            .location.reload(true);
    }
}

function on_refresh()
{
    // Update all frames
    window.parent.document.location = 'index.cgi';
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
                window.parent.frames[ NUM_LIST_FRAME   ].document
                    .location.reload(true);
                window.parent.frames[ NUM_PROP_FRAME   ].document
                    .location.reload(true);
                window.parent.frames[ NUM_STATUS_FRAME ].document
                    .location.reload(true);
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