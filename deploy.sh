#!/bin/bash

PROD_SITE="app"
PROD_PATH="/app/meteo38"

git push backup master -f

git push prod master -f

ssh $PROD_SITE "cd $PROD_PATH && git reset --hard && npm install --production && pm2 restart meteo38"

#.
