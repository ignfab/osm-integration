#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "${SCRIPT_DIR}/setenv.sh" || { 
    exit 1 
}

#--------------------------------------------------------------
# Handle import / update options
#--------------------------------------------------------------

PGDATABASE=${PGDATABASE:-osm}
echo "[INFO] PGDATABASE=${PGDATABASE}"

echo "[INFO] OSM2PGSQL_OPTS=${OSM2PGSQL_OPTS}"

#--------------------------------------------------------------
# Update OSM data in PostgreSQL
#--------------------------------------------------------------
osm2pgsql-replication update --verbose -- \
    --database=$PGDATABASE \
    --slim --hstore --multi-geometry \
    --log-progress=true \
    ${OSM2PGSQL_OPTS} \
    --style="${OSM_CARTO_DIR}/openstreetmap-carto.style" \
    --tag-transform-script="${OSM_CARTO_DIR}/openstreetmap-carto.lua"

