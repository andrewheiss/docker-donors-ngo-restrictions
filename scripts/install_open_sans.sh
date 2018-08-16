#!/usr/bin/env sh
FONT_NAME="Open_Sans"

cd /tmp/${FONT_NAME}
unzip -o -j ${FONT_NAME}.zip
cp *.ttf /usr/share/fonts
fc-cache -f -v
