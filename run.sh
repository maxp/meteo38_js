#!/bin/bash

# /etc/init/ws-meteo38.conf:
# description   "openirk service"
# start on runlevel [2]
# stop on runlevel [!2]
# respawn
# respawn limit 0 10
# script
#  sleep 2
#  cd /www/meteo38
#  exec /bin/su www -c "./run.sh"
# end script

export NODE_PATH="/usr/lib/node_modules"
export NODE_ENV="production"
export LOG="/var/log/www/meteo38"

exec nodejs main meteo38 >> ${LOG}-out.log 2>&1

#.
