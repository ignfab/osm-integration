#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")

#--------------------------------------------------------------
# Compute static paths
#--------------------------------------------------------------
export OSM_INTEGRATION_DIR=${ROOT_DIR}
export OSM_STYLES_DIR=${ROOT_DIR}/styles
export OSM_CARTO_DIR=${OSM_STYLES_DIR}/openstreetmap-carto

#--------------------------------------------------------------
# Download openstreetmap-carto if required
#--------------------------------------------------------------
if [ ! -e "${OSM_CARTO_DIR}/openstreetmap-carto.style" ];
then
    bash "${SCRIPT_DIR}/get-styles.sh"
fi

#--------------------------------------------------------------
# Compute storage paths
#--------------------------------------------------------------
export OSM_DATA_DIR=${OSM_DATA_DIR:-${ROOT_DIR}/data}
# optionnal (only for USE_FLAT_NODES)
export OSM_FLAT_NODES_PATH=${OSM_DATA_DIR}/nodes.raw


#--------------------------------------------------------------
# static osm2pgsql options
#--------------------------------------------------------------
OSM2PGSQL_OPTS="--slim --hstore --multi-geometry"

LOG_PROGRESS=${LOG_PROGRESS:-1}
echo "[INFO] LOG_PROGRESS=${LOG_PROGRESS}"
if [ "$LOG_PROGRESS" != "0" ];
then
    OSM2PGSQL_OPTS="${OSM2PGSQL_OPTS} --log-progress=true"
else
    OSM2PGSQL_OPTS="${OSM2PGSQL_OPTS} --log-progress=false"
fi

#--------------------------------------------------------------
# Handle options for --flat-nodes and --cache
#--------------------------------------------------------------

USE_FLAT_NODES=${USE_FLAT_NODES:-0}
echo "[INFO] USE_FLAT_NODES=${USE_FLAT_NODES}"
if [ "$USE_FLAT_NODES" != "0" ];
then
    OSM2PGSQL_OPTS="--flat-nodes ${OSM_FLAT_NODES_PATH}"
fi

# Use CACHE_SIZE=0 with USE_FLAT_NODES 
CACHE_SIZE=${CACHE_SIZE:-2000}
echo "[INFO] CACHE_SIZE=${CACHE_SIZE}"
OSM2PGSQL_OPTS="${OSM2PGSQL_OPTS} --cache=$CACHE_SIZE"

#--------------------------------------------------------------
# Compute storage paths
#--------------------------------------------------------------
export OSM2PGSQL_OPTS
