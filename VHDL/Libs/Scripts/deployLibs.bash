#!/bin/bash

#================================================================================
# deployLibs.bash - updates github repos for individual labos
# indend to push libs from [eda_libs](https://gitlab.hevs.ch/course/ElN/eda_libs.git)
# Example usage 1: ./Scripts/deployLibs.bash -v -p synd_eln_labs -r https://github.com/hei-synd-2131-eln/eln_labs.git
# Example usage 2: ./Scripts/deployLibs.bash -v -p ete_eln_labs -r https://github.com/hei-ete-8132-eln/eln_labs.git
# Example usage 3: ./Scripts/deployLibs.bash -v -p eln_chrono -r https://github.com/hei-synd-2131-eln/eln_chrono.git
# Example usage 4: ./Scripts/deployLibs.bash -v -p eln_cursor -r https://github.com/hei-synd-2131-eln/eln_cursor.git
# Example usage 5: ./Scripts/deployLibs.bash -v -p eln_inverter -r https://github.com/hei-ete-8132-eln/eln_inverter.git
# Example usage 6: ./Scripts/deployLibs.bash -v -p eln_synchro -r https://github.com/hei-ete-8132-eln/eln_synchro.git
# Example usage 7: ./Scripts/deployLibs.bash -v -p sem_labs -r https://github.com/hei-synd-225-sem/sem_labs.git
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
# [ete_eln_labs](https://github.com/hei-ete-8132-eln/eln_labs.git)
# [ele_labs]()
# [sem_labs](https://github.com/hei-synd-225-sem/sem_labs.git)
# [eln_cursor](https://github.com/hei-synd-2131-eln/eln_cursor.git)
# [eln_chrono](https://github.com/hei-synd-2131-eln/eln_chrono.git)
# [eln_kart(https://github.com/hei-synd-2131-eln/eln_kart.git)
# [eln_inverter](https://github.com/hei-ete-8132-eln/eln_inverter.git)
# [eln_synchro](https://github.com/hei-ete-8132-eln/eln_synchro.git)
# [eln_support]()
# [eptm_radio]()
# [eptm_audioamp]()
# [cansat]()
project='eln_labs'
repo='https://github.com/hei-synd-2131-eln/eln_labs.git'

usage='Usage: deployLibs.bash [-p projectName] [-r repourl] [-v] [-h]'
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
  echo "-- $DATE: Deploy Libraries for Students"
  echo "${INDENT}for $project"
  echo "${INDENT}to $repo"
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

library_dest=`realpath "./Libs"`
library_source=`realpath "./../../.."`
mkdir -p $library_dest

