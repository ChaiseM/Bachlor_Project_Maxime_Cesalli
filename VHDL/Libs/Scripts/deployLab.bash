#!/bin/bash

#================================================================================
# deployLab.bash - updates github repos for individual labos
# Example usage 01: ./Scripts/deployLab.bash -v -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
# Example usage 02: ./Scripts/deployLab.bash -v -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
# Example usage 03: ./Scripts/deployLab.bash -v -p eln_chrono -r https://github.com/hei-synd-2131-eln/eln_chrono.git
# Example usage 04: ./Scripts/deployLab.bash -v -p eln_cursor -r https://github.com/hei-synd-2131-eln/eln_cursor.git
# Example usage 05: ./Scripts/deployLab.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git -d 01-StepperMotor
# Example usage 06: ./Scripts/deployLab.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git -d 02-DcMotor
# Example usage 07: ./Scripts/deployLab.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git -d 03-Sensors
# Example usage 08: ./Scripts/deployLab.bash -v -p eln_kart -r https://github.com/hei-synd-2131-eln/eln_kart.git -d 04-Controller
# Example usage 09: ./Scripts/deployLab.bash -v -p eln_inverter -r https://github.com/hei-ete-8132-eln/eln_inverter.git
# Example usage 10: ./Scripts/deployLab.bash -v -p eln_synchro -r https://github.com/hei-ete-8132-eln/eln_synchro.git
#
# Example usage 11: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 01-WaveformGenerator
# Example usage 12: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 01-WaveformGenerator
# Example usage 13: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 02-SplineInterpolator
# Example usage 14: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 03-DigitalToAnalogConverter
# Example usage 15: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 04-Lissajous
# Example usage 16: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 05-Morse
# Example usage 17: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 06-07-08-09-SystemOnChip
# Example usage 18: ./Scripts/deployLab.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git -d 10-PipelinedOperators
#
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory
base_directory="$base_directory/.."

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '
DATE=`date '+%Y-%m-%d %H:%M:%S'`

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""

#-------------------------------------------------------------------------------
# Parse command line options
#
# Valid Projects
# [synd_eln_labs](https://github.com/hei-synd-2131-eln/eln_labs.git)
# [ete_eln_labs](https://github.com/hei-ete-8132-eln/eln_labs)
# [ele_labs]()
# [sem_labs](https://github.com/hei-synd-225-sem/sem_labs.git)
# [eln_cursor](https://github.com/hei-synd-2131-eln/eln_cursor.git)
# [eln_chrono](https://github.com/hei-synd-2131-eln/eln_chrono.git)
# [eln_kart](https://github.com/hei-synd-2131-eln/eln_kart.git)
# [eln_inverter](https://github.com/hei-ete-8132-eln/eln_inverter.git)
# [eln_synchro](https://github.com/hei-ete-8132-eln/eln_synchro.git)
# [eln_support]()
# [eptm_radio]()
# [eptm_audioamp]()
# [cansat]()
# [synd_sem_labs](https://github.com/hei-synd-225-sem/sem_labs.git)
project='eln_labs'
repo='https://github.com/hei-synd-2131-eln/eln_labs.git'
dir='01-StepperMotor'

usage='Usage: deployLab.bash [-p projectName] [-r repourl] [-d directory] [-v] [-h]'
while getopts 'p:r:d:vh' options; do
  case $options in
    p ) project=$OPTARG;;
    r ) repo=$OPTARG;;
    d ) dir=$OPTARG;;
    v ) verbose=1;;
    h ) echo -e $usage
          exit 1;;
    * ) echo -e $usage
          exit 1;;
  esac
done

#-------------------------------------------------------------------------------
# Display info
#
if [ -n "$verbose" ] ; then
  echo "$SEPARATOR"
  echo "-- $DATE: Deploy Laboratory for Students"
  echo "${INDENT}for $project"
  echo "${INDENT}to $repo"
  echo "${INDENT}in $dir"
  echo ""
fi

#-------------------------------------------------------------------------------
# Clean current repo
#
echo "Clean parent repo from intermediate files"
./cleanGenerated.bash

#-------------------------------------------------------------------------------
# Clone student repo
#
# Create a tmp subdirectory if it doesn't exist
echo "Create tmp folder"
mkdir -p tmp
cd tmp

# Get repo
echo "Clone student repo $project"
# Add login and access token to url
repo_access=$(echo $repo | sed 's/https\?:\/\///')
github_username=tschinz
github_accesstoken=aa585090e71fbc7b75c693623053853247c0c420
repo_access="https://$github_username:$github_accesstoken@${repo_access}"
git clone $repo_access
if [ "$project" == "synd_eln_labs" ]; then
  cd eln_labs
elif [ "$project" == "ete_eln_labs" ]; then
  cd eln_labs
else
  cd $project
fi

repo_dest=`realpath "./"`
repo_source=`realpath "./../../.."`

echo "Update files in student repo $project"
# Copy needed files per project
if [ "$project" == "synd_eln_labs" ]; then
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder ./
    else
      echo "skip $folder"
    fi
  done
  rm -v -f ./Num/hdl/sinewaveGenerator_comb.vhd

