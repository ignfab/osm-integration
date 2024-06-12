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

echo "[DEBUG] OSM2PGSQL_OPTS=${OSM2PGSQL_OPTS}"

#--------------------------------------------------------------
# Handle import specific options
#--------------------------------------------------------------

OSM_PLANET_URL=${OSM_PLANET_URL:-https://download.geofabrik.de/europe/monaco-latest.osm.pbf}
echo "[INFO] OSM_PLANET_URL=${OSM_PLANET_URL}"

FORCE_DOWNLOAD=${FORCE_DOWNLOAD:-0}
echo "[INFO] FORCE_DOWNLOAD=${FORCE_DOWNLOAD}"

CREATE_DB=${CREATE_DB:-1}
echo "[INFO] CREATE_DB=${CREATE_DB}"

#--------------------------------------------------------------
# Create osm database
#--------------------------------------------------------------
if [ "$CREATE_DB" != "0" ];
then
    createdb "$PGDATABASE"
    psql -d "$PGDATABASE" -c "CREATE EXTENSION IF NOT EXISTS postgis"
    psql -d "$PGDATABASE" -c "CREATE EXTENSION IF NOT EXISTS hstore"
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
mkdir -p "$OSM_DATA_DIR"
if [ ! -e "$OSM_DATA_DIR/osm.pbf" ] || [ "$FORCE_DOWNLOAD" != "0" ] ;
then
    wget -O "$OSM_DATA_DIR/osm.pbf" "$OSM_PLANET_URL"
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
    --slim --hstore --multi-geometry \
    --log-progress=true \
    ${OSM2PGSQL_OPTS} \
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

