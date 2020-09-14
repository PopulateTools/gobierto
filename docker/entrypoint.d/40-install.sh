#!/bin/bash
cd $PWD
echo -e "\e[33mRecovery gems\e[39m"
$PWD/bin/bundle install --binstubs=$PWD/bin --gemfile=$PWD/Gemfile --path=$PWD

echo -e "\e[33mCheck health of keys\e[39m"
$PWD/bin/i18n-tasks normalize
$PWD/bin/i18n-tasks health
