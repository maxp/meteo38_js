#
#   lib/config
#

HOSTCONF_DIR = "var"

path = require 'path'

process.env.NODE_ENV = 'development' if not process.env.NODE_ENV

pack = require path.resolve(process.cwd(), "package.json")
conf = require path.resolve(process.cwd(), "config.json")
conf.appname = pack.name
conf.version = pack.version

hostconf = require path.resolve(process.cwd(), HOSTCONF_DIR, process.env.NODE_ENV+".json")

for k, v of hostconf
    if v == null
        delete conf[k]
    else
        conf[k] = v
#

console.log "#{conf.appname} #{conf.version} - config loaded - "+ (
    new Date().toISOString().replace(/T/, ' ').replace(/\.\d\d\dZ$/,'')
)

module.exports = conf

#.