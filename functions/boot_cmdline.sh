#!/usr/bin/env bash
set -e

##
# delBootCmdlineProperty
# $1 KEY
#
function delBootCmdlineProperty {
    local FILE="/boot/cmdline.txt"
    local KEY="$1"

    # Check if key exists
    #
    grep -Eq "(^|\s)${KEY}(=|\s|$)" "${FILE}" &&
    (
      (
        # Key exists, remove it, and fixup remnant whitespace
        #
        sed  -Ei \
          -e "s/(^|\s)${KEY}(=((\S+)|(\"[^\"]+\")))?(\s|\$)/\1\6/g" \
          -e "s/\s+$//g" \
          -e "s/\s+/ /g" \
          "${FILE}"
      ) || true
    ) || true
}

##
# addBootCmdlineProperty
# $1 KEY
# $2 VALUE (optional) (caller must add quotes if required)
#
function addBootCmdlineProperty {
    local FILE="/boot/cmdline.txt"
    local KEY="$1"
    local VAL="$2"

    # Delete existing value, if any
    #
    delBootCmdlineProperty "${KEY}"

    # Just Key or Key+Value?
    #
    if [ -z "${VAL}" ]; then
      # Just Key
      #
      sed -Ei "s/$/ ${KEY}/" "${FILE}"
    else
      # Key + Value
      #
      sed -Ei "s/$/ ${KEY}=${VAL}/" "${FILE}"
    fi
}
