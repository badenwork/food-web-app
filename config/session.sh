#!/bin/bash


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
   --incognito \
   --kiosk "http://vending.local/"
