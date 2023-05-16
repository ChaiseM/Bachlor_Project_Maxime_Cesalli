#!/bin/bash

#================================================================================
# deployLibsAll.bash - updates github repos for all labo's at once
# indend to push libs from [eda_libs](https://gitlab.hevs.ch/course/ElN/eda_libs.git)
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '
DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""

./deployLibs.bash -v -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
./deployLibs.bash -v -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
./deployLibs.bash -v -p isc-eln-labs -r https://github.com/hei-isc-eln/eln-labs.git
./deployLibs.bash -v -p eln_chrono -r https://github.com/hei-synd-2131-eln/eln_chrono.git
./deployLibs.bash -v -p eln_cursor -r https://github.com/hei-synd-2131-eln/eln_cursor.git
./deployLibs.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git
./deployLibs.bash -v -p eln_inverter -r https://github.com/hei-ete-8132-eln/eln_inverter.git
./deployLibs.bash -v -p eln_synchro -r https://github.com/hei-ete-8132-eln/eln_synchro.git
./deployLibs.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git
./deployLibs.bash -v -p eln-kart -r https://github.com/hei-synd-2131-eln/eln-kart.git
./deployLibs.bash -v -p eln-display -r https://github.com/hei-isc-eln/eln-display.git

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: ${0##*/} finished"
echo "$SEPARATOR"
popd