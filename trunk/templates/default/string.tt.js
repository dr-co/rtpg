/*
 * Translates for strings
 *
 */

[% FOR string IN data.info %]
const [% string.key %] = "[% string.value | html %]";
[% END %]
