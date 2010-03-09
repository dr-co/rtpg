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
const NUM_PROP_FRAME = 3;
const NUM_STATUS_FRAME = 4;

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
    $('#locale')					.bind('change', on_change_locale);
    $('#refresh')					.bind('change', on_change_refresh);
    $('#skin')						.bind('change', on_change_skin);

    // Start refresh timer
    $('#refresh').change();
});

/*
 * Get selection list. First time try to get all checked rows and return sting
 * of hash concatination. If no, try to get current torrent hash.
 * Return empty string if no selection.
*/
function get_selections()
{
    var arrSelected = new Array();
    var objDocList = window.parent.frames[ NUM_LIST_FRAME ].document;

    // Get checked torrents hash
    $.each($(objDocList).find('table.list tbody'), function(i, objTboby){
        var objCheckbox = $(objTboby).find('> tr:first > td:first > input:checked');
        if( !objCheckbox.length ){ return; }
        arrSelected.push( objCheckbox.val() );
    });
    // Return checked
    if(arrSelected.length){ return arrSelected.join(','); }

    // Get current torrent hash
    var objCurrent = $(objDocList).find('table.list tbody.selected');
    var objCheckbox = $(objCurrent).find('> tr:first > td:first > input[type=checkbox]');
    if( objCheckbox.length ){ arrSelected.push( objCheckbox.val() ); }
    // Return current
    if(arrSelected.length) return arrSelected[0];

    // Nothing
    return new String('');
}

function on_delete()
{
    // Restart refresh timer
    $('#refresh').change();

    // Get selected
    var strSelected = new String( get_selections() );
    if( ! strSelected.length ){ alert( NO_SELECTED ); return; }

    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?delete=' + strSelected;
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_start()
{
    // Restart refresh timer
    $('#refresh').change();

    // Get selected
    var strSelected = new String( get_selections() );
    if( ! strSelected.length ){ alert( NO_SELECTED ); return; }

    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?start=' + strSelected;
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_pause()
{
    // Restart refresh timer
    $('#refresh').change();

    // Get selected
    var strSelected = new String( get_selections() );
    if( ! strSelected.length ){ alert( NO_SELECTED ); return; }

    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?pause=' + strSelected;
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_stop()
{
    // Restart refresh timer
    $('#refresh').change();

    // Get selected
    var strSelected = new String( get_selections() );
    if( ! strSelected.length ){ alert( NO_SELECTED ); return; }

    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?stop=' + strSelected;
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_priority_up()
{
    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?priority_up=' + $.cookie('current');
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_priority_down()
{
    // Update frames
    window.parent.frames[ NUM_LIST_FRAME ].document.location =
        'list.cgi?priority_down=' + $.cookie('current');
    window.parent.frames[ NUM_PROP_FRAME ].document.location = 'prop.cgi';
}

function on_refresh()
{
    // Update all windows
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
                window.parent.frames[ NUM_LIST_FRAME ].document
                    .location = 'list.cgi';
                window.parent.frames[ NUM_PROP_FRAME ].document
                    .location = 'prop.cgi';
                window.parent.frames[ NUM_STATUS_FRAME ].document
                    .location = 'status.cgi';
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