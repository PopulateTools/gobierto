#!/bin/bash

engine_name="custom-field-plugins-engine"

echo "Running setup script for $engine_name"
while getopts ":d:" opt; do
  case $opt in
    d) opt_dir=$OPTARG ;;
  esac
done

dev_dir=${opt_dir:-$DEV_DIR}

if [ -z "$dev_dir" ]
then
  echo "Please set DEV_DIR in your .bash_profile before running this script or invoke it with -d dev_dir, where dev_dir is the path containing gobierto";
else
  engines_path=${GOBIERTO_ENGINES_PATH:-"$DEV_DIR/gobierto/vendor/gobierto_engines"}
  source_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
  echo "Using dev_dir: $dev_dir"
  echo "Using engines_path: $engines_path"

  echo "Creating symlinks..."
  echo "executing ln -s $source_path $engines_path"
  ln -F -s $source_path $engines_path

  $source_path/script/create_engine_symlinks.sh -d $dev_dir/gobierto

  echo "executing ln -s $dev_dir/gobierto/node_modules $source_path"
  ln -F -s $dev_dir/gobierto/node_modules $source_path

  echo "[OK]"
fi
