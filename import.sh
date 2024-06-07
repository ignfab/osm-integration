#!/bin/bash

#--------------------------------------------------------------
# Compute paths
#--------------------------------------------------------------

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

OSM_STYLES_DIR=${SCRIPT_DIR}/styles
OSM_CARTO_DIR=${OSM_STYLES_DIR}/openstreetmap-carto

#--------------------------------------------------------------
# Handle import / update options
#--------------------------------------------------------------
OSM_DATA_DIR=${OSM_DATA_DIR:-${SCRIPT_DIR}/data}
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

echo "[DEBUG] OPTS_CACHE=${OPTS_CACHE}"

#--------------------------------------------------------------
# Handle import specific options
#--------------------------------------------------------------

OSM_PLANET_URL=${OSM_PLANET_URL:-https://download.geofabrik.de/europe/monaco-latest.osm.pbf}
echo "[INFO] OSM_PLANET_URL=${OSM_PLANET_URL}"

FORCE_DOWNLOAD=${FORCE_DOWNLOAD:-0}
echo "[INFO] FORCE_DOWNLOAD=${FORCE_DOWNLOAD}"

#--------------------------------------------------------------
# Create osm database
#--------------------------------------------------------------
createdb $PGDATABASE
CREATE_DB=${CREATE_DB:-1}
echo "[INFO] CREATE_DB=${CREATE_DB}"

#--------------------------------------------------------------
# Create osm database
#--------------------------------------------------------------
createdb $PGDATABASE
psql -d $PGDATABASE -c "CREATE EXTENSION IF NOT EXISTS postgis"
psql -d $PGDATABASE -c "CREATE EXTENSION IF NOT EXISTS hstore"

#--------------------------------------------------------------
# Download openstreetmap-carto if required
#--------------------------------------------------------------
if [ ! -e "${OSM_CARTO_DIR}/openstreetmap-carto.style" ];
then
    bash "${SCRIPT_DIR}/get-styles.sh"
fi

#--------------------------------------------------------------
# Download external data
#--------------------------------------------------------------
cd "${OSM_CARTO_DIR}"
python3 "scripts/get-external-data.py" \
    --database $PGDATABASE \
    --verbose

#--------------------------------------------------------------
# Download OSM data
#--------------------------------------------------------------
mkdir -p $OSM_DATA_DIR
if [ ! -e "$OSM_DATA_DIR/osm.pbf" ] || [ "$FORCE_DOWNLOAD" != "0" ] ;
then
    wget -O "$OSM_DATA_DIR/osm.pbf" $OSM_PLANET_URL
fi

#--------------------------------------------------------------
# Remove existing flat-nodes
#--------------------------------------------------------------
rm -rf "${OSM_FLAT_NODES_PATH}"

#--------------------------------------------------------------
# Import OSM file to PostgreSQL
# --flat-nodes="${OSM_DATA_DIR}/nodes.raw" --cache=0
#--------------------------------------------------------------
osm2pgsql \
    --database=$PGDATABASE \
    --slim \
    --hstore \
    --multi-geometry \
    --log-progress=true \
    ${OPTS_CACHE} \
    --style="${OSM_CARTO_DIR}/openstreetmap-carto.style" \
    --tag-transform-script="${OSM_CARTO_DIR}/openstreetmap-carto.lua" \
    "$OSM_DATA_DIR/osm.pbf"

#--------------------------------------------------------------
# Init replication table
#--------------------------------------------------------------
osm2pgsql-replication init \
    --database=$PGDATABASE \
    --osm-file "$OSM_DATA_DIR/osm.pbf"

#--------------------------------------------------------------
# Create indexes
#--------------------------------------------------------------
python3 "${OSM_CARTO_DIR}/scripts/indexes.py"

