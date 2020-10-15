#!/bin/bash
set -e

cd $PWD
echo -e "[INFO] Recovery gems"
$PWD/bin/bundle install --binstubs=$PWD/bin --gemfile=$PWD/Gemfile --path=$PWD

echo -e "[INFO] Check health of keys"
$PWD/bin/i18n-tasks normalize
$PWD/bin/i18n-tasks health
