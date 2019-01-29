#!/bin/bash

echo "pi_brighntess " $* >> /tmp/pi_brightness.log

sudo /home/be/BEINCONTROL/sbin/pi_backlight_brightness $*
