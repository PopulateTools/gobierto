#!/bin/bash

# Reference: config/database.yml
if [ "$RAILS_ENV" == "development" ]; then
    PG_DATABASE="gobierto_development"
elif [ "$RAILS_ENV" == "test" ]; then
    PG_DATABASE="gobierto_test"
elif [ "$RAILS_ENV" == "staging" ]; then
    PG_DATABASE="gobierto_staging"
else
    PG_DATABASE="gobierto_production"
fi

# Check PostgreSQL
if PGPASSWORD=$PG_PASSWORD psql -h $PG_HOST -U $PG_USERNAME -d postgres -c '\q'; then
    echo -e "[INFO] Check Database: Ready"

    PG_DATABASE_CHECK=$(PGPASSWORD=$PG_PASSWORD psql -t -h $PG_HOST -U $PG_USERNAME \
      -d postgres \
      -c "SELECT datname FROM pg_database WHERE datname='$PG_DATABASE';")

    # If not exist database and file .create-finish execute setup
    if [ "$PG_DATABASE_CHECK" == "$PG_DATABASE" ]; then
        echo -e "[INFO] Database found: $PG_DATABASE, will not be created"
    else
        echo -e "[INFO] Create database $PG_DATABASE"
        if [ ! -f $PWD/db/.create-finish ]; then
            set -e
            echo -e "[INFO] Setup database PostgreSQL"
            cd $PWD
            $PWD/bin/rails db:setup
            
            echo -e "[INFO] Setup database ElastickSearch"
            $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:reset
            $PWD/bin/rails gobierto_budgets:elastic_search_schemas:manage:create
            $PWD/bin/rails gobierto_budgets:fixtures:load
            echo '::BudgetsSeeder.seed!' | $PWD/bin/rails c
            touch $PWD/db/.create-finish
            set +e
        else
            echo -e "[INFO] File found: $PWD/db/.create-finish, \
              will not create database PostgreSQL and ElastickSearch"
        fi
    fi

else
    echo -e "[WARNING] Check Database: Not ready"
fi
