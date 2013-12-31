#!/bin/bash

PROD_SITE="anga@anga"
PROD_PATH="/www/meteo38"

git push prod master -f

ssh $PROD_SITE "cd $PROD_PATH && git reset --hard && touch main.js"

#.
