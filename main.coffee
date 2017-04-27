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

body_parser = require 'body-parser'
compress = require 'compression'
cookie_parser = require 'cookie-parser'
error_handler = require 'errorhandler'
serve_static = require 'serve-static'
#multipart = require 'connect-multiparty'

express = require 'express'
app = express()

app.set "views", __dirname      # +"/jade"
app.set "view engine", 'jade'

app.enable "trust proxy"

app.use compress()
app.use cookie_parser()
app.use body_parser({limit:10*1024*1024})


# app.use sess.middleware()
# app.use auth.middleware()

# app.use app.router

if config.env is "development"
    app.use '/inc', serve_static(__dirname+"/inc")
    app.use error_handler {dumpExceptions: true, showStack: true}
    app.locals.pretty = true
    app.locals.cache = false
else
    app.use '/inc', serve_static(__dirname+"/inc", {maxAge: 1*24*3600*1000})
    app.use error_handler()
    app.locals.pretty = false
    app.locals.cache = true
#
#-

ST_LIST_COOKIE = "st_list"
ST_LIST_DEFAULT = [
  "asbtv", "irgp", "npsd", "uiii", "basenet", "zbereg", "soln", "irk2",
  "olha", "lin_baik", "lin_list", "khomutovo"
]

#ST_LIST_MAX    = 20

#
#   urls
#

HPA_MMHG = 1.3332239

wind_nesw = (b) ->
    return "" if b >= 360 or b < 0
    return ["С","СВ","В","ЮВ","Ю","ЮЗ","З","СЗ"][(Math.floor((b+22)/45)) % 8]
#-


app.get '/', (req, res) ->
    console.log "req:", req
    st_list = st_list_cleanup(req.params?.st_list)
    console.log "st_list_p:", st_list
    st_list = st_list_cleanup(req.cookies[ST_LIST_COOKIE]) if not st_list.length
    console.log "st_list_q:", st_list
    st_list = ST_LIST_DEFAULT if not st_list.length
    #
    fetch_sts( st_list, (data) ->
        res.render "app/main", {
            title: "Погода в Иркутске и области"
            st_list: st_list
            data: data
            hhmm: lib.hhmm(new Date())

            # code duplicated in inc/front.coffee
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
            format_p: (last) ->
                p = (Math.round(last.p/HPA_MMHG)+" мм" if last.p?) or ""
                h = (Math.round(last.h)+"%" if last.h?) or ""
                return if p and h then p+", "+h else p+h
            #-
            format_w: (last) ->
                if last.w? or last.g?
                    s = if last.w? then ""+Math.round(last.w) else ""
                    if last.g? and (Math.round(last.g) > Math.round(last.w))
                        s += "-" if s
                        s += Math.round(last.g)
                    #-
                    s += " м/с" if s
                    if last.b? and (Math.round(last.w) > 0)
                        d = wind_nesw(Math.round(last.b))
                        s += ", "+d if d
                    return s
                else
                    return ""
            #-
        }
    )
#-

app.get "/opts", (req, res) ->
    fav_ids = st_list_cleanup(req.cookies[ST_LIST_COOKIE])
    get_stlist( (data) ->
        st_f = {}
        st_n = []
        for st in data
            if st._id in fav_ids
                st_f[st._id] = st
            else
                st_n.push(st)
        #
        res.render "app/opts", {fav_ids:fav_ids, st_f:st_f, st_n:st_n}
    )
#-

# deprecated
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
    # ?d=0, n=3, st=stid
    st = lib.str(req.query.st)
    return res.json({err:"badreq",msg:"?d=0,n=3,st=..."}) if not st

    t1 = moment().set('hour', 0).set('minute', 0).set('second', 0).set('millisecond', 0)
    t1.add("days", lib.int(req.query.d) + 1)

    n = lib.int(req.query.n)
    n = DAYNUM_MAX if n > DAYNUM_MAX
    n = 1 if n < 1

    t0 = moment(t1).subtract("days", n)

    db.coll_dat().aggregate(
        [
            {$match:{st:st, ts:{$gte:t0.toDate(), $lt:t1.toDate()}}},
            {$group:{
                _id:{
                    y:{$year:"$ts"},
                    m:{$month:"$ts"},
                    d:{$dayOfMonth:"$ts"},
                    h:{$hour:"$ts"}
                },
                ts0:{$min:"$ts"},
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
            return res.json {ok:1, st:st, data:data}
    )
#-



# app.get '/st_graph', (req, res) ->
#     # ?d=0, n=3, st[]=stid1, st[]=stid2
#     st_list = st_list_cleanup(req.query.st)
#     return res.json({err:"badreq",msg:"?d=0,n=3,st[]=..."}) if not st_list.length

#     t1 = moment().set('hour', 0).set('minute', 0).set('second', 0).set('millisecond', 0)
#     t1.add("days", lib.int(req.query.d) + 1)

#     n = lib.int(req.query.n)
#     n = DAYNUM_MAX if n > DAYNUM_MAX
#     n = 1 if n < 1

#     db.coll_dat().aggregate(
#         [
#             {$match:{
#                 st:{$in:st_list},
#                 ts:{
#                     $gte: moment(t1).subtract("days", n).toDate()
#                     $lt:  t1.toDate()
#                 }
#             }},
#             {$group:{
#                 _id:{
#                     st:"$st",
#                     y:{$year:"$ts"},
#                     m:{$month:"$ts"},
#                     d:{$dayOfMonth:"$ts"},
#                     h:{$hour:"$ts"}
#                 },
#                 ts0:{$min:"$ts"},
#                 t_m:{$min:"$t"},
#                 t_x:{$max:"$t"},
#                 t_a:{$avg:"$t"},
#                 p_m:{$min:"$p"},
#                 p_x:{$max:"$p"},
#                 p_a:{$avg:"$p"},
#                 h_m:{$min:"$h"},
#                 h_x:{$max:"$h"},
#                 h_a:{$avg:"$h"},
#                 w_m:{$min:"$w"},
#                 w_a:{$avg:"$w"},
#                 w_x:{$max:"$g"}
#             }},
#             {$sort:{ts0:1}}
#         ],
#         (err, data) ->
#             if err
#                 warn "st_graph:", err
#                 return res.json {err:"db"}
#             #
#             for d in data
#                 d.st = d._id.st
#                 delete d._id
#                 delete d.w_x if d.w_x is null
#                 for v in ['t','p','h','w']
#                     if d[v+'_m'] is null
#                         delete d[v+'_m']
#                         delete d[v+'_x']
#                         delete d[v+'_a']
#                     #
#                 #
#             #
#             return res.json {ok:1, data:data}
#     )
# #-

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

app.get "/help", (req, res) -> res.render("app/help", title:"Вопросы и ответы")

# app.get "/ico", (req, res) -> res.render "app/ico"

app.get '/favicon.ico', serve_static(__dirname+'/inc/img', {maxAge: 30 * 24*3600*1000})

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
