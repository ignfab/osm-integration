# osm-integration

**!!!EXPERIMENTAL!!!** Scripts d'import et de mise à jour des données OSM dans PostgreSQL s'appuyant sur [osm2pgsql](https://osm2pgsql.org/doc/manual.html) et [osm2pgsql-replication](https://osm2pgsql.org/doc/man/osm2pgsql-replication-1.9.1.html).

## Prérequis

* Instance PostgreSQL avec tuning adéquat
* python3-psycopg2
* osm2pgsql
* unzip
* gdal-bin

## Principaux scripts

* [install.sh](install.sh) : utilisation des utilitaires (osm2pgsql, unzip, gdal-bin,...)
* [bin/import.sh](bin/import.sh) : import initial des données
* [bin/update.sh](bin/update.sh) : mise à jour des données

## Paramétrage

La connexion à la base de données s'appuie sur les variables d'environnements standards de PostgreSQL (PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE,...).

| Variable           | Description                                                        | Valeur par défaut                                          |
| ------------------ | ------------------------------------------------------------------ | ---------------------------------------------------------- |
| **OSM_PLANET_URL** | URL du fichier PBF utilisée uniquement pour l'import               | https://download.geofabrik.de/europe/monaco-latest.osm.pbf |
| OSM_DATA_DIR       | Dossier de téléchargement des données                              | `./data`                                                   |
| CACHE_SIZE         | Permet d'adapter la taille du cache pour les noeuds                | `2000` (1)                                                 |
| USE_FLAT_NODES     | Permet d'activer `--flat-nodes=${OSM_DATA_DIR}/nodes.raw`          | `0` (2)                                                    |
| CREATE_DB          | Permet de désactiver la création automatique de la base de données | `0`                                                        |
| LOG_PROGRESS       | Permet de désactiver le reporting de la progression                | `1`                                                        |

Remarques :

* (1) Voir [osm2pgsql.org - Caching](https://osm2pgsql.org/doc/manual.html#caching), compter `20000` pour import monde (soit 20Gi)
* (2) Il faut alors conserver le fichier `${OSM_DATA_DIR}/nodes.raw` qui remplace la table `planet_osm_nodes`


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

bash bin/import.sh
```

## Utlisation avec docker

Voir [docker-compose.yaml](docker-compose.yaml) qui permet de **tester en local** comme suit :

```bash
# Construire l'image
docker compose build

# Démarrer la stack avec osm-integration en mode terminal
docker compose up -d

# Configurer l'import
export OSM_PLANET_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf
export CACHE_SIZE=2000
docker compose run integration bin/update.sh

# Mettre à jour les données
docker compose run integration bin/update.sh
```

Pour le debug :

```bash
# Se connecter à osm-integration en mode terminal
docker compose exec integration /bin/bash
#... on est alors dans le conteneur :

# Vérifier l'accès à la BDD
psql -l
```


## Licence

[MIT](LICENSE)

## Ressources

* [download.geofabrik.de - OpenStreetMap Data Extracts](https://download.geofabrik.de/)
* [osm2pgsql.org - OSM2PGSQL MANUAL](https://osm2pgsql.org/doc/manual.html)
* [osm2pgsql.org - osm2pgsql-replication](https://osm2pgsql.org/doc/man/osm2pgsql-replication-1.9.1.html)
* [jakobmiksch.eu - Update an OSM database with osm2pgsql](https://jakobmiksch.eu/post/osm2pgsql-replication-script/)

