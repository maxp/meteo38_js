#
#   misc: common coffescript routines
#

x = exports ? this

crypto = require 'crypto'
fs = require 'fs'
http = require 'http'
Buffer = require('buffer').Buffer

urand_fd = fs.openSync "/dev/urandom", 'r'

x.now = () -> new Date().getTime()

x.urandom = urandom = (n) ->
    buff = new Buffer(n)
    fs.readSync urand_fd, buff, 0, n, 0
    return buff
#-

x.random_digits = (n=6) ->
    s = ""
    while s.length < n
        a = 0
        for i in urandom(4)
            a = a * 256 + i
        s += a
    #
    return s.slice(0, n)
#-

x.sha256 = (str) -> crypto.createHash('sha256').update(str, "utf-8").digest("hex")

x.int = (s, def=0) ->
    i = parseInt(s, 10)
    return if isNaN(i) then def else i
#-

x.str = (s) -> if (not s?) or (typeof s == "number" and isNaN(s)) then "" else ""+s

x.set_if = (dict, key, val) -> dict[key] = val if val?

# x.req_ips = (req) ->
#     return null if (not req.ips?.length) or 
#         (req.ips.length == 1 and req.ips[0] == req.ip)
#     return req.ips
# #-    


WATCH_FILE_TIMEOUT = 3000

x.watch_file = (filename, cb) ->
    cb ?= () ->
        console.log "exiting..."
        process.exit 99
    #-      
    ts = null
    setInterval( 
        () -> 
            fs.stat filename, (err, stat) ->
                return cb() if err
                ts ?= stat.mtime
                return cb() if stat.mtime > ts
            #-
        #-
        WATCH_FILE_TIMEOUT
    )
#-


d02 = (d) -> if d < 10 then "0"+d else ""+d

x.ddmmyyyy = (date) ->
      return "??.??.????" if not date
      d02(date.getDate())+"."+d02(date.getMonth()+1)+"."+date.getFullYear()
#-

x.hhmm = (date) ->
      return "??:??" if not date
      d02(date.getHours())+":"+d02(date.getMinutes())
#-

x.hhmmss = (date) ->
      return "??:??:??" if not date
      d02(date.getHours())+":"+d02(date.getMinutes())+":"+d02(date.getSeconds())
#-

x.ddmmyyyy_hhmm = (date) -> return x.ddmmyyyy(date)+" "+x.hhmm(date)
x.ddmmyyyy_hhmmss = (date) -> return x.ddmmyyyy(date)+" "+x.hhmmss(date)


#.
