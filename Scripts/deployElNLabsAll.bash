#!/bin/bash

#================================================================================
# deployLabsAll.bash - updates github repos for all labo's at once
# indend to push labs from [eln_labs](https://gitlab.hevs.ch/course/ElN/eln_labs.git)
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '
DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""


./deployLab.bash -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
./deployLab.bash -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
./deployLab.bash -p isc-eln-labs -r https://github.com/hei-isc-eln/eln-labs.git

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: ${0##*/} finished"
echo "$SEPARATOR"
popd