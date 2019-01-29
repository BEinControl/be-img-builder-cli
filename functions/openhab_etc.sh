#!/usr/bin/env bash
set -e

##
# _openhabAddProperty
# $1 FILE
# $2 KEY
# $3 VALUE
# $4 COMMENT (optional) (without leading #)
#
function _openhabAddProperty {
    local FILE="$1"
    local HASH="#"
    local KEY="$2"
    local VAL="$3"
    local CMT="$4"

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
            sed  -Ei "s/(^${KEY}\s*=.*\$)/${HASH}\1\n${CMT}${KEY} = ${VAL}/g" "${FILE}"
          ) || true
        )
      ) ||
      (
        # Key does not exist, append ours to end of file
        #
        echo -e "\n${CMT}${KEY} = ${VAL}" >> "${FILE}"
      )
    )
}

##
# _openhabDisableProperty
# $1 FILE
# $2 KEY
# $3 COMMENT (optional) (without leading #)
#
function _openhabDisableProperty {
    local FILE="$1"
    local HASH="#"
    local KEY="$2"
    local CMT="$3"

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
# _openhabAddElementToListProperty (private)
# $1 FILE
# $2 KEY
# $3 ELEMENT
# $4 COMMENT (optional) (without leading #)
#
function _openhabAddElementToListProperty {
    local FILE="$1"
    local HASH="#"
    local KEY="$2"
    local ELEMENT="$3"
    local CMT="$4"

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Check if key+element already present
    #
    grep -Eq "^${KEY}\s*=\s*((${ELEMENT})|.+((\s|,)${ELEMENT}))(\s|,|$)" "${FILE}" ||
    (
      (
        # Check if key present
        #
        grep -Eq "^${KEY}\s*=\s*" "${FILE}" &&
        (
          (
            # Key exists, append our element and add comment
            #
            sed -Ei \
                -e "s/^(${KEY}\s*=\s*\S.*)$/${CMT}\1,${ELEMENT}/g" \
                -e "s/^(${KEY}\s*=\s*)$/${CMT}\1${ELEMENT}/g"    \
                "${FILE}"
          ) || true
        )
      ) ||
      (
        # Key does not exist, append key+element to end of file
        #
        echo -e "\n${CMT}${KEY} = ${ELEMENT}" >> "${FILE}"
      )
    )
}

##
# _openhabAddElementToListProperty (private)
# $1 FILE
# $2 KEY
# $3 ELEMENT
# $4 COMMENT (optional) (without leading #)
#
function _openhabDeleteElementFromListProperty {
    local FILE="$1"
    local HASH="#"
    local KEY="$2"
    local ELEMENT="$3"
    local CMT="$4"

    # Configure comment, if present
    #
    if [ ! -z "${CMT}" ]; then
      CMT="${HASH} ${CMT}\n"
    fi

    # Remove element, if present, adding comment
    # NOTE: If removing last element, leaves KEY property empty
    #       (i.e. does not comment it out or remove it)
    #
    sed -Ei \
        -e "s/^(${KEY}\s*=\s*)${ELEMENT}\s*$/${CMT}\1/g"            \
        -e "s/^(${KEY}\s*=\s*)${ELEMENT}\s*,(.*)$/${CMT}\1\2/g"     \
        -e "s/^(${KEY}\s*=.*),\s*${ELEMENT}\s*,(.*)$/${CMT}\1,\2/g" \
        -e "s/^(${KEY}\s*=.*),\s*${ELEMENT}\s*$/${CMT}\1/g"         \
        "${FILE}" \
    || true
}

DIR_OPENHAB_ETC="/etc/openhab2/"
FILE_OPENHAB_ETC_ADDONS="${DIR_OPENHAB_ETC}/services/addons.cfg"

##
# setOpenhabInstallationType
# $1 TYPE ( minimal | simple | standard | expert | demo )
# $2 COMMENT (optional) (without leading #)
#
function setOpenhabInstallationType {
    _openhabAddProperty "${FILE_OPENHAB_ETC_ADDONS}" "package" "$1" "$2"
}

##
# clearOpenhabInstallationType
# $1 COMMENT (optional) (without leading #)
#
function clearOpenhabInstallationType {
    _openhabDisableProperty "${FILE_OPENHAB_ETC_ADDONS}" "package" "$1"
}

##
# enableOpenhabBinding
# $1 BINDING
# $2 COMMENT (optional) (without leading #)
#
function enableOpenhabBinding {
    _openhabAddElementToListProperty "${FILE_OPENHAB_ETC_ADDONS}" "binding" "$1" "$2"
}

##
# disableOpenhabBinding
# $1 BINDING
# $2 COMMENT (optional) (without leading #)
#
function disableOpenhabBinding {
    _openhabDeleteElementFromListProperty "${FILE_OPENHAB_ETC_ADDONS}" "binding" "$1" "$2"
}

##
# enableOpenhabUI
# $1 UI
# $2 COMMENT (optional) (without leading #)
#
function enableOpenhabUI {
    _openhabAddElementToListProperty "${FILE_OPENHAB_ETC_ADDONS}" "ui" "$1" "$2"
}

##
# disableOpenhabUI
# $1 UI
# $2 COMMENT (optional) (without leading #)
#
function disableOpenhabUI {
    _openhabDeleteElementFromListProperty "${FILE_OPENHAB_ETC_ADDONS}" "ui" "$1" "$2"
}

##
# enableOpenhabTransform
# $1 TRANSFORM
# $2 COMMENT (optional) (without leading #)
#
function enableOpenhabTransform {
    _openhabAddElementToListProperty "${FILE_OPENHAB_ETC_ADDONS}" "transformation" "$1" "$2"
}

##
# disableOpenhabTransform
# $1 TRANSFORM
# $2 COMMENT (optional) (without leading #)
#
function disableOpenhabTransform {
    _openhabDeleteElementFromListProperty "${FILE_OPENHAB_ETC_ADDONS}" "transformation" "$1" "$2"
}

##
# fixOpenhabEtcPermissions
# Call this after adding files to $DIR_OPENHAB_ETC
#
function fixOpenhabEtcPermissions {
    chown -R openhab.openhab  "${DIR_OPENHAB_ETC}"
    chmod -R u+rwX,go+rX,go-w "${DIR_OPENHAB_ETC}"
}
