#!/bin/sh -e

mkdir -p configuration/kubernetes
cd configuration/kubernetes
# The default compose file uses yml, not yaml.
kompose convert -f ../../docker-compose.yml
