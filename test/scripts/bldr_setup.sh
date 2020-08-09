#!/bin/bash
pgpass=$(grep '^password' /hab/svc/builder-api/config/config.toml)
/hab/pkgs/core/postgresql/9.6.11/*/bin/psql --dbname=builder -c "insert into accounts (name, email) values ('test', 'noreply@localhost.localdomain');"
accountid=$(/hab/pkgs/core/postgresql/9.6.11/*/bin/psql  --dbname=builder -qtAX -c "select id from accounts where name = 'test';")
/hab/pkgs/core/postgresql/9.6.11/*/bin/psql --dbname=builder -c "insert into account_tokens (account_id, token) values ('${accountid}', '_abc123==');"
