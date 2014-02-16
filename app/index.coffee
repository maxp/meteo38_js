#
#   meteo38.ru: application logic
#

x = exports ? this

ST_LIST_MAX    = 20
ST_ID_MAX_LEN  = 64

{isArray} = require 'util'

# config = require '../lib/config'
db     = require '../lib/db'
lib    = require '../lib'

{debug, info, warn} = require '../lib/logger'


x.st_list_cleanup = (s) ->
    return [] if not s?.length
    s = (""+s).split(',').slice(0, ST_LIST_MAX)
    return (t.replace(/[^0-9a-zA-Z\-_]/g,'').substring(0, ST_ID_MAX_LEN) for t in s)
#-


x.fetch_sts = (st_list, cb) ->
    db.coll_st().find(
            {_id:{$in:st_list}, pub:1},
            {_id:1,title:1,last:1,descr:1,addr:1,ll:1,trends:1} 
        ).sort({title:1}).toArray (err, data) ->
            if err
                warn "app.fetch_sts:", err
                return cb([])
            #
            cb(data)
    #-
#-



#.