#!/bin/bash

# Load trackball setup
xmodmap ~/.xmodmap

# Disable LCD screen, set HDMI output as primary
xrandr --output HDMI-3 --primary
xrandr --output LVDS-1 --off
