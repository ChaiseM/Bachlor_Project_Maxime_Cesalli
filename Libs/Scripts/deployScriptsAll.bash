#!/bin/bash

#================================================================================
# deployScriptsAll.bash - updates github Scripts folder for all labo's at once
# indend to push scripts from [eda_scripts](https://gitlab.hevs.ch/course/ElN/eda_scripts.git)
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '
DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""

./deployScripts.bash -v -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
./deployScripts.bash -v -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
./deployScripts.bash -v -p eln_chrono -r https://github.com/hei-synd-2131-eln/eln_chrono.git
./deployScripts.bash -v -p eln_cursor -r https://github.com/hei-synd-2131-eln/eln_cursor.git
./deployScripts.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git
./deployScripts.bash -v -p eln_inverter -r https://github.com/hei-ete-8132-eln/eln_inverter.git
./deployScripts.bash -v -p eln_synchro -r https://github.com/hei-ete-8132-eln/eln_synchro.git
./deployScripts.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: ${0##*/} finished"
echo "$SEPARATOR"
popd