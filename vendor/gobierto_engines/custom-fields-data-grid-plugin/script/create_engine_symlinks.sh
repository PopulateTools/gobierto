#!/bin/bash

engine_webpack_entry_path="app/javascripts/packs/custom_fields_data_grid_plugin.js"
engine_webpack_source_path="app/javascripts/custom_fields_data_grid_plugin"

echo "Running engine setup"

while getopts ":d:" opt; do
  case $opt in
    d) opt_dir=$OPTARG ;;
  esac
done
gobierto_dir=${opt_dir:-"$DEV_DIR/gobierto"}

if [ -z "$gobierto_dir" ]
then
  echo "Please set DEV_DIR in your .bash_profile before running this script or invoke it with -d gobierto_dir, where gobierto_dir is the path of gobierto release";
else
  source_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

  gobierto_webpack_source_path="$gobierto_dir/app/javascript"

  echo "    Creating engine symlinks..."

  echo "    executing ln -s $source_path/$engine_webpack_entry_path $gobierto_webpack_source_path"
  ln -s $source_path/$engine_webpack_entry_path $gobierto_webpack_source_path

  echo "    executing ln -s $source_path/$engine_webpack_source_path $gobierto_webpack_source_path"
  ln -s $source_path/$engine_webpack_source_path $gobierto_webpack_source_path

  echo "    [OK]"
fi
