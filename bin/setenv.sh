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
# optionnal
export OSM_FLAT_NODES_PATH=${OSM_DATA_DIR}/nodes.raw

#--------------------------------------------------------------
# Handle options for --cache and --flat-nodes
#--------------------------------------------------------------
CACHE_SIZE=${CACHE_SIZE:-2000}
echo "[INFO] CACHE_SIZE=${CACHE_SIZE}"
OSM2PGSQL_OPTS="--cache=$CACHE_SIZE"

USE_FLAT_NODES=${USE_FLAT_NODES:-0}
echo "[INFO] USE_FLAT_NODES=${USE_FLAT_NODES}"
if [ "$USE_FLAT_NODES" != "0" ];
then
    OSM2PGSQL_OPTS="--flat-nodes ${OSM_FLAT_NODES_PATH} --cache=0"
fi

#--------------------------------------------------------------
# Compute storage paths
#--------------------------------------------------------------
export OSM2PGSQL_OPTS
