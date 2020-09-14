#!/bin/bash

if [ ! -f $PWD/db/.create-finish ]; then
    echo -e "\e[35mSetup database postgresql and ElastickSearch\e[39m"
    cd $PWD
    $PWD/bin/rails db:setup

    $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:reset
    $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:create
    $PWD/bin/rails gobierto_budgets:fixtures:load
    echo '::BudgetsSeeder.seed!' | $PWD/bin/rails c
    touch $PWD/db/.create-finish
fi
