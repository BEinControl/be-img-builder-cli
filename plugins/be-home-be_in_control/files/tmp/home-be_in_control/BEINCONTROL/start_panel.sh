#!/bin/bash

# /home/be/BEINCONTROL/start_panel.sh
#
# BEINCONTROL (c) 2018 Brilliant Efficiencies

export DISPLAY=:0

# Read Panel URL
PANEL_URL=$(</home/be/BEINCONTROL/panel.url)

# Stop any currently-running kiosk
killall chromium-browser

(

# Wait for panel to be available
/home/be/BEINCONTROL/retry.sh \
    --tries=120               \
    --sleep=5                 \
    /home/be/BEINCONTROL/is_url_present.sh "${PANEL_URL}"

) |
# Give user a progress bar
zenity           \
    --progress   \
    --pulsate    \
    --no-cancel  \
    --auto-close \
    --modal      \
    --title=""   \
    --text="Waiting For Panel To Come Online"

RETRY_EXIT_CODE=${PIPESTATUS[0]}

# Is panel up?
if [ "${RETRY_EXIT_CODE}" != "0" ]; then

    # Notify user and give them a chance to reboot
    zenity                      \
        --error                 \
        --modal                 \
        --ok-label="Reboot"     \
        --text="<span foreground='#FF0000'>PANEL FAILED TO START</span>\n\n<span weight='bold' foreground='#0000FF'>Reboot</span> to try again.\n\nIf the problem persists,\nplease contact Support.   "

    sudo reboot
    exit 1
fi

#
# Launch panel in brower
#

# HACK to Clear crash status on default profile to prevent "reopen" dialogue
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/be/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/'   /home/be/.config/chromium/Default/Preferences

# Open Chromium in Kiosk mode to habPanel
/usr/bin/chromium-browser            \
    --temp-profile                   \
    --window-size=800,480            \
    --no-default-browser-check       \
    --noerrdialogs                   \
    --disable-suggestions-service    \
    --disable-session-crashed-bubble \
    --disable-save-password-bubble   \
    --disable-translate              \
    --disable-infobars               \
    --disable-gesture-typing         \
    --no-first-run                   \
    --touch-events=enabled           \
    --kiosk                          \
    "${PANEL_URL}"                   \
    &

exit 0
