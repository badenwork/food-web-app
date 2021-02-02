#!/bin/bash

NAME=web_app
SERVER=pi@vending.local
SERVER_ROOT=/home/pi/vending


elm-app build || exit 1


echo "1. Upload app..."
rsync -az -e ssh ./build/ $SERVER:$SERVER_ROOT/$NAME
rsync -az -e ssh ./config/ $SERVER:$SERVER_ROOT/config