elif [ "$project" == "ete_eln_labs" ]; then
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder ./
    else
      echo "skip $folder"
    fi
  done
  rm -v -f ./Num/hdl/sinewaveGenerator_comb.vhd

elif [ "$project" == "ele_labs" ]; then
  echo "Error: Not implemented yet"

elif [ "$project" == "sem_labs" ]; then
  mkdir -p $dir
  repo_dest=`realpath "./$dir/"`
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/01-WaveformGenerator/Scripts" != "$folder" && "$repo_source/02-SplineInterpolator/Scripts" != "$folder" && "$repo_source/03-DigitalToAnalogConverter/Scripts" != "$folder" && "$repo_source/04-Lissajous/Scripts" != "$folder" && "$repo_source/05-Morse/Scripts" != "$folder" && "$repo_source/06-07-08-09-SystemOnChip/Scripts" != "$folder" && "$repo_source/10-PipelinedOperators/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder $repo_dest
    else
      echo "skip $folder"
    fi
  done
  echo ""
  echo "Delete solutions blocs for sem-labs $dir"

  if [ "$dir" == "01-WaveformGenerator" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "02-SplineInterpolator" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "03-DigitalToAnalogConverter" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "04-Lissajous" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "05-Morse" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "06-07-08-09-SystemOnChip" ]; then
    echo "Info: Nothing to be deleted"
  elif [ "$dir" == "10-PipelinedOperators" ]; then
    echo "Info: Nothing to be deleted"
  fi

elif [ "$project" == "eln_cursor" ]; then
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder ./
    else
      echo "skip $folder"
    fi
  done
  echo ""
  echo "Delete solutions blocs for eln_cursor"
  rm -v -f ./Cursor/hdl/amplitudeControl_RTL.vhd
  rm -v -f ./Cursor/hdl/bridgeControl_RTL.vhd
  rm -v -f ./Cursor/hdl/decelerationPositions_RTL.vhd
  rm -v -f ./Cursor/hdl/divider_RTL.vhd
  rm -v -f ./Cursor/hdl/findDistance_RTL1.vhd
  rm -v -f ./Cursor/hdl/positionCounter_RTL.vhd
  rm -v -f ./Cursor/hdl/pulseWidthModulator_RTL.vhd
  rm -v -f ./Cursor/hds/_amplitudecontrol._epf
  rm -v -f ./Cursor/hds/_bridgecontrol._epf
  rm -v -f ./Cursor/hds/_control._epf
  rm -v -f ./Cursor/hds/_decelerationpositions._epf
  rm -v -f ./Cursor/hds/_divider._epf
  rm -v -f ./Cursor/hds/_positioncounter._epf
  rm -v -f ./Cursor/hds/_pulsewidthmodulator._epf
  rm -v -f ./Cursor/hds/.hdlsidedata/_amplitudecontrol_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_amplitudeControl_RTL.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_bridgecontrol_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_bridgeControl_RTL.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_control_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_control_fsm.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_decelerationpositions_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_decelerationPositions_RTL.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_divider_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_divider_RTL.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_findDistance_RTL1.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_positioncounter_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_positionCounter_RTL.vhd._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_pulsewidthmodulator_entity.vhg._fpf
  rm -v -f ./Cursor/hds/.hdlsidedata/_pulseWidthModulator_RTL.vhd._fpf
  rm -v -f -r ./Cursor/hds/amplitude@control
  rm -v -f -r ./Cursor/hds/bridge@control
  rm -v -f -r ./Cursor/hds/control
  rm -v -f -r ./Cursor/hds/deceleration@positions
  rm -v -f -r ./Cursor/hds/divider
  rm -v -f -r ./Cursor/hds/position@counter
  rm -v -f -r ./Cursor/hds/pulse@width@modulator
  rm -v -f -r ./Cursor/hds/rising@detector
  rm -v -f -r ./Board/concat/concatenated.vhd
  rm -v -f -r ./Board/concat/eln_cursor.vhd

elif [ "$project" == "eln_chrono" ]; then
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder ./
    else
      echo "skip $folder"
    fi
  done
  echo ""
  echo "Delete solutions blocs for eln_chrono"
  rm -v -f ./Chronometer/hdl/coilControl_RTL.vhd
  rm -v -f ./Chronometer/hdl/divider1Hz_RTL.vhd
  rm -v -f ./Chronometer/hdl/tickLengthCounter_RTL.vhd
  rm -v -f ./Chronometer/hdl/lcdDisplay_masterVersion.vhd
  rm -v -f ./Chronometer/hds/_coilcontrol._epf
  rm -v -f ./Chronometer/hds/_control._epf
  rm -v -f ./Chronometer/hds/_divider1hz._epf
  rm -v -f ./Chronometer/hds/_ticklengthcounter._epf
  rm -v -f ./Chronometer/hds/_coilcontrol._epf
  rm -v -f ./Chronometer/hds/_coilcontrol._epf
  rm -v -f ./Chronometer/hds/_coilcontrol._epf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_coilcontrol_entity.vhg._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_coilControl_RTL.vhd._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_control_entity.vhg._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_control_fsm.vhg._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_divider1hz_entity.vhg._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_divider1Hz_RTL.vhd._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_ticklengthcounter_entity.vhg._fpf
  rm -v -f ./Chronometer/hds/.hdlsidedata/_tickLengthCounter_RTL.vhd._fpf
  rm -v -f -r ./Chronometer/hds/coil@control/
  rm -v -f -r ./Chronometer/hds/control/
  rm -v -f -r ./Chronometer/hds/divider1@hz/
  rm -v -f -r ./Chronometer/hds/rising@detector/
  rm -v -f -r ./Chronometer/hds/tick@length@counter/
  rm -v -f -r ./Board/concat/concatenated.vhd
  rm -v -f -r ./Board/concat/eln_chrono.vhd

