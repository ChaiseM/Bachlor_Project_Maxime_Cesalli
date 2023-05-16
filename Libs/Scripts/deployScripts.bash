#!/bin/bash

#================================================================================
# deployScripts.bash - updates github repos for individual labos
# indend to push scripts from [eda_scripts](https://gitlab.hevs.ch/course/ElN/eda_scripts.git)
# Example usage 1: ./Scripts/deployScripts.bash -v -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
# Example usage 2: ./Scripts/deployScripts.bash -v -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
# Example usage 3: ./Scripts/deployScripts.bash -v -p eln_chrono -r https://github.com/hei-synd-2131-eln/eln_chrono.git
# Example usage 4: ./Scripts/deployScripts.bash -v -p eln_cursor -r https://github.com/hei-synd-2131-eln/eln_cursor.git
# Example usage 5: ./Scripts/deployScripts.bash -v -p eln_inverter -r https://github.com/hei-ete-8132-eln/eln_inverter.git
# Example usage 6: ./Scripts/deployScripts.bash -v -p eln_synchro -r https://github.com/hei-ete-8132-eln/eln_synchro.git
# Example usage 7: ./Scripts/deployScripts.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git
#

base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory
base_directory="$base_directory"

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
# [ete_eln_labs](https://github.com/hei-ete-8132-eln/eln_labs.git)
# [ele_labs]()
# [sem_labs](https://github.com/hei-synd-225-sem/sem_labs.git)
# [eln_cursor](https://github.com/hei-synd-2131-eln/eln_cursor.git)
# [eln_chrono](https://github.com/hei-synd-2131-eln/eln_chrono.git)
# [eln_kart](https://github.com/hei-synd-2131-eln/eln_kart.git)
# [eln_inverter](https://github.com/hei-ete-8132-eln/eln_inverter.git)
# [eln_support](https://github.com/hei-ete-8132-eln/eln_synchro.git)
# [eln_synchro]()
# [eptm_radio]()
# [eptm_audioamp]()
# [cansat]()
project='eln_labs'
repo='https://github.com/hei-synd-2131-eln/eln_labs.git'

usage='Usage: deployScripts.bash [-p projectName] [-r repourl] [-v] [-h]'
while getopts 'p:r:vh' options; do
  case $options in
    p ) project=$OPTARG;;
    r ) repo=$OPTARG;;
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
  echo "-- $DATE: Deploy Scripts for Students"
  echo "${INDENT}for $project"
  echo "${INDENT}to $repo"
  echo ""
fi

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

library_source=`realpath "./../.."`

# ELN Kart has a different project structure
if [ "$project" == "eln_kart" ]; then
  # Copy needed libraries per project
  mkdir -p "01-StepperMotor/Scripts"
  library_dest=`realpath "./01-StepperMotor/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_libero.pl"    "$library_dest/"
  cp -arf "$library_source/start_libero.pl"     "$library_dest/"

  # Copy needed libraries per project
  mkdir -p "02-DcMotor/Scripts"
  library_dest=`realpath "./02-DcMotor/Scripts"`
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_libero.pl"    "$library_dest/"
  cp -arf "$library_source/start_libero.pl"     "$library_dest/"

  # Copy needed libraries per project
  mkdir -p "03-Sensors/Scripts"
  library_dest=`realpath "./03-Sensors/Scripts"`
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_libero.pl"    "$library_dest/"
  cp -arf "$library_source/start_libero.pl"     "$library_dest/"

  # Copy needed libraries per project
  mkdir -p "04-Controller/Scripts"
  library_dest=`realpath "./04-Controller/Scripts"`
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_libero.pl"    "$library_dest/"
  cp -arf "$library_source/start_libero.pl"     "$library_dest/"


# SEm Labs has also a different project structure
elif [ "$project" == "sem_labs" ]; then
  # Copy needed libraries per project
  mkdir -p "01-WaveformGenerator/Scripts"
  library_dest=`realpath "./01-WaveformGenerator/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

  mkdir -p "02-SplineInterpolator/Scripts"
  library_dest=`realpath "./02-SplineInterpolator/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

  mkdir -p "03-DigitalToAnalogConverter/Scripts"
  library_dest=`realpath "./03-DigitalToAnalogConverter/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

    mkdir -p "04-Lissajous/Scripts"
  library_dest=`realpath "./04-Lissajous/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

    mkdir -p "05-Morse/Scripts"
  library_dest=`realpath "./05-Morse/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

    mkdir -p "06-07-08-09-SystemOnChip/Scripts"
  library_dest=`realpath "./06-07-08-09-SystemOnChip/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

    mkdir -p "10-PipelinedOperators/Scripts"
  library_dest=`realpath "./10-PipelinedOperators/Scripts"`
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"

else
  mkdir -p "Scripts"
  library_dest=`realpath "./Scripts"`

  # Copy needed libraries per project
  echo "Update files in student repo $project"
  echo "    Copy scripts for Windows"
  cp -arf "$library_source/hdlDesigner.bat"     "$library_dest/"
  cp -arf "$library_source/cleanScratch.bat"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bat"  "$library_dest/"
  cp -arf "$library_source/searchPaths.bat"     "$library_dest/"
  echo "    Copy scripts for Linux"
  cp -arf "$library_source/hdlDesigner.bash"    "$library_dest/"
  cp -arf "$library_source/cleanGenerated.bash" "$library_dest/"
  echo "    Copy perl scripts for HDL Designer"
  cp -arf "$library_source/trimLibs.pl"         "$library_dest/"
  cp -arf "$library_source/update_ise.pl"       "$library_dest/"
  cp -arf "$library_source/update_libero.pl"    "$library_dest/"
  cp -arf "$library_source/start_libero.pl"     "$library_dest/"
fi

# add/commit/push changes to student repo
echo "    Git: Add => Commit => Push"
git add -A
git commit -a -m "$DATE: Automatic Scripts Update with ``deployScripts.bash`` :shipit:"
git push origin master
cd ..

# Delete tmp directory
cd ..
echo "    Delete tmp directory"
rm -rf "./tmp"

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- $DATE: $project updated at $repo"
echo "$SEPARATOR"
popd