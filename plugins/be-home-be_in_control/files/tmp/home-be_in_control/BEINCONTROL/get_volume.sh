#!/bin/bash

# Found Here: https://www.dronkert.net/rpi/vol.html

MIX=amixer
declare -i LO=0     # Minimum volume; try 10 to avoid complete silence
declare -i HI=100   # Maximum volume; try 95 to avoid distortion
declare -i ADJ=4    # Volume adjustment step size

usage ()
{
	echo "Usage: `basename $0`" >&2
	echo "  prints a whole number between $LO and $HI, inclusive." >&2
	exit 1
}

# Zero arguments
[ $# -eq 0 ] || usage

EXE=$(which $MIX)
if [ -z "$EXE" ]; then
	echo "Error: $MIX not found. Try \"sudo apt-get install alsa-utils\" first." >&2
	exit 2
fi

GET=$($EXE cget numid=1)
declare -i MIN=$(echo $GET | /bin/grep -E -o -e ',min=[^,]+' | /bin/grep -E -o -e '[0-9-]+')
declare -i MAX=$(echo $GET | /bin/grep -E -o -e ',max=[^,]+' | /bin/grep -E -o -e '[0-9-]+')
declare -i VAL=$(echo $GET | /bin/grep -E -o -e ': values=[0-9+-]+' | /bin/grep -E -o -e '[0-9-]+')

if (( MIN >= MAX || VAL < MIN || VAL > MAX )); then
	echo "Error: could not get the right values from $MIX output." >&2
	exit 3
fi

declare -i LEN=0
(( LEN = MAX - MIN ))

declare -i ABS=0
(( ABS = VAL - MIN ))

declare -i PCT=0
(( PCT = 100 * ABS / LEN ))

echo $PCT
exit 0
