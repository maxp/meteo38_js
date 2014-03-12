#
#   meteo38.ru: application logic
#

x = exports ? this

ST_LIST_MAX    = 30
ST_ID_MAX_LEN  = 64

ST_FRESH = 7 * 24*3600*1000    # last refresh interval
DATA_FRESH = 2 * 3600*1000

{isArray} = require 'util'

# config = require '../lib/config'
db     = require '../lib/db'
lib    = require '../lib'

{debug, info, warn} = require '../lib/logger'


x.st_list_cleanup = (s) ->
    return [] if not s?.length
    s = (""+s).split(',').slice(0, ST_LIST_MAX)
    res = (t.replace(/[^0-9a-zA-Z\-_]/g,'').substring(0, ST_ID_MAX_LEN) for t in s)
    return (s for s in res when s)
#-


x.fetch_sts = (st_list, cb) ->
    res = {}
    db.coll_st().find(
            {_id:{$in:st_list}, pub:1, ts:{$gte:new Date(lib.now()-DATA_FRESH)}},
            {_id:1,title:1,last:1,descr:1,addr:1,ll:1,trends:1} 
        ).each (err, item) ->
            warn "app.fetch_sts:", err if err
            return cb(res) if not item
            res[item._id] = item
    #-
#-

x.fetch_data = (st_list, cb) ->
    res = {}
    db.coll_st().find(
            {_id:{$in:st_list},pub:1,ts:{$gte:new Date(lib.now()-DATA_FRESH)}},
            {_id:1,last:1,trends:1} 
        ).each (err, item) ->
            warn "app.fetch_data:", err if err
            return cb(res) if not item
            res[item._id] = item
    #-
#-


x.get_stlist = (cb) ->
    fresh = lib.now() - ST_FRESH
    db.coll_st().find(
            {pub:1, ts:{$gte: new Date(fresh)}}
            {_id:1,title:1,addr:1,descr:1,ll:1}
        ).sort({title:1}).toArray (err, data) ->
            if err 
                warn "app.st_list:", err
                return cb([])
            #
            cb(data)
    #-
#-


#.