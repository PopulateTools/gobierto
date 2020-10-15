#!/bin/bash

# Reference: config/database.yml
if [ "$ENV" == "development" ]; then
    PG_DATABASE="gobierto_development"
elif [ "$ENV" == "test" ]; then
    PG_DATABASE="gobierto_test"
elif [ "$ENV" == "staging" ]; then
    PG_DATABASE="gobierto_staging"
else
    PG_DATABASE="gobierto_production"
fi

export PGPASSWORD=$PG_PASSWORD
psql -h $PG_HOST -U $PG_USERNAME -d $PG_DATABASE -c '\q'
RESULT=$?
if [ "$RESULT" == "1" ] && [ ! -f $PWD/db/.create-finish ]; then
    echo -e "\e[35mSetup database postgresql and ElastickSearch\e[39m"
    cd $PWD
    $PWD/bin/rails db:setup

    $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:reset
    $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:create
    $PWD/bin/rails gobierto_budgets:fixtures:load
    echo '::BudgetsSeeder.seed!' | $PWD/bin/rails c
    touch $PWD/db/.create-finish
fi
