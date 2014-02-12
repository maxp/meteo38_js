#
#   meteo38.ru: database module
#

x = exports ? this

config = require './config'
{debug, info, warn} = require './logger'
{MongoClient, ObjectID, Grid} = require 'mongodb'

db_conn = null

MongoClient.connect config.db.url, (err, db) ->
    if err
        warn "db.err:", err
        process.exit 1
    #
    info "db connected", db.databaseName
    #
    db_conn = db
    # indexes(db)
#-


#indexes = (db) ->
##-

# x.trace = (data) ->
#     db_conn.collection('trace').insert data, (err) -> warn "db.trace:", err if err
# #-

x.OID = x.ObjectID = ObjectID

x.db_conn = -> db_conn
x.coll = (collection_name) -> db_conn.collection(collection_name)

x.make_oid = make_oid = (id) -> 
    try
        return ObjectID(id)
    catch err
        return null
#-    

x.str_id = str_id = (id) -> 
    return null if not id
    return id if id instanceof ObjectID
    try
        return ObjectID(id)
    catch err
        return ""+id
#-    

x.coll_dat = () -> db_conn.collection("dat")
x.coll_st  = () -> db_conn.collection("st")

# x.next_seq = (name, cb) ->
#     db_conn.collection(SEQ).findAndModify(
#         {_id:name}, null, {$inc:{val:1}}, {upsert:true, new:1},
#         (err, data) -> 
#             if err
#                 warn "next_seq:", err
#                 cb(null)
#             else
#                 cb(data.val)
#     )
# #-  


#.
