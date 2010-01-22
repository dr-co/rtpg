/*
 * save_cookie - save new param in cookies.
 * 	name 	- param name
 * 	value 	- new param value
 */
function save_cookie(name, value)
{
    var exp = new Date();
    exp.setTime(exp.getTime() + 5*360*24*3600*1000);
    document.cookie = name+'='+escape(value) +
        '; expires='+exp.toGMTString() +
        '; path=/';
}