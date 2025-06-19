#!/bin/bash

# Run psql command with predefined parameters
function run_psql {
    PGPASSWORD="secret" psql -h "localhost" -U "postgres" -w "$@"
}
