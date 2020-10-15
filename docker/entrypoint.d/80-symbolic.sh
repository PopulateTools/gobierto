#!/bin/bash
set -e

export SECRET_KEY_BASE=$(rake secret)
export ROLLBAR_ACCESS_TOKEN=$(rake secret)
echo -e "[INFO] Execute Pre-Webpack"
yarn install
if [[ ! -f $PWD/node_modules/css-loader/index.js ]]; then
  if [[ $RAILS_ENV == "production" ]]; then
      $PWD/bin/webpack --verbose --mode production --config /gobierto/config/webpack/production.js
  else
      $PWD/bin/webpack --verbose
  fi
fi

if [[ ! $(stat $PWD/app/javascript/packs/custom_fields_data_grid_plugin.js | grep -o 'symbolic link') ]]; then
    echo -e "[INFO] Create symbolic link $PWD/vendor/gobierto_engines/custom-fields-data-grid-plugin"
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-data-grid-plugin/app/javascripts/packs/custom_fields_data_grid_plugin.js \
      $PWD/app/javascript/packs
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-data-grid-plugin/app/javascripts/custom_fields_data_grid_plugin \
      $PWD/app/javascript
fi

if [[ ! $(stat $PWD/app/javascript/packs/custom_fields_progress_plugin.js | grep -o 'symbolic link') ]]; then
    echo -e "[INFO] Create symbolic link $PWD/vendor/gobierto_engines/custom-fields-progress-plugin"
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-progress-plugin/app/javascripts/packs/custom_fields_progress_plugin.js º
      $PWD/app/javascript/packs
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-progress-plugin/app/javascripts/custom_fields_progress_plugin \
      $PWD/app/javascript
fi

if [[ ! $(stat $PWD/app/javascript/packs/custom_fields_table_plugin.js | grep -o 'symbolic link') ]]; then
    echo -e "[INFO] Create symbolic link $PWD/vendor/gobierto_engines/custom-fields-table-plugin"
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-table-plugin/app/javascripts/packs/custom_fields_table_plugin.js \
      $PWD/app/javascript/packs
    ln -s \
      $PWD/vendor/gobierto_engines/custom-fields-table-plugin/app/javascripts/custom_fields_table_plugin \
      $PWD/app/javascript
fi

if [[ ! $(stat $PWD/node_modules | grep -o 'symbolic link') ]]; then
    echo -e "[INFO] Create symbolic link of all modules from gobierto_engines and i18n"
    ln -F -s \
      $PWD/vendor/gobierto_engines/ \
      $PWD/node_modules
    ln -s \
      $PWD/ruby/2.7.0/gems/i18n-js-3.7.1/app/assets/javascripts/i18n/ \
      $PWD/app/javascript/lib/i18n/modules
fi
