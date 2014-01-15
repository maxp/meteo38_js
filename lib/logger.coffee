#
#   meteo38.ru: logger
#

x = exports ? this

config = require './config'
moment = require 'moment'
{inspect} = require 'util'
winston = require 'winston'

logger = new winston.Logger {
    transports: [
        new winston.transports.Console
            timestamp: -> moment().format("MMM.DD HH:mm:ss")
            level: "debug"
        new winston.transports.File
            name: "file#all"
            filename: config.logger.all
            timestamp: -> moment().format("MMM.DD HH:mm:ss")
            level: "debug"
            json: false
            # prettyPrint: true
            # maxsize: 
            # maxFiles:
        new winston.transports.File
            name: "file#err"
            filename: config.logger.err
            timestamp: -> moment().format("MMM.DD HH:mm:ss")
            level: "warn"
            json: false
    ]
}

format_args = (msg, args...) ->
    res = [msg]
    for s in args
        if not s?
            res.push "[Nil]"
        else if s instanceof Date
            res.push moment(s).format("YYYY.MM.DD-HH:mm:ss")
        else
            res.push inspect(s, false, 4, false)
    #
    res.join ' '
#

x.log   = logger.log
x.info  = (args...) -> logger.log "info", format_args args...
x.warn  = (args...) -> logger.log "warn", format_args args...
x.debug = (args...) -> logger.log "debug",format_args args...

#.