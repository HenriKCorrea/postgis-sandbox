#!/bin/bash

ogr2ogr \
    -nln nyc_census_blocks_2000 \
    -nlt PROMOTE_TO_MULTI \
    -lco GEOMETRY_NAME=geom \
    -lco FID=gid \
    -lco PRECISION=NO \
    Pg:'dbname=nyc host=localhost user=postgres password=secret port=5432' \
    postgis-workshop/data/2000/nyc_census_blocks_2000.shp
