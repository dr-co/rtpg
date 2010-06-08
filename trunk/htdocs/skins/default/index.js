/*

AUTHORS

 Copyright (C) 2010 Dmitry E. Oboukhov <unera@debian.org>
 Copyright (C) 2010 Roman V. Nikolaev <rshadow@rambler.ru>

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

/* This file contain java scripts for frameset */

// Global frameset links
var frmsMiddle;
var frmsContent;

$(document).ready(function(){
    // Set global links
    frmsMiddle 	= $('#frms_middle');
    frmsContent	= $('#frms_content');

    // Restore frames positions
    frmsMiddle.attr('cols',  $.cookie('horizontal') || frmsMiddle.attr('cols'));
    frmsContent.attr('rows', $.cookie('vertical')   || frmsContent.attr('rows'));

    // Save frame position on resize
    $(window[2]).bind('resize', function(){
        $.cookie('horizontal', frmsMiddle.attr('cols'),  { expires: 730 });
        $.cookie('vertical',   frmsContent.attr('rows'), { expires: 730 });
    });
});
