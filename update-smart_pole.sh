#!/bin/bash

# Retrieve full path of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import functions
source "$SCRIPT_DIR/functions.sh"

# Update smart_pole table with random data
# This script runs indefinitely, updating the smart_pole table every 10 seconds
while true; do
  run_psql -c "SELECT update_smart_pole_random();"
  sleep 10
done