#!/bin/bash
mkdir -p /tmp/screenshots

if [[ $OSTYPE == "darwin"* ]]; then
  screencapture -x /tmp/screenshots/screenshot.png
else
  maim -u /tmp/screenshots/screenshot.png
fi

if command -v viu &>/dev/null; then
  viu /tmp/screenshots/screenshot.png
else
  echo "Screenshot saved to /tmp/screenshots/screenshot.png"
  echo "Install 'viu' to view in terminal"
fi
