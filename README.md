# osm-integration

**!!!EXPERIMENTAL!!!** Scripts [import.sh](import.sh) et [update.sh](update.sh) pour les chargements des données OSM dans PostgreSQL s'appuyant sur [osm2pgsql](https://osm2pgsql.org/doc/manual.html) et [osm2pgsql-replication](https://osm2pgsql.org/doc/man/osm2pgsql-replication-1.9.1.html).

## Prérequis

* Instance PostgreSQL avec tuning adéquat
* osm2pgsql unzip gdal-bin python3-psycopg2

## Principaux scripts

* [install.sh](install.sh) : utilisation des utilitaires (osm2pgsql, unzip, gdal-bin,...)
* [import.sh](import.sh) : import initial des données
* [update.sh](update.sh) : mise à jour des données

## Paramétrage

La connexion à la base de données s'appuie sur les variables d'environnements standards de PostgreSQL (PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE,...).

| Variable           | Description                                    | Valeur par défaut                                          |
| ------------------ | ---------------------------------------------- | ---------------------------------------------------------- |
| **OSM_PLANET_URL** | URL du fichier PBF pour [import.sh](import.sh) | https://download.geofabrik.de/europe/monaco-latest.osm.pbf |
| OSM_DATA_DIR       | Dossier de téléchargement des données          | `${SCRIPT_DIR}/data`                                       |


## Utilisation

```bash
# configuration de l'accès à la base de données
export PGHOST=localhost
export PGUSER=postgres
export PGPORT=5432
export PGPASSWORD=ChangeIt

# valeur par défaut
export CACHE_SIZE=2000
export OSM_PLANET_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf

# France
#export CACHE_SIZE=6000
#export OSM_PLANET_URL=https://download.geofabrik.de/europe/france-latest.osm.pbf

# Espagne
#export CACHE_SIZE=2000
#export OSM_PLANET_URL=http://download.geofabrik.de/europe/spain-latest.osm.pbf

# Côte d'ivoire
#export OSM_PLANET_URL=https://download.geofabrik.de/africa/ivory-coast-latest.osm.pbf

# Monde entier
#export USE_FLAT_NODES=1
#export OSM_PLANET_URL=https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf

bash osm2pgsql/import.sh
```

## Utlisation avec docker

Voir [docker-compose.yaml](docker-compose.yaml) qui permet de **tester en local** comme suit :

```bash
# Construire l'image
docker compose build

# Démarrer la stack avec osm-integration en mode terminal
docker compose up -d

# Se connecter à osm-integration en mode terminal
docker compose exec terminal /bin/bash
#... on est alors dans le conteneur :

# Vérifier l'accès à la BDD
psql -l

# Importer les données
export CACHE_SIZE=2000
export OSM_PLANET_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf

bash import.sh
```


## TODO

* Ajouter une option `USE_FLAT_NODES` à false par défaut
* Créer un utilisateur "osmrw" et un utilisateur "osmro"
* Vérifier la possibilité de faire le lien avec un serveur de tuile (invalidation des tuiles)

## Licence

[MIT](LICENSE)

## Ressources

* [download.geofabrik.de - OpenStreetMap Data Extracts](https://download.geofabrik.de/)
* [osm2pgsql.org - OSM2PGSQL MANUAL](https://osm2pgsql.org/doc/manual.html)
* [osm2pgsql.org - osm2pgsql-replication](https://osm2pgsql.org/doc/man/osm2pgsql-replication-1.9.1.html)
* [jakobmiksch.eu - Update an OSM database with osm2pgsql](https://jakobmiksch.eu/post/osm2pgsql-replication-script/)

