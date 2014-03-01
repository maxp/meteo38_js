#
#   meteo38.ru: exp
#

x = exports ? this

config = require '../lib/config'
db     = require '../lib/db'
lib    = require '../lib'

{debug, info, warn} = require '../lib/logger'


x.t_js = (req, res) ->

    res.send("nimp")
#-


#.