#
#   openirk.ru: obj
#

x = exports ? this

config = require '../lib/config'
db     = require '../lib/db'
lib    = require '../lib'

{debug, info, warn} = require '../lib/logger'

NOPIC_URL = "/inc/img/no_foto.png"


x.groups = (req, res) ->
    db.groups().find({type:req.params.type, ord:{$gte:0}}).sort([['ord',1],['title',1]])
        .toArray (err, data) ->
            if err
                warn "obj.groups", err
                res.json {err:"db", msg:"Ошибка базы данных!"}
            else
                res.json {ok:1, groups:data}
    #-
#-


x.list = (req, res) ->
    # TODO: dist, ct, ts, ll

    # , state:{$gt:0}
    
    db.objs().find({grp:req.query.grp})
        .sort({title:1}).limit(10000).toArray (err, data) ->
            if err
                warn "obj.list", err
                res.json {err:"db", msg:"Ошибка базы данных!"}
            else
                res.json {ok:1, objs:data}
#-


x.pic = (req, res) ->
    # TODO: verify obj_id, add expiration header, obj.pic[i]
    
    pic_id = db.make_oid req.query.pic_id
    return res.redirect(NOPIC_URL) if not pic_id

    db.pics_grid().get pic_id, (err, data) ->
        warn "obj/pic:", err if err
        return res.redirect(NOPIC_URL) if not data
        return res.set({
            "Content-Type": "image/jpeg",
            "Content-Length": data.length
        }).send(data)
    #
#-


#.