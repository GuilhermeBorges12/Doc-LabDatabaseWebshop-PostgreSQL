#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8

DB_NAME=$1

DATABASENAME=${1:-'mywebshop'}

echo "Restoring data to database $DATABASENAME"

createdb $DATABASENAME
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/create.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/products.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/articles.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/labels.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/customer.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/address.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/order.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/order_positions.sql
psql -h localhost -p 5432 -U postgres -d $DATABASENAME -f data/stock.sql