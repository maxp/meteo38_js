#!/bin/bash

PROD_SITE="www@ex1"
PROD_PATH="/www/meteo38"

git push prod master -f

ssh $PROD_SITE "cd $PROD_PATH && npm install --production && git reset --hard && touch main.js"

#.
