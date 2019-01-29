#!/bin/bash

# ~/bin/stop_kiosk.sh
#
# BEINCONTROL (c) 2018 Brilliant Efficiencies

# HACK this is a bit of a nuke-it-from orbit solution
killall chromium-browser
killall /usr/lib/chromium-browser/chromium-browser
