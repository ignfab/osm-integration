FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y curl ca-certificates \
 && install -d /usr/share/postgresql-common/pgdg \
 && curl -q -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
 && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y postgresql-client-15 \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y --no-install-recommends wget unzip gdal-bin python3-psycopg2 python3-pip osm2pgsql \
 && apt-get install -y --no-install-recommends osm2pgsql \
 && python3 -m pip install pyyaml \
 && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupadd -g "${GID}" osm \
 && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" osm

RUN mkdir -p /opt/osm-integration
WORKDIR /opt/osm-integration

COPY bin/ bin
RUN chmod +x bin/*.sh

RUN bash bin/get-styles.sh

RUN mkdir -p /opt/osm-integration/data \
 && chown -R osm:osm /opt/osm-integration/data
VOLUME /opt/osm-integration/data

RUN mkdir -p /opt/osm-integration/styles/openstreetmap-carto/data \
 && chown -R osm:osm /opt/osm-integration/styles/openstreetmap-carto/data
VOLUME /opt/osm-integration/styles/openstreetmap-carto/data

USER osm

