#
#   angara-bb: sess
#

x = exports ? this

SESS_COLLECTION = 'sess'

SESS_COOKIE =  "sid"
SESS_MAXAGE = 365*24*3600*1000

SESS_IPS   = "ips"
SESS_TS    = "ts"
SESS_TMP   = "tmp"

NONCE_LENGTH = 10

util = require '../lib/util'
{debug, info, warn} = require '../lib/logger'
db = require '../lib/db'

make_sid = ->
  # hex_timestamp.random_hex
  (new Date()).getTime().toString(16)+"."+(
    (('0'+i.toString(16)).slice(-2) for i in util.urandom(NONCE_LENGTH)).join(''))
#-

class Sess
  constructor: (id, dat) ->
    @sid = id
    @data = dat
    @mk = null      # modified keys
    @fixed = false  # session saved, no changes allowed
  #-

  new_sid: ->
    @sid = make_sid()

  get: (key, defval) ->
    @data[key] ? defval
  #-

  set: (key, val) ->
    if @fixed
      warn "sess.set failed: "+key
      return @
    #
    if not @mk?
      @mk = {}
      @sid ?= make_sid()
    #
    @mk[key] = val?
    @data[key] = val
    return @
  #-

#--

load = (sid, cb) ->
  db.coll(SESS_COLLECTION).findOne( {_id:sid}, {_id:0}, (err, data) ->
    warn "sess.load:", err if err?
    if not err and sid and data?
      cb(sid, data)
    else
      cb(null, {})
  )
#-

x.middleware = () ->
  (req, res, next) ->
    return next() if req.sess?

    res.on "header", () ->
      sess = req.sess
      return if not sess or not req.sess.mk

      sess.set(SESS_IPS, req.ips).set(SESS_TS, new Date())
      sess.fixed = true

      opts = {httpOnly: true} # domain: ".domain", path: "/"
      opts.maxAge = SESS_MAXAGE if not sess.get(SESS_TMP)
      res.cookie(SESS_COOKIE, sess.sid, opts)

      fset = {}
      unset = {}
      for k,v of sess.mk
        if v
          fset[k] = sess.data[k]
        else
          unset[k] = 1
      #

      db.coll(SESS_COLLECTION).update(
        {_id:sess.sid}, {$set:fset, $unset:unset}, {upsert:true}, (err, dat) ->
          warn "sess.save: "+sess.sid, err if err?
      )
    #

    load req.cookies[SESS_COOKIE], (sid, data) ->
      req.sess = new Sess(sid, data)
      next()
    #
  #
#-

#.