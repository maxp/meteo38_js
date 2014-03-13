#
#   meteo38.ru: main
#

config = require './lib/config'
lib = require './lib'
db = require './lib/db'

TRENDS_INTERVAL = 60*60*1000

moment = require 'moment'

# init logging and database
#
{debug, info, warn} = require './lib/logger'

{st_list_cleanup, fetch_sts, get_stlist, fetch_data} = require './app'

exp = require "./app/exp"


# db   = require './lib/db'
# sess = require './lib/sess'
# auth = require './app/auth'
# user = require './app/user'

#multipart = require 'connect-multiparty'
express = require 'express'

app = express()

#app.configure ->
app.set "views", __dirname      # +"/jade"
app.set "view engine", 'jade'

app.enable "trust proxy"

#app.use express.favicon(__dirname+'/inc/img/favicon.ico')

app.use express.compress()
app.use express.cookieParser()
# app.use sess.middleware()

# app.use express.urlencoded()
app.use express.json()

# app.use auth.middleware()
app.use app.router

if config.env is "development"
    app.use '/inc', express.static __dirname+"/inc"
    app.use express.errorHandler {dumpExceptions: true, showStack: true}
    app.locals.pretty = true
    app.locals.cache = false
else
    app.use '/inc', express.static __dirname+"/inc", {maxAge: 1*24*3600*1000}
    app.use express.errorHandler()
    app.locals.pretty = false
    app.locals.cache = true
#
#-

ST_LIST_COOKIE = "st_list"
ST_LIST_DEFAULT = [
    "irgp", "uiii", "rlux120", "iood", "sokr"
]

#ST_LIST_MAX    = 20

#
#   urls
#

app.get '/', (req, res) ->
    st_list = st_list_cleanup(req.cookies[ST_LIST_COOKIE])
    if not st_list.length
        st_list = ST_LIST_DEFAULT 
        # res.cookie ST_LIST_COOKIE, st_list, {expires: new Date("2101-01-01"), httponly: false}
    #
    fetch_sts( st_list, (data) ->
        res.render "app/main", {
            title: "Погода в Иркутске и области"
            st_list: st_list
            data: data
            hhmm: lib.hhmm(new Date())
            format_t: (last, trends) ->
                return "" if not last.t?
                t = Math.round(last.t)
                [cls,sign] = if t > 0 then ["pos","+"] else if t < 0 then ["neg","-"] else ["zer",""]
                t = -t if t < 0 

                tr = " &nbsp;"
                acls = ""
                if trends?.t
                    tts = new Date(trends.ts).getTime()
                    if tts > lib.now() - TRENDS_INTERVAL
                        if trends.t.last >= trends.t.avg + 1
                            tr = "&uarr;" 
                            acls = "pos"
                        if trends.t.last <= trends.t.avg - 1
                            tr = "&darr;" 
                            acls = "neg"
                    #
                #
                return " <span class='#{cls}'>#{sign}<i>#{t}</i></span>&deg;"+
                        "<span class='arr #{acls}'>#{tr}</span>"
        }
    )
#-

app.get '/st_list', (req, res) ->
    # ?filter by ll
    st_fav = st_list_cleanup(req.cookies[ST_LIST_COOKIE])
    get_stlist( (data) -> res.json {ok:1, st_fav:st_fav, st_list:data} )
#-

app.post '/st_favs', (req, res) ->
    favs = st_list_cleanup(req.body.favs)
    res.cookie ST_LIST_COOKIE, favs, {expires: new Date("2101-01-01"), httponly: false}
    res.json {ok:1, fav_num:favs.length}
#-

app.get '/st_data', (req, res) ->
    st_list = st_list_cleanup((req.query.st_list or "").split(','))
    return res.json({err:"badreq"}) if not st_list.length
    fetch_data( st_list, (data) -> 
        return res.json {ok:1, data:data, hhmm:lib.hhmm(new Date())} 
    )
#-


DAYNUM_MAX = 10

app.get '/st_graph', (req, res) ->
    # ?d=0, n=3, st[]=stid1&st[]=stid2
    st_list = st_list_cleanup((req.query.st_list or "").split(','))
    return res.json({err:"badreq",msg:"?d=0,n=3,st[]=..."}) if not st_list.length

    t1 = moment().set('hour', 0).set('minute', 0).set('second', 0).set('millisecond', 0)
    t1.add("days", lib.int(req.query.d) + 1)

    n = lib.int(req.query.n)
    n = DAYNUM_MAX if n > DAYNUM_MAX
    n = 1 if n < 1

    db.coll_dat().aggregate(
        [
            {$match:{
                st:{$in:st_list},
                ts:{
                    $gte: moment(t1).subtract("days", n).toDate()
                    $lt:  t1.toDate()
                }
            }},
            {$group:{
                _id:{
                    st:"$st",
                    y:{$year:"$ts"},
                    m:{$month:"$ts"},
                    d:{$dayOfMonth:"$ts"},
                    h:{$hour:"$ts"}                    
                },
                ts0: {$min:"$ts"},
                t_m:{$min:"$t"},
                t_x:{$max:"$t"},
                t_a:{$avg:"$t"},
                p_m:{$min:"$p"},
                p_x:{$max:"$p"},
                p_a:{$avg:"$p"},
                h_m:{$min:"$h"},
                h_x:{$max:"$h"},
                h_a:{$avg:"$h"},
                w_m:{$min:"$w"},
                w_a:{$avg:"$w"},
                w_x:{$max:"$g"}
            }},
            {$sort:{ts0:1}}
        ],
        (err, data) ->
            if err
                warn "st_graph:", err
                return res.json {err:"db"}
            #
            for d in data
                d.st = d._id.st
                delete d._id
                delete d.w_x if d.w_x is null
                for v in ['t','p','h','w']
                    if d[v+'_m'] is null
                        delete d[v+'_m']
                        delete d[v+'_x']
                        delete d[v+'_a']
                    #
                #
            #
            return res.json {ok:1, data:data}
    )
#-

app.get "/exp/t.js", exp.t_js
app.get "/exp/", (req, res) -> 
    get_stlist( (data) ->
        res.render "app/exp", {
            title: "Как установить информер на свой сайт"
            st_list: data
        }
    )
#-
    
app.get "/exp", (req, res) -> res.redirect "/exp/"

app.get "/help", (req, res) -> res.render("app/help", title: "Вопросы и ответы")

# app.get "/ico", (req, res) -> res.render "app/ico"

app.get '/favicon.ico', express.static(__dirname+'/inc/img')

app.get '/yandex_6f489466c2955c1a.txt', (req, res) -> res.send "ok"
app.get '/google527c56f2996a48ae.html', (req, res) -> 
    res.send "google-site-verification: google527c56f2996a48ae.html"
#



# app.all "/_trace", (req, res) ->
#     t = {ips: req.ips, ua: req.headers['user-agent'] or "?"}
#     if req.sess
#         lib.set_if t, 'sid', req.sess.sid
#         lib.set_if t, 'uid', req.sess.get("user_id")
#         lib.set_if t, 'login', req.sess.get("user_login")
#     #
#     lib.set_if t, 'param', req.body
#     info "trace", t
#     res.send 204, ""
#     t.ts = new Date()
#     db.trace(t)
# #-

info "Listen - "+config.server.host+":"+config.server.port
app.listen config.server.port, config.server.host

lib.watch_file __filename

#.   