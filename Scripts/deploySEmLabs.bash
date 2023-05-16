#!/bin/bash

#================================================================================
# deployLabsAll.bash - updates github repos for all labo's at once
# indend to push labs from [sem_labs](https://gitlab.hevs.ch/course/SEm/hd-labs.git)
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '
DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""


./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 01-WaveformGenerator
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 02-SplineInterpolator
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 03-DigitalToAnalogConverter
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 04-Lissajous
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 05-Morse
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 06-07-08-09-SystemOnChip
./deployLab.bash -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 10-PipelinedOperators

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: ${0##*/} finished"
echo "$SEPARATOR"
popd