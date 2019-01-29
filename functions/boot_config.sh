#!/usr/bin/env bash
set -e

##
# addBootConfigProperty
# $1 KEY (CANNOT be 'dtparam' || 'dtoverlay')
# $2 VALUE (caller must add quotes if required)
# $3 COMMENT (optional) (without leading #)
#
function addBootConfigProperty {
    local FILE="/boot/config.txt"
    local HASH="#"
    local KEY="$1"
    local VAL="$2"
    local CMT="$3"

    # Check against device tree params
    #
    if [ "${KEY}" == "dtparam" ] || [ "${KEY}" == "dtoverlay" ]; then
        echo "Device Tree property '${KEY}' not supported in this function.  See specialized functions" && false
    fi

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Check if property already set to expected value
    #
    grep -q "^${KEY}\s*=\s*${VAL}\s*$" "${FILE}" ||
    (
      (
        # Check if property key already exists
        #
        grep -q "^${KEY}\s*=" "${FILE}" &&
        (
          (
            # Key exists, comment out existing property and add ours right after
            #
            sed  -Ei "s/(^${KEY}\s*=.*\$)/${HASH}\1\n${CMT}${KEY}=${VAL}/g" "${FILE}"
          ) || true
        )
      ) ||
      (
        # Key does not exist, append ours to end of file
        #
        echo -e "\n${CMT}${KEY}=${VAL}" >> "${FILE}"
      )
    )
}

##
# disableBootConfigProperty
# $1 KEY (CANNOT be 'dtparam' || 'dtoverlay')
# $2 COMMENT (optional) (without leading #)
#
function disableBootConfigProperty {
    local FILE="/boot/config.txt"
    local HASH="#"
    local KEY="$1"
    local CMT="$2"

    # Check against device tree params
    #
    if [ "${KEY}" == "dtparam" ] || [ "${KEY}" == "dtoverlay" ]; then
        echo "Device Tree property '${KEY}' not supported in this function.  See specialized functions" && false
    fi

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Comment out existing property, if present
    #
    sed  -Ei "s/(^${KEY}\s*=.*\$)/${CMT}${HASH}\1/g" "${FILE}" || true
}

##
# enableBootConfigOverlay
# $1 OVERLAY
# $2 COMMENT (optional) (without leading #)
function enableBootConfigOverlay {
    local FILE="/boot/config.txt"
    local HASH="#"
    local OVR="$1"
    local CMT="$2"

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Check if overlay already enabled
    #
    grep -Eq "^dtoverlay\s*=\s*${OVR}(\s+\$|:.*\$|\$)" "${FILE}" ||
    (
      # Overlay not enabled, append ours to end of file
      #
      echo -e "\n${CMT}dtoverlay=${OVR}" >> "${FILE}"
    )
}

##
# disableBootConfigOverlay
# $1 OVERLAY
# $2 COMMENT (optional) (without leading #)
function disableBootConfigOverlay {
    local FILE="/boot/config.txt"
    local HASH="#"
    local OVR="$1"
    local CMT="$2"

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Comment out existing property, if present
    #
    sed  -Ei "s/(^dtoverlay\s*=\s*${OVR}(\s+\$|:.*\$|\$))/${CMT}${HASH}\1/g" "${FILE}" || true
}
