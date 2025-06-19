#!/bin/bash

shp2pgsql \
    -D \
    -I \
    -s 26918 \
    postgis-workshop/data/2000/nyc_census_blocks_2000.shp \
    nyc_census_blocks_2000 \
    | psql dbname=nyc user=postgres host=localhost 
