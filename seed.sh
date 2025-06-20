#!/bin/bash

# Retrieve full path of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import functions
source "$SCRIPT_DIR/functions.sh"

# Create dataset table
run_psql -f "$SCRIPT_DIR/create-nyc_pole_location.sql"
run_psql -c "\copy nyc_pole_location(id,latitude,longitude,on_street,zipcode,installation_date) FROM '$SCRIPT_DIR/nyc_pole_location.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');"
run_psql -f "$SCRIPT_DIR/create-smart_pole.sql"
