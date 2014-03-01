#
#   meteo38.ru: exp
#

x = exports ? this

config = require '../lib/config'
#db     = require '../lib/db'
#lib    = require '../lib'

{debug, info, warn} = require '../lib/logger'

{fetch_data} = require '../app'


x.t_js = (req, res) ->
    res.header("Content-Type", "text/javascript")

    st = req.query.st or ""
    return res.send("") if not st

    res.header("Cache-Control", "no-cache, no-store, must-revalidate");
    res.header("Pragma", "no-cache");
    res.header("Expires", 0);

    st_list = [st]
    fetch_data(st_list, (data)-> 
        return res.send("") if not (last = data?[st]?.last)
        return res.send("") if not last.t or isNaN(last.t)

        t = Math.round(last.t)
        if t > 0
            clr = "#a40"
        else if t < 0
            clr = "#04d"
        else 
            clr = "#555"
        
        html = "<a href=\"http://meteo38.ru/\" style=\"color:#{clr};text-decoration:none;\">"+
                    (if t > 0 then "+"+t else ""+t)+"&deg;</a>"
        res.send """
            try{document.getElementById("meteo38_t_#{st}").innerHTML='#{html}';}catch(err){};
        """
    )
#-


#.