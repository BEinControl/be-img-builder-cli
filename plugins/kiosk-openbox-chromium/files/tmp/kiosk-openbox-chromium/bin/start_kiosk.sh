#!/bin/bash

# ~/bin/start_kiosk.sh
#
# BEINCONTROL (c) 2018 Brilliant Efficiencies

export DISPLAY=:0

# Read Kiosk URL
KIOSK_URL=$(<~/KIOSK.URL)

# Stop any currently-running kiosk
killall chromium-browser
killall /usr/lib/chromium-browser/chromium-browser

(

# Wait for URL to be available
~/bin/retry.sh \
    --tries=120               \
    --sleep=5                 \
    ~/bin/is_url_present.sh "${KIOSK_URL}"

) |
# Give user a progress bar
zenity           \
    --progress   \
    --pulsate    \
    --no-cancel  \
    --auto-close \
    --modal      \
    --title=""   \
    --text="Waiting For Display To Come Online"

RETRY_EXIT_CODE=${PIPESTATUS[0]}

# Is panel up?
if [ "${RETRY_EXIT_CODE}" != "0" ]; then

    # Notify user and give them a chance to reboot
    zenity                      \
        --error                 \
        --modal                 \
        --ok-label="Reboot"     \
        --text="<span foreground='#FF0000'>DISPLAY FAILED TO START</span>\n\n<span weight='bold' foreground='#0000FF'>Reboot</span> to try again.\n\nIf the problem persists,\nplease contact Support.   "

    sudo reboot
    exit 1
fi

#
# Launch URL in brower
#

# HACK to Clear crash status on default profile to prevent "reopen" dialogue
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/'   ~/.config/chromium/Default/Preferences

# Open Chromium in Kiosk mode to URL
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
    "${KIOSK_URL}"                   \
    & 2>/dev/null

exit 0