elif [ "$project" == "eln_kart" ]; then
  mkdir -p $dir
  repo_dest=`realpath "./$dir/"`
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder $repo_dest
    else
      echo "skip $folder"
    fi
  done
  echo ""
  echo "Delete solutions blocs for eln_kart $dir"

  if [ "$dir" == "01-StepperMotor" ]; then
    rm -v -f ./01-StepperMotor/StepperMotor/hdl/angleDifference_RTL.vhd
	rm -v -f ./01-StepperMotor/StepperMotor/hdl/coilControl_RTL.vhd
	rm -v -f ./01-StepperMotor/StepperMotor/hdl/stepperCounter_RTL.vhd
	rm -v -f ./01-StepperMotor/StepperMotor/hds/angle@control/master@version.bd
	rm -v -f ./01-StepperMotor/StepperMotor/hds/coil@control/master@version_counter@demux.bd
	rm -v -f ./01-StepperMotor/StepperMotor/hds/coil@control/master@version_shift@reg.bd
  elif [ "$dir" == "02-DcMotor" ]; then
    rm -v -f ./02-DcMotor/DcMotor/hdl/dcMotorPwm_RTL.vhd
  elif [ "$dir" == "03-Sensors" ]; then
    rm -v -f ./03-Sensors/Sensors/hdl/hallCounters_RTL.vhd
	rm -v -f ./03-Sensors/Sensors/hdl/ultrasoundRanger_RTL.vhd
  elif [ "$dir" == "04-Controller" ]; then
    echo "Info: Nothing to be deleted"
  fi

elif [ "$project" == "eln_inverter" ]; then
  find $repo_source -maxdepth 1 -type f \! \( -name .gitmodules -o -name .gitlab-ci.yml -o -name README.md -o -name LICENSE \) -exec cp -ar '{}' $repo_dest \;
  for folder in $(find $repo_source -maxdepth 1 -type d )
  do
    if [[ "$repo_source" != "$folder" && "$repo_source/.git" != "$folder" && "$repo_source/Libs" != "$folder" && "$repo_source/Scripts" != "$folder" && "$repo_source/img" != "$folder" ]] ; then
      echo "copy $folder"
      cp -ar $folder ./
    else
      echo "skip $folder"
    fi
  done
  echo ""
  echo "Delete solutions blocs for eln_inverter"
  rm -v -f -r ./Board/concat/concatenated.vhd
  rm -v -f -r ./Board/concat/eln_inverter.vhd

elif [ "$project" == "eln_synchro" ]; then
  echo "Error: Not implemented yet"

elif [ "$project" == "eln_support" ]; then
  echo "Error: Not implemented yet"

elif [ "$project" == "eptm_radio" ]; then
  echo "Error: Not implemented yet"

elif [ "$project" == "eptm_audioamp" ]; then
  echo "Error: Not implemented yet"

elif [ "$project" == "cansat" ]; then
  echo "Error: Not implemented yet"
fi

#-------------------------------------------------------------------------------
# change from masterVersion to studentVersion and delete all masterVersion
#
if [ "$project" == "synd_eln_labs" ]; then
  ./../../changeDefaultViews.bash -p "Scripts/tmp/eln_labs" -a masterVersion -n studentVersion -r
  ./../../changeDefaultViews.bash -p "Scripts/tmp/eln_labs" -a master@version -n student@version -r
elif [ "$project" == "ete_eln_labs" ]; then
  ./../../changeDefaultViews.bash -p "Scripts/tmp/eln_labs" -a masterVersion -n studentVersion -r
  ./../../changeDefaultViews.bash -p "Scripts/tmp/eln_labs" -a master@version -n student@version -r
else
  ./../../changeDefaultViews.bash -p "Scripts/tmp/$project" -a masterVersion -n studentVersion -r
  ./../../changeDefaultViews.bash -p "Scripts/tmp/$project" -a master@version -n student@version -r
fi

# add/commit/push changes to student repo
git add -A
git commit -a -m "$DATE: Automatic Laboratory Update with ``deployLab.bash`` :shipit:"
git push origin master
cd ..

# Delete tmp directory
echo "Delete tmp directory"
cd ..
pwd
rm -rf "./tmp"

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: $project updated at $repo"
echo "$SEPARATOR"
popd
