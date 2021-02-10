#!/bin/bash

sleep 10
# DISPLAY=:0
chromium-browser \
   --no-first-run \
   --noerrdialogs \
   --start-maximized \
   --window-position=0,0 \
   --disable \
   --disable-translate \
   --disable-features=TranslateUI \
   --disable-infobars \
   --disable-suggestions-ui \
   --disable-save-password-bubble \
   --disable-session-crashed-bubble \
   --disable-popup-blocking \
   --disable-breakpad \
   --disable-cloud-import \
   --disable-signin-promo \
   --disable-sync \
   --fast \
   --fast-start \
   --no-default-browser-check \
   --check-for-update-interval=315360000 \
   --incognito \
   --kiosk "http://localhost/"
