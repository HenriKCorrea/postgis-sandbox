#!/bin/bash

podman run -it --rm --network postgis-sandbox_some-network docker.io/postgis/postgis:17-3.5-alpine psql -h some-postgis -U postgres
