#!/bin/bash

#================================================================================
# changeDefaultViews.bash - change HDL Project views
# * Usage master => student: ``changeDefaultViews.bash -v -a masterVersion -n studentVersion``
# * Usage student => master: ``changeDefaultViews.bash -v -a studentVersion -n masterVersion``
# * Usage: add ``-r`` for deleting the specified actual view **dangerous**
#
base_directory="$(dirname "$(readlink -f "$0")")"
pushd $base_directory
base_directory="$base_directory/.."

SEPARATOR='--------------------------------------------------------------------------------'
INDENT='  '

echo "$SEPARATOR"
echo "-- ${0##*/} Started!"
echo ""

#--------------------------------------------------------------------------------
# Parse command line options
#
project_directory=''
actual_view='masterVersion'
new_view='studentVersion'

usage='Usage: changeDefaultViews.bash [-p projectDir] [-r] [-v] [-h]'
while getopts 'p:a:n:rvh' options; do
  case $options in
    p ) project_directory=$OPTARG;;
    a ) actual_view=$OPTARG;;
    n ) new_view=$OPTARG;;
    r ) delete_actual_view=1;;
    v ) verbose=1;;
    h ) echo -e $usage
          exit 1;;
    * ) echo -e $usage
          exit 1;;
  esac
done
if [ -z "$project_directory" ]; then
  project_directory="$base_directory"
else
  project_directory="$base_directory/$project_directory"
fi

#-------------------------------------------------------------------------------
# Display info
#
if [ -n "$verbose" ] ; then
  echo "$SEPARATOR"
  echo "Changing default views for HDL Designer"
  echo "${INDENT}in $project_directory"
  echo "${INDENT}from $actual_view to $new_view"
  if [ -n "$delete_actual_view" ] ; then
    echo "Delete all $actual_view in $project_directory"
  fi
fi

#-------------------------------------------------------------------------------
# Remove generated and cache files
#
./cleanGenerated.bash

#-------------------------------------------------------------------------------
# Change views in configuration files
#
find $project_directory -type f -name '*._epf' \
  | xargs sed -i "s/$actual_view/$new_view/g"

#-------------------------------------------------------------------------------
# Remove all acutal views File
#
if [ -n "$delete_actual_view" ] ; then
  project_directory=`realpath $project_directory`
  echo $project_directory
  echo "Delete $actual_view"
  find $project_directory/ -type f -iname "*$actual_view*" -exec echo "rm {}" \;
  find $project_directory/ -type f -iname "*$actual_view*" -exec rm {} \;
  # For HDL Designer file naming convention
  # making uppercase letters to @lowercase masterVersion = master@version
  actual_view="$(sed -E s/\([A-Z]\)/@\\L\\1/g <<< $actual_view)"
  find $project_directory/ -type f -name "*$actual_view*" -exec echo "rm {}" \;
  find $project_directory/ -type f -name "*$actual_view*" -exec rm {} \;

fi

#-------------------------------------------------------------------------------
# Exit
#
echo ""
echo "-- ${0##*/} Finished!"
echo "$SEPARATOR"
popd