# Copy needed libraries per project
echo "Update files in student repo $project"
if [ "$project" == "synd_eln_labs" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, NanoBlaze"
  cp -arf "$library_source/Gates/"          "$library_dest/"
  cp -arf "$library_source/IO/"             "$library_dest/"
  cp -arf "$library_source/Sequential/"     "$library_dest/"
  cp -arf "$library_source/Common/"         "$library_dest/"
  cp -arf "$library_source/Common_test/"    "$library_dest/"
  cp -arf "$library_source/NanoBlaze/"      "$library_dest/"
elif [ "$project" == "ete_eln_labs" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Operators, Common, NanoBlaze"
  cp -arf "$library_source/Gates/"          "$library_dest/"
  cp -arf "$library_source/IO/"             "$library_dest/"
  cp -arf "$library_source/Sequential/"     "$library_dest/"
  cp -arf "$library_source/Operators/"      "$library_dest/"
  cp -arf "$library_source/Common/"         "$library_dest/"
  cp -arf "$library_source/Common_test/"    "$library_dest/"
  cp -arf "$library_source/NanoBlaze/"      "$library_dest/"
elif [ "$project" == "ele_labs" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Operators, Common, Memory, Modulation, NanoBlaze"
  cp -ar "$library_source/Gates"           "$library_dest/"
  cp -ar "$library_source/IO"              "$library_dest/"
  cp -ar "$library_source/Sequential"      "$library_dest/"
  cp -ar "$library_source/Operators"       "$library_dest/"
  cp -ar "$library_source/Common"          "$library_dest/"
  cp -ar "$library_source/Common_test"     "$library_dest/"
  cp -ar "$library_source/Memory"          "$library_dest/"
  cp -ar "$library_source/Memory_test"     "$library_dest/"
  cp -ar "$library_source/Modulation"      "$library_dest/"
  cp -ar "$library_source/Modulation_test" "$library_dest/"
  cp -ar "$library_source/NanoBlaze"       "$library_dest/"
  cp -ar "$library_source/NanoBlaze_test"  "$library_dest/"
elif [ "$project" == "sem_labs" ]; then
  echo "    Copy libraries: Common, RS232, AhbLite, Memory, RiscV, NanoBlaze"
  cp -ar "$library_source/Common"         "$library_dest/"
  cp -ar "$library_source/Common_test"    "$library_dest/"
  cp -ar "$library_source/RS232"          "$library_dest/"
  cp -ar "$library_source/RS232_test"     "$library_dest/"
  cp -ar "$library_source/AhbLite"        "$library_dest/"
  cp -ar "$library_source/AhbLite_test"   "$library_dest/"
  cp -ar "$library_source/Memory"         "$library_dest/"
  cp -ar "$library_source/Memory_test"    "$library_dest/"
  cp -ar "$library_source/RiscV"          "$library_dest/"
  cp -ar "$library_source/RiscV_test"     "$library_dest/"
  cp -ar "$library_source/NanoBlaze"      "$library_dest/"
  cp -ar "$library_source/NanoBlaze_test" "$library_dest/"
elif [ "$project" == "eln_cursor" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, Lcd, Memory"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/Lcd"         "$library_dest/"
  cp -ar "$library_source/Lcd_test"    "$library_dest/"
  cp -ar "$library_source/Memory"      "$library_dest/"
  cp -ar "$library_source/Memory_test" "$library_dest/"
elif [ "$project" == "eln_chrono" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, Lcd, Memory, RS232"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/Lcd"         "$library_dest/"
  cp -ar "$library_source/Lcd_test"    "$library_dest/"
  cp -ar "$library_source/Memory"      "$library_dest/"
  cp -ar "$library_source/Memory_test" "$library_dest/"
  cp -ar "$library_source/RS232"       "$library_dest/"
  cp -ar "$library_source/RS232_test"  "$library_dest/"
elif [ "$project" == "eln_kart" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, Lcd, Memory, RS232"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/I2C"         "$library_dest/"
  cp -ar "$library_source/I2C_test"    "$library_dest/"
  cp -ar "$library_source/Memory"      "$library_dest/"
  cp -ar "$library_source/Memory_test" "$library_dest/"
  cp -ar "$library_source/RS232"       "$library_dest/"
  cp -ar "$library_source/RS232_test"  "$library_dest/"
elif [ "$project" == "eln_inverter" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, Cordic"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Operators"   "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/Cordic"      "$library_dest/"
  cp -ar "$library_source/Cordic_test" "$library_dest/"
elif [ "$project" == "eln_support" ]; then
  echo "Nothing todo, no Libararies needed"
elif [ "$project" == "eln_synchro" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common, Memory, RS232"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/Memory"      "$library_dest/"
  cp -ar "$library_source/Memory_test" "$library_dest/"
  cp -ar "$library_source/RS232"       "$library_dest/"
  cp -ar "$library_source/RS232_test"  "$library_dest/"
elif [ "$project" == "eptm_radio" ]; then
  echo "    Copy libraries: Gates, IO, Sequential, Common"
  cp -ar "$library_source/Gates"       "$library_dest/"
  cp -ar "$library_source/IO"          "$library_dest/"
  cp -ar "$library_source/Sequential"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
elif [ "$project" == "eptm_audioamp" ]; then
  echo "    Copy libraries: AD_DA, Common, Filter"
  cp -ar "$library_source/AD_DA"       "$library_dest/"
  cp -ar "$library_source/AD_DA_test"  "$library_dest/"
  cp -ar "$library_source/Common"      "$library_dest/"
  cp -ar "$library_source/Common_test" "$library_dest/"
  cp -ar "$library_source/Filter"      "$library_dest/"
  cp -ar "$library_source/Filter_test" "$library_dest/"
elif [ "$project" == "cansat" ]; then
  echo "    Copy libraries: AhbLite, AhbLiteComponents, Common, Commandline, Memory, NanoBlaze, RS232"
  cp -ar "$library_source/AhbLite"                "$library_dest/"
  cp -ar "$library_source/AhbLite_test"           "$library_dest/"
  cp -ar "$library_source/AhbLiteComponents"      "$library_dest/"
  cp -ar "$library_source/AhbLiteComponents_test" "$library_dest/"
  cp -ar "$library_source/Common"                 "$library_dest/"
  cp -ar "$library_source/Commandline"            "$library_dest/"
  cp -ar "$library_source/Commandline_test"       "$library_dest/"
  cp -ar "$library_source/Memory"                 "$library_dest/"
  cp -ar "$library_source/Memory_test"            "$library_dest/"
  cp -ar "$library_source/NanoBlaze"              "$library_dest/"
  cp -ar "$library_source/NanoBlaze_test"         "$library_dest/"
  cp -ar "$library_source/RS232"                  "$library_dest/"
  cp -ar "$library_source/RS232_test"             "$library_dest/"
fi

# add/commit/push changes to student repo
echo "    Git: Add => Commit => Push"
git add -A
git commit -a -m "$DATE: Automatic Library Update with ``deployLibs.bash`` :shipit:"
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