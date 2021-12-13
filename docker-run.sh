#!/bin/bash
docker build -t flinox/mm2-replicator:latest .

docker run --rm -it --hostname mm2-replicator --name mm2-replicator \
--mount type=bind,source="$(pwd)"/config,target=/app/replicator/config/ \
--mount type=bind,source="$(pwd)"/properties,target=/properties/ \
--security-opt label=disable \
flinox/mm2-replicator:latest 
