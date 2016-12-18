#!/bin/bash

export NODE_PATH="/usr/lib/node_modules"
export NODE_ENV="production"
export LOG="/www/log/meteo38"

exec nodejs main meteo38 >> ${LOG}-out.log 2>> ${LOG}-err.log 

#.
