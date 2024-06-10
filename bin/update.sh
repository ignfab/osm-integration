#!/bin/bash

#--------------------------------------------------------------
# Compute paths
#--------------------------------------------------------------

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")

OSM_STYLES_DIR=${ROOT_DIR}/styles
OSM_CARTO_DIR=${OSM_STYLES_DIR}/openstreetmap-carto

#--------------------------------------------------------------
# Handle import / update options
#--------------------------------------------------------------
OSM_DATA_DIR=${OSM_DATA_DIR:-${ROOT_DIR}/data}
# optionnal
OSM_FLAT_NODES_PATH=${OSM_DATA_DIR}/nodes.raw

PGDATABASE=${PGDATABASE:-osm}
echo "[INFO] PGDATABASE=${PGDATABASE}"

# handle cache options
CACHE_SIZE=${CACHE_SIZE:-2000}
echo "[INFO] CACHE_SIZE=${CACHE_SIZE}"
OPTS_CACHE="--cache=$CACHE_SIZE"

USE_FLAT_NODES=${USE_FLAT_NODES:-0}
echo "[INFO] USE_FLAT_NODES=${USE_FLAT_NODES}"
if [ "$USE_FLAT_NODES" != "0" ];
then
    OPTS_CACHE="--flat-nodes ${OSM_FLAT_NODES_PATH} --cache=0"
fi

echo "[INFO] OPTS_CACHE=${OPTS_CACHE}"

#--------------------------------------------------------------
# Download openstreetmap-carto if required
#--------------------------------------------------------------
if [ ! -e "${OSM_CARTO_DIR}/openstreetmap-carto.style" ];
then
    bash "${SCRIPT_DIR}/get-styles.sh"
fi

#--------------------------------------------------------------
# Update OSM data in PostgreSQL
#--------------------------------------------------------------
osm2pgsql-replication update --verbose -- \
    --database=$PGDATABASE \
    --slim \
    --hstore \
    --multi-geometry \
    --log-progress=true \
    ${OPTS_CACHE} \
    --style="${OSM_CARTO_DIR}/openstreetmap-carto.style" \
    --tag-transform-script="${OSM_CARTO_DIR}/openstreetmap-carto.lua"